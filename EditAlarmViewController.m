//
//  EditAlarmViewController.m
//  MultipleAlarms
//
//  Created by Andrew on 9/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EditAlarmViewController.h"
#import "MultipleAlarmsAppDelegate.h"
#import "AlarmLabelViewController.h"
#import "SoundsViewController.h"
#import "SingleAlarmViewController.h"
#import "MultipleAlarmsViewController.h"
#import "Singleton.h"
#import "Utils.h"

@implementation EditAlarmViewController
@synthesize alarmLabelVC;
@synthesize soundsVC;
@synthesize singleVC;
@synthesize multVC;
@synthesize tabl;
@synthesize tableData;
@synthesize snoozes;

-(void)initializeTableData {
    
    tableData = 0;
	tableData = [[NSMutableArray alloc] init]; //initialize the array
    
    tableResult = 0;
	tableResult = [[NSMutableArray alloc] init]; //initialize the array
    
    newrownumber  = (int)[[Singleton sharedSingleton] getnewrownumber];
    //NSLog(@"row chosen in update method is  %i", newrownumber);

	query = [[NSString alloc] initWithFormat: @"SELECT name, sound, snooze, timeexactstring, timestart, timeend, numalarms FROM alarms where row = '%i'",newrownumber];     
    //NSLog(@"query - %@", query);
    
	sqlite3_stmt *statement;
	if(sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, nil) == SQLITE_OK){
		while(sqlite3_step(statement) == SQLITE_ROW){
            
			char *nameChosen = (char *)sqlite3_column_text(statement, 0);
            //NSLog(@"name for alarm is  %s", nameChosen);
            
            alarmLabel = [NSString stringWithFormat: @"%s",nameChosen];
            
            // Capitalize the first letter of words.
            char *sound = (char *)sqlite3_column_text(statement, 1);
            soundLabel = [[NSString stringWithFormat: @"%s",sound] capitalizedString];
            //NSLog(@"sound label is  %@", soundLabel);
            
            snoozeSaved = sqlite3_column_int(statement, 2);	    
            //NSLog(@"snooze for alarm : %i", snoozeSaved);
            
            singleTimeChosen = (char *)sqlite3_column_text(statement, 3);
            strSingleTime = [[NSString alloc] initWithFormat:@"%s",singleTimeChosen];
            //NSLog(@"single alarm is  %@", strSingleTime);
            
            if ([strSingleTime isEqualToString:@"(null)"]) {
                strSingleTime = @"Not Set";
                //NSLog(@"single alarm is in if %@", strSingleTime);
            }
            else {
                strSingleTime = [[Singleton sharedSingleton] hourAMPM:strSingleTime];
            }
            
            timeStartChosen = (char *)sqlite3_column_text(statement, 4);
            strStart = [[NSString alloc] initWithFormat:@"%s",timeStartChosen];
            timeEndChosen = (char *)sqlite3_column_text(statement, 5);
            strEnd = [[NSString alloc] initWithFormat:@"%s",timeEndChosen];
            //NSLog(@"time start is  %@", strStart);
            //NSLog(@"time end is  %@", strEnd);
            
            // If there are values for both start and end
            if ([strStart isEqualToString:@"(null)"] || [strEnd isEqualToString:@"(null)"]) {
                timeRange = @"Not Set";
                //NSLog(@"time range for alarm is  %@", timeRange);
            }
            else {
                timeRange = [[NSString alloc] initWithFormat:@"%@ - %@",strStart,strEnd];
                //NSLog(@"time range for alarm in else is  %@", timeRange);
            }
            
            if ([timeRange isEqualToString:@"Start Time - End Time"]) {
                timeRange = @"Not Set";
            }
            //NSLog(@"time range for alarm in else is  %@", timeRange);
            
            numAlarms = sqlite3_column_int(statement, 6);
            
            if (numAlarms == 0) {
                strAlarms = @"1";
            }
            else {
                strAlarms = [[NSString alloc] initWithFormat:@"%i",numAlarms];
            }
            //NSLog(@"number of alarms : %@", strAlarms);
            
            
		}
		sqlite3_finalize(statement);
	}
    
    if ([strSingleTime isEqualToString:@"Not Set"] && [timeRange isEqualToString:@"Not Set"]) {
        
        //NSLog(@"both not set");
        [tableData addObject:@"Label"];
        [tableData addObject:@"Sound"];
        [tableData addObject:@"Fixed Time Alarm"];
        [tableData addObject:@"Random Alarms"];
        
        [tableResult addObject:alarmLabel];
        [tableResult addObject:soundLabel];
        [tableResult addObject:strSingleTime];
        [tableResult addObject:timeRange];
    }
    
    else if ([strSingleTime isEqualToString:@"Not Set"] && ![timeRange isEqualToString:@"Not Set"]) {
        
        //NSLog(@"single alarm not set");
        [tableData addObject:@"Label"];
        [tableData addObject:@"Sound"];
        [tableData addObject:@"Random Alarms"];
        [tableData addObject:@"No. of Alarms"];
        
        [tableResult addObject:alarmLabel];
        [tableResult addObject:soundLabel];
        [tableResult addObject:timeRange];
        [tableResult addObject:strAlarms];
    }
    
    else if ( ![strSingleTime isEqualToString:@"Not Set"] && [timeRange isEqualToString:@"Not Set"]) {
        
        //NSLog(@"multiple alarm not set");
        [tableData addObject:@"Label"];
        [tableData addObject:@"Sound"];
        [tableData addObject:@"Fixed Time Alarm"];
        [tableData addObject:@"Snooze"];
        
        [tableResult addObject:alarmLabel];
        [tableResult addObject:soundLabel];
        [tableResult addObject:strSingleTime];
        [tableResult addObject:@""]; 
    }
    
    //NSLog(@"table result: %@", tableResult);
    
    [tabl reloadData];
}

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
    
    //NSLog(@"in view will appear in edit alarmsVC");
    
    self.navigationItem.hidesBackButton = YES;
    
    //Open database
	if(sqlite3_open([[[Singleton sharedSingleton] dataFilePath] UTF8String], &database) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database");
	}
    
    [self initializeTableData];
    
    // provide my own Save button to dismiss the keyboard
    UIBarButtonItem* editing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self action:@selector(saveData:)];
    self.navigationItem.rightBarButtonItem = editing;
    [editing release];
    
    // provide my own Cancel button to dismiss the keyboard
    UIBarButtonItem* cancelling = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self action:@selector(cancelData:)];
    self.navigationItem.leftBarButtonItem = cancelling;
    [cancelling release];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(15, 370, 290, 20)];
    [name setText:@"* Choose either fixed time alarm or random alarms."];
    [name setFont:[UIFont systemFontOfSize:12]];
    name.textColor = [UIColor darkGrayColor];
    name.backgroundColor = [UIColor clearColor];
    [self.view addSubview:name];
    [name release];
    
    UILabel *name2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 400, 290, 20)];
    [name2 setText:@"* Snooze is set 9 minutes after fixed time alarm."];
    [name2 setFont:[UIFont systemFontOfSize:12]];
    name2.textColor = [UIColor darkGrayColor];
    name2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:name2];
    [name2 release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title =  NSLocalizedString(@"Edit Alarm", @"edit alarm");
    
    // Create new alarm if newalarm = 1 in Singleton class.
    
}

- (void)saveData:(id)sender
{
    self.navigationItem.rightBarButtonItem = nil;
    
    // Find out if snooze is chosen
    if (snoozes.on == YES) {
        //NSLog(@"snooze is on");
        snoozeValue = 1;
    }
    else {
        //NSLog(@"snooze is off");
        snoozeValue = 0;
    }
    
    newrownumber  = (int)[[Singleton sharedSingleton] getnewrownumber];
    //NSLog(@"row chosen in update method is  %i", newrownumber);
    
    char *update = "update alarms set snooze = ?, alarmon = ? where row = ?;";    
    sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK){
		sqlite3_bind_int(stmt, 1, snoozeValue);
        sqlite3_bind_int(stmt, 2, 1);
		sqlite3_bind_int(stmt, 3, newrownumber);
        
        //NSLog(@"in sql stmt");
	}
    
	if(sqlite3_step(stmt) != SQLITE_DONE)
		NSLog(@"statement failed");
	sqlite3_finalize(stmt);

    if ([soundLabel isEqualToString:@"Not Set"]) {
        //NSLog(@"null sound");
        //Alert view message.
        message = [[NSString alloc] initWithFormat:
                   @"Please set a sound for the alarm."];
        
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
    else if ([strSingleTime isEqualToString:@"Not Set"] && [timeRange isEqualToString:@"Not Set"]) {
        //Alert view message.
        message = [[NSString alloc] initWithFormat:
                   @"Please set a time for the single alarm or a time range for the random alarms."];
        
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
    else {
        [Utils startActivityIndicator:@"Setting alarms ..."];
        
        // go to root controller
        [self performSelector:@selector(goToRootController) withObject:self afterDelay:1.0 ];
    }
}

- (void) goToRootController {
    MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController popToRootViewControllerAnimated:NO];
}

- (void)cancelData:(id)sender
{
    // Get the row chosen from FrontVC
    newrownumber  = (int)[[Singleton sharedSingleton] getnewrownumber];
    //NSLog(@"row chosen from frontVC is  %i", newrownumber);
    
    // Get the last DB entry made to carry to next view in singleton to use in update.
	query =  @"SELECT row FROM alarms order by row desc limit 1"; 	
	sqlite3_stmt *stateme;
	if(sqlite3_prepare_v2(database, [query UTF8String],-1, &stateme, nil) == SQLITE_OK){
		while(sqlite3_step(stateme) == SQLITE_ROW){
			lastRowDatabase = sqlite3_column_int(stateme, 0);		    
            //NSLog(@"last row saved : %i", lastRowDatabase); 
		}
		sqlite3_finalize(stateme);
	}
    
    // Get the row chosen from FrontVC
    int plusclicked  = (int)[[Singleton sharedSingleton] getplusclicked];
    //NSLog(@"plusclicked from frontVC is  %i", plusclicked);
    
    if ((newrownumber == lastRowDatabase) && (plusclicked == 1)) {
        
        // Delete this row in DB.
        char *update = "delete from alarms where row = ?;";	
        sqlite3_stmt *stmt;
        if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK){
            sqlite3_bind_int(stmt, 1, newrownumber);		
        }
        
        // Check if DB delete functioned
        if(sqlite3_step(stmt) != SQLITE_DONE)
            NSLog(@"statement failed.");
        
        else {
            NSLog(@"delete statement worked.");
        }
        sqlite3_finalize(stmt);
        
        //Close database
        sqlite3_close(database);

    }
    self.navigationItem.leftBarButtonItem = nil;
    MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController popToRootViewControllerAnimated:NO];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    
    NSInteger row = [indexPath row];
    
    //Set up the cell names
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 120, 36)];
    [label setText:[tableData objectAtIndex:indexPath.row]];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor whiteColor];
    [cell addSubview:label];
    [label release];
    
    if ( [tableData containsObject:@"Fixed Time Alarm"] && ![tableData containsObject:@"Random Alarms"] && row == 3) {
        
        // Bug #81: Extra "t" remains on the screen after adding new fixed alarm
        // Make this cell wide enough to fully cover previous text
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(146, 6, 54, 36)];
        [name setText:@""];
        [name setFont:[UIFont boldSystemFontOfSize:13]];
        name.textColor = [UIColor blackColor];
        name.backgroundColor = [UIColor whiteColor];
        [cell addSubview:name];
        [name release];
        
        //NSLog(@"inside if so load snooze switch");

        snoozes = [[UISwitch alloc] initWithFrame:CGRectMake(152, 6, 130, 40)];
        
        // Get snooze saved from database.
        if (snoozeSaved == 0) {
            [snoozes setOn:NO];
        }
        else {
            [snoozes setOn:YES];
        }
        
        [cell addSubview:snoozes];
        [snoozes release];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        
        //NSLog(@"inside else so don't load switch");
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(146, 6, 132, 36)];
        [name setText:[tableResult objectAtIndex:indexPath.row]];
        [name setFont:[UIFont boldSystemFontOfSize:13]];
        name.textColor = [UIColor blackColor];
        name.backgroundColor = [UIColor whiteColor];
        [cell addSubview:name];
        [name release];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.selectionStyle = UITableViewCellEditingStyleNone;

    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    //NSLog(@"row selected: %i",[indexPath row]);
    
    if ([indexPath row] == 0) {
        if (self.alarmLabelVC == nil)
        {
           AlarmLabelViewController *aDetail = [[AlarmLabelViewController alloc] initWithNibName: @"AlarmLabelViewController" bundle:[NSBundle mainBundle]];
            self.alarmLabelVC = aDetail;
            [aDetail release];
        }	
        MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.navController pushViewController:alarmLabelVC animated:NO];
    }
    else if ([indexPath row] == 1) {
        if (self.soundsVC == nil)
        {
            SoundsViewController *aDetail = [[SoundsViewController alloc] initWithNibName: @"SoundsViewController" bundle:[NSBundle mainBundle]];
            self.soundsVC = aDetail;
            [aDetail release];
        }	
        MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.navController pushViewController:soundsVC animated:YES];
    }
    else if ([tableData containsObject:@"Fixed Time Alarm"] && [indexPath row] == 2) {
        if (self.singleVC == nil)
        {
            SingleAlarmViewController *aDetail = [[SingleAlarmViewController alloc] initWithNibName: @"SingleAlarmViewController" bundle:[NSBundle mainBundle]];
            self.singleVC = aDetail;
            [aDetail release];
        }	
        MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.navController pushViewController:singleVC animated:NO];
    }
    else if ([tableData containsObject:@"Fixed Time Alarm"] && [tableData containsObject:@"Random Alarms"] && [indexPath row] == 3) {
        if (self.multVC == nil)
        {
            MultipleAlarmsViewController *aDetail = [[MultipleAlarmsViewController alloc] initWithNibName: @"MultipleAlarmsViewController" bundle:[NSBundle mainBundle]];
            self.multVC = aDetail;
            [aDetail release];
        }	
        MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.navController pushViewController:multVC animated:NO];
    }
    else if (![tableData containsObject:@"Fixed Time Alarm"] && [tableData containsObject:@"Random Alarms"] && [indexPath row] == 2) {
        if (self.multVC == nil)
        {
            MultipleAlarmsViewController *aDetail = [[MultipleAlarmsViewController alloc] initWithNibName: @"MultipleAlarmsViewController" bundle:[NSBundle mainBundle]];
            self.multVC = aDetail;
            [aDetail release];
        }	
        MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.navController pushViewController:multVC animated:NO];
    }
    else if (![tableData containsObject:@"Fixed Time Alarm"] && [tableData containsObject:@"Random Alarms"] && [indexPath row] == 3) {
        if (self.multVC == nil)
        {
            MultipleAlarmsViewController *aDetail = [[MultipleAlarmsViewController alloc] initWithNibName: @"MultipleAlarmsViewController" bundle:[NSBundle mainBundle]];
            self.multVC = aDetail;
            [aDetail release];
        }	
        MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.navController pushViewController:multVC animated:NO];
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
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
