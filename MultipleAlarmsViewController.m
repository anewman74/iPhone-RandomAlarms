//
//  MultipleAlarmsViewController.m
//  MultipleAlarms
//
//  Created by Andrew on 1/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MultipleAlarmsViewController.h"
#import "MultipleAlarmsAppDelegate.h"
#import "Singleton.h"

@implementation MultAlarmTableCell

@synthesize lblName;
@synthesize lblTime;
 
@end

@implementation MultipleAlarmsViewController
@synthesize pickTime;
@synthesize alarmnum;
@synthesize tableTimes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle
-(void)viewWillAppear:(BOOL)animated {
    
    // provide my own Save button to dismiss the keyboard
    UIBarButtonItem* editing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self action:@selector(saveData:)];
    self.navigationItem.rightBarButtonItem = editing;
    [editing release];
    
    // provide my own Cancel button to dismiss the keyboard
    UIBarButtonItem* cancelling = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self action:@selector(cancelData:)];
    self.navigationItem.leftBarButtonItem = cancelling;
    [cancelling release];
    
    //Open database
	if(sqlite3_open([[[Singleton sharedSingleton] dataFilePath] UTF8String], &database) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database");
	}
    
    tableData = [[NSArray alloc] initWithObjects:@"Start Time",@"End Time", nil];
    
    arrTimes = 0;
    arrTimes = [[NSMutableDictionary alloc] init];
    
    // Set the bool so we can make the Start Time with the blue background.
    viewJustAppeared = YES;
    firstRowSelected = NO;
    
    //Set date picker to now.
    now = [[NSDate alloc] init];
    //pickTime = [[[UIDatePicker alloc] init] autorelease];
    pickTime.datePickerMode = UIDatePickerModeTime;
	pickTime.minuteInterval = 1;
    [pickTime setDate:now animated:NO];
    [pickTime addTarget:self
                 action:@selector(updateLabel:)
       forControlEvents:UIControlEventValueChanged]; 
    
    newrownumber  = (int)[[Singleton sharedSingleton] getnewrownumber];
    //NSLog(@"row chosen in update method in mult alarms is  %i", newrownumber);
    
	query = [[NSString alloc] initWithFormat: @"SELECT timestart, doublestart, timeend, doubleend, numalarms FROM alarms where row = '%i'",newrownumber];     
    //NSLog(@"query - %@", query);
    
	sqlite3_stmt *statement;
	if(sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, nil) == SQLITE_OK){
		while(sqlite3_step(statement) == SQLITE_ROW){
            
            timeStartChosen = (char *)sqlite3_column_text(statement, 0);
            strStart = [NSString stringWithFormat:@"%s",timeStartChosen];
            //NSLog(@"in select: %@", strStart);
            
            if ([strStart isEqualToString:@"(null)"]) {
                strStart = @"Select Time";
                
                // Formatter
                formatter1 = [[[NSDateFormatter alloc] init] autorelease];
                [formatter1 setDateFormat:@"HH:mm"];
                strStart = [formatter1 stringFromDate:now];
                strStart = [[Singleton sharedSingleton] hourAMPM:strStart];
                //NSLog(@"str start in view will appear if it was null: %@", strStart);
                
                // Set the str dbl start
                strDblStart = [NSString stringWithFormat:@"%f",[now timeIntervalSince1970]];
            }
            else {
                strDblStart = [NSString stringWithFormat:@"%f",sqlite3_column_double(statement, 1)];
            }
            //NSLog(@"str dbl start: %@", strDblStart);
            [arrTimes setValue:strStart forKey:@"startTime"];
            [arrTimes setValue:strDblStart forKey:@"strDblSt"];
            
            
            timeEndChosen = (char *)sqlite3_column_text(statement, 2);
            strEnd = [NSString stringWithFormat:@"%s",timeEndChosen];
            
            if ([strEnd isEqualToString:@"(null)"]) {
                strEnd = @"Select Time";
                strDblEnd = @"0.000";
            }
            else {
                strDblEnd = [NSString stringWithFormat:@"%f",sqlite3_column_double(statement, 3)];
            }
            //NSLog(@"str dbl start: %@", strDblStart);
            [arrTimes setValue:strEnd forKey:@"endTime"];
            [arrTimes setValue:strDblEnd forKey:@"strDblEnd"];
            
            numAlarms = sqlite3_column_int(statement, 4);
            if(numAlarms == 0) {
                numAlarms = 1;
                alarmnum.text = @"1";
            }
            alarmnum.text = [[NSString alloc] initWithFormat:@"%i",numAlarms];
        }
		sqlite3_finalize(statement);
	}
    
    //NSLog(@"in view will appear, arr times: %@",arrTimes);
    [tableTimes reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title =  @"Random Alarms";
}

- (void)saveData:(id)sender
{
    NSString *stringStart = [arrTimes valueForKey:@"startTime"];
    NSString *stringEnd = [arrTimes valueForKey:@"endTime"];
    strDblStart = [arrTimes valueForKey:@"strDblSt"];
    strDblEnd = [arrTimes valueForKey:@"strDblEnd"];
    
    //NSLog(@"inside save data, string start: %@",stringStart);
    //NSLog(@"string end: %@",stringEnd);
    //NSLog(@"strdblstart: %@",strDblStart);
    //NSLog(@"strdblend: %@",strDblEnd);
    
    if ([stringEnd isEqualToString:@"Select Time"]) {
        //Alert view message.
        message = [[NSString alloc] initWithFormat:
                   @"Please enter a value for the end time."];
        
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
    else if(![stringStart isEqualToString:stringEnd] ) {
        
        self.navigationItem.rightBarButtonItem = nil;
        
        newrownumber  = (int)[[Singleton sharedSingleton] getnewrownumber];
        //NSLog(@"row chosen in update method is  %i", newrownumber);
        
        int numAlarm = [alarmnum.text intValue];
        
        if (numAlarm == 0) {
            numAlarm = 1;
        }
        //NSLog(@"num alarms: %i", numAlarm);
        
        char *update = "update alarms set timestart = ?, timeend = ?, numalarms = ?, doublestart = ?, doubleend =? where row = ?;";   
        //NSLog(@"update: %s", update);
        sqlite3_stmt *stmt;
        if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK){
            sqlite3_bind_text(stmt, 1, [stringStart UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [stringEnd UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 3, numAlarm);
            sqlite3_bind_double(stmt,4, [strDblStart doubleValue]);
            sqlite3_bind_double(stmt,5, [strDblEnd doubleValue]);
            sqlite3_bind_int(stmt, 6, newrownumber);
            
            //NSLog(@"in sql stmt");
        }
        
        if(sqlite3_step(stmt) != SQLITE_DONE)
            NSLog(@"statement failed");
        sqlite3_finalize(stmt);
        
        sqlite3_close(database);
        
        
        MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.navController popViewControllerAnimated:NO];
    }
    else {
        //Alert view message.
        message = [[NSString alloc] initWithFormat:
                   @"Start Time and End Time can not be the same."];
        
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
}

- (void)cancelData:(id)sender
{
    self.navigationItem.leftBarButtonItem = nil;
    MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController popViewControllerAnimated:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    // Set the bool so we can make the Start Time with the blue background.
    viewJustAppeared = NO;
    firstRowSelected = NO;
    
    [alarmnum resignFirstResponder];
	[self becomeFirstResponder];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
    
    alarmnum.text = @"";
}

-(BOOL) textFieldShouldReturn: (UITextField *) theTextField {	
    
	[theTextField resignFirstResponder];
	[self becomeFirstResponder];
	
	return YES;
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    MultAlarmTableCell *cell = (MultAlarmTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"MultAlarmTableCell" owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    //NSLog(@"table loading view just appeared: %i",viewJustAppeared);
    //NSLog(@"first selected: %i", firstRowSelected);
    //NSLog(@"index path row in update label: %i",indexPath.row);
    
    if (viewJustAppeared == YES) {
        if (indexPath.row == 0) {
            
            cell.backgroundColor = [UIColor blueColor];
            //Set up the cell names
            [cell.lblName setText:[tableData objectAtIndex:indexPath.row]];
            [cell.lblName setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblName.textColor = [UIColor whiteColor];
            cell.lblName.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblName];
            
            // Formatter
            formatter1 = [[[NSDateFormatter alloc] init] autorelease];
            [formatter1 setDateFormat:@"HH:mm"];
            
            //Selected Time Values:
            timeSelectedStart = [pickTime date];
            
            // String date selected
            strSelectedStart = [formatter1 stringFromDate:timeSelectedStart];
            strSelectedStart = [[Singleton sharedSingleton] hourAMPM:strSelectedStart];
            //NSLog(@"date selected in details method: %@", strSelectedStart);
            
            [cell.lblTime setText:[arrTimes valueForKey:@"startTime"]];
            [cell.lblTime setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblTime.textColor = [UIColor whiteColor];
            cell.lblTime.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblTime];
        }
        else {
            cell.backgroundColor = [UIColor whiteColor];
            //Set up the cell names
            [cell.lblName setText:[tableData objectAtIndex:indexPath.row]];
            [cell.lblName setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblName.textColor = [UIColor blackColor];
            cell.lblName.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblName];
            
            // Formatter
            formatter1 = [[[NSDateFormatter alloc] init] autorelease];
            [formatter1 setDateFormat:@"HH:mm"];
            
            //Selected Time Values:
            timeSelectedEnd = [pickTime date];
            
            // String date selected
            strSelectedEnd = [formatter1 stringFromDate:timeSelectedEnd];	
            strSelectedEnd = [[Singleton sharedSingleton] hourAMPM:strSelectedEnd];
            //NSLog(@"date selected in details method: %@", strSelectedEnd);
            
            [cell.lblTime setText:[arrTimes valueForKey:@"endTime"]];
            [cell.lblTime setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblTime.textColor = [UIColor blueColor];
            cell.lblTime.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblTime];
        }
    }
    else if(firstRowSelected == YES) {
        if (indexPath.row == 0) {
            cell.backgroundColor = [UIColor whiteColor];
            //Set up the cell names
            [cell.lblName setText:[tableData objectAtIndex:indexPath.row]];
            [cell.lblName setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblName.textColor = [UIColor blackColor];
            cell.lblName.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblName];
            
            // Formatter
            formatter1 = [[[NSDateFormatter alloc] init] autorelease];
            [formatter1 setDateFormat:@"HH:mm"];
            
            //Selected Time Values:
            timeSelectedStart = [pickTime date];
            
            // String date selected
            strSelectedStart = [formatter1 stringFromDate:timeSelectedStart];
            strSelectedStart = [[Singleton sharedSingleton] hourAMPM:strSelectedStart];
            //NSLog(@"date selected in details method: %@", strSelectedStart);
            
            [cell.lblTime setText:[arrTimes valueForKey:@"startTime"]];
            [cell.lblTime setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblTime.textColor = [UIColor blueColor];
            cell.lblTime.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblTime];
        }
        else {
            cell.backgroundColor = [UIColor blueColor];
            //Set up the cell names
            [cell.lblName setText:[tableData objectAtIndex:indexPath.row]];
            [cell.lblName setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblName.textColor = [UIColor whiteColor];
            cell.lblName.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblName];
            
            // Formatter
            formatter1 = [[[NSDateFormatter alloc] init] autorelease];
            [formatter1 setDateFormat:@"HH:mm"];
            
            //Selected Time Values:
            timeSelectedEnd = [pickTime date];
            
            // String date selected
            strSelectedEnd = [formatter1 stringFromDate:timeSelectedEnd];	
            strSelectedEnd = [[Singleton sharedSingleton] hourAMPM:strSelectedEnd];
            //NSLog(@"date selected in details method: %@", strSelectedEnd);
            
            [cell.lblTime setText:[arrTimes valueForKey:@"endTime"]];
            [cell.lblTime setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblTime.textColor = [UIColor whiteColor];
            cell.lblTime.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblTime];
        }
    }
    else {
        if (indexPath.row == 0) {
            cell.backgroundColor = [UIColor whiteColor];
            //Set up the cell names
            [cell.lblName setText:[tableData objectAtIndex:indexPath.row]];
            [cell.lblName setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblName.textColor = [UIColor blackColor];
            cell.lblName.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblName];
            
            // Formatter
            formatter1 = [[[NSDateFormatter alloc] init] autorelease];
            [formatter1 setDateFormat:@"HH:mm"];
            
            //Selected Time Values:
            timeSelectedStart = [pickTime date];
            
            // String date selected
            strSelectedStart = [formatter1 stringFromDate:timeSelectedStart];
            strSelectedStart = [[Singleton sharedSingleton] hourAMPM:strSelectedStart];
            //NSLog(@"date selected in details method: %@", strSelectedStart);
            
            [cell.lblTime setText:[arrTimes valueForKey:@"startTime"]];
            [cell.lblTime setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblTime.textColor = [UIColor blueColor];
            cell.lblTime.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblTime];
        }
        else {
            cell.backgroundColor = [UIColor whiteColor];
            //Set up the cell names
            [cell.lblName setText:[tableData objectAtIndex:indexPath.row]];
            [cell.lblName setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblName.textColor = [UIColor blackColor];
            cell.lblName.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblName];
            
            // Formatter
            formatter1 = [[[NSDateFormatter alloc] init] autorelease];
            [formatter1 setDateFormat:@"HH:mm"];
            
            //Selected Time Values:
            timeSelectedEnd = [pickTime date];
            
            // String date selected
            strSelectedEnd = [formatter1 stringFromDate:timeSelectedEnd];	
            strSelectedEnd = [[Singleton sharedSingleton] hourAMPM:strSelectedEnd];
            //NSLog(@"date selected in details method: %@", strSelectedEnd);
            
            [cell.lblTime setText:[arrTimes valueForKey:@"endTime"]];
            [cell.lblTime setFont:[UIFont boldSystemFontOfSize:16]];
            cell.lblTime.textColor = [UIColor blueColor];
            cell.lblTime.backgroundColor = [UIColor clearColor];
            [cell addSubview:cell.lblTime];
        }
    }
    
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"inside will select, indexPath.row: %i",indexPath.row);
    
    //NSLog(@"viewJustAppeared: %i", viewJustAppeared);
    //NSLog(@"firstRowSelected: %i", firstRowSelected);
    
    [alarmnum resignFirstResponder];
    
    if (viewJustAppeared == YES) {
        viewJustAppeared = NO;
        firstRowSelected = YES;
        [tableTimes reloadData];
    }
    else {
        MultAlarmTableCell *cell = (MultAlarmTableCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell setBackgroundColor: [UIColor blueColor]];
        cell.lblName.textColor = [UIColor whiteColor];
        cell.lblName.backgroundColor = [UIColor clearColor];
        cell.lblTime.textColor = [UIColor whiteColor];
        cell.lblTime.backgroundColor = [UIColor clearColor]; 
        firstRowSelected = NO;
    }
    //NSLog(@"viewJustAppeared: %i", viewJustAppeared);
    //NSLog(@"firstRowSelected: %i", firstRowSelected);

    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"inside will deselect, indexPath.row: %i",indexPath.row);
        
    MultAlarmTableCell *cell = (MultAlarmTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor: [UIColor whiteColor]];
    cell.lblName.textColor = [UIColor blackColor];
    cell.lblName.backgroundColor = [UIColor clearColor];
    cell.lblTime.textColor = [UIColor blueColor];
    cell.lblTime.backgroundColor = [UIColor clearColor];
        
    return indexPath;
}

- (void)updateLabel:(id)sender {
    //NSLog(@"inside update label");
    //NSLog(@"view just appeared: %i",viewJustAppeared);
    //NSLog(@"first selected: %i", firstRowSelected);
    
    NSIndexPath *indexPath = [tableTimes indexPathForSelectedRow];
    //NSLog(@"index path row of table in update label: %i",indexPath.row);
    
    // Formatter
	formatter1 = [[[NSDateFormatter alloc] init] autorelease];
    [formatter1 setDateFormat:@"HH:mm"];
    
    //Selected Time Values:
	timeSelectedStart = [pickTime date];
    //NSLog(@"picked in update label: %@", timeSelectedStart);
    double dblPicker = [timeSelectedStart timeIntervalSince1970];
    //NSLog(@"dblpicker in update label: %f", dblPicker);
    NSString *strDblPicker = [NSString stringWithFormat:@"%f",dblPicker];
    //NSLog(@"strDblPicker in update label: %@", strDblPicker);
    
	// String date selected
	strSelectedStart = [formatter1 stringFromDate:timeSelectedStart];
    strSelectedStart = [[Singleton sharedSingleton] hourAMPM:strSelectedStart];
    //NSLog(@"date selected in details method: %@", strSelectedStart);
    
    MultAlarmTableCell *cell = (MultAlarmTableCell *)[tableTimes cellForRowAtIndexPath:indexPath];
    cell.lblTime.text = strSelectedStart;
    
    // This is actually when the view has just appeared ... viewJustAppeared = YES.
    if (viewJustAppeared == YES) {
        [arrTimes setValue:strSelectedStart forKey:@"startTime"];
        [arrTimes setValue:strDblPicker forKey:@"strDblSt"];
        
        //for the first select, reload table
        [tableTimes reloadData];
    }
    else {
        if (indexPath.row == 0) {
            [arrTimes setValue:strSelectedStart forKey:@"startTime"];
            [arrTimes setValue:strDblPicker forKey:@"strDblSt"];
        }
        else {
            [arrTimes setValue:strSelectedStart forKey:@"endTime"];
            [arrTimes setValue:strDblPicker forKey:@"strDblEnd"];
        }
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [super dealloc];
    [pickTime release];
    [alarmnum release];
    [tableTimes release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


@end
