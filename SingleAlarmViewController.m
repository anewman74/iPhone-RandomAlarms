//
//  SingleAlarmViewController.m
//  MultipleAlarms
//
//  Created by Andrew on 1/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SingleAlarmViewController.h"
#import "MultipleAlarmsAppDelegate.h"
#import "Singleton.h"

@implementation SingleAlarmViewController
@synthesize datePicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle
#pragma mark - View lifecycle
-(void)viewWillAppear:(BOOL)animated {
    
    //Open database
	if(sqlite3_open([[[Singleton sharedSingleton] dataFilePath] UTF8String], &database) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database");
	}
    
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
    
    now = [[NSDate alloc] init];
    [datePicker setDate:now animated:NO];
	[datePicker setMinimumDate:nil];
	[datePicker setMaximumDate:nil];
	
	dateSelectedTime = [[NSDate alloc] init];
	
	newrownumber  = (int)[[Singleton sharedSingleton] getnewrownumber];
    //NSLog(@"row chosen in update method is  %i", newrownumber);

	query = [[NSString alloc] initWithFormat: @"SELECT timeexactstring, doubleexactstring FROM alarms where row = '%i'",newrownumber];     
    //NSLog(@"query - %@", query);
    
	sqlite3_stmt *statement;
	if(sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, nil) == SQLITE_OK){
		while(sqlite3_step(statement) == SQLITE_ROW){
            
            char *singleTimeChosen = (char *)sqlite3_column_text(statement, 0);
            strSelectedTime = [[NSString alloc] initWithFormat:@"%s",singleTimeChosen];
            //NSLog(@"single alarm is  %@", strSelectedTime);
            
            if (![strSelectedTime isEqualToString:@"(null)"]) {
                
                dateSelectedTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 1)];
                //NSLog(@"dateSelectedTime in select %@", dateSelectedTime);
                [datePicker setDate:dateSelectedTime animated:NO];
            }
        }
	}
}

- (void)saveData:(id)sender
{
    self.navigationItem.rightBarButtonItem = nil;

    newrownumber  = (int)[[Singleton sharedSingleton] getnewrownumber];
    //NSLog(@"row chosen in save data method is  %i", newrownumber);
    
    // Formatter
	formatter1 = [[[NSDateFormatter alloc] init] autorelease];
    [formatter1 setDateFormat:@"HH:mm"];
    
    //singleTime.datePickerMode = UIDatePickerModeTime;
	//singleTime.minuteInterval = 1;
    
    //Selected Time Values:
	dateSelectedTime = [datePicker date];
    //NSLog(@"dateSelectedTime %@", dateSelectedTime);
    
	// String date selected
	strSelectedTime = [formatter1 stringFromDate:dateSelectedTime];	    
    //NSLog(@"time selected in details method: %@", strSelectedTime);
    
    char *update = "update alarms set doubleexactstring = ?, timeexactstring = ? where row = ?;";    
    sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK){
        sqlite3_bind_double(stmt,1, [dateSelectedTime timeIntervalSince1970]);
		sqlite3_bind_text(stmt, 2, [strSelectedTime UTF8String], -1, NULL);
		sqlite3_bind_int(stmt, 3, newrownumber);
        
        //NSLog(@"in sql stmt");
	}
    
	if(sqlite3_step(stmt) != SQLITE_DONE)
		NSLog(@"statement failed");
	sqlite3_finalize(stmt);
    
    
    MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController popViewControllerAnimated:NO];
}

- (void)cancelData:(id)sender
{
    self.navigationItem.leftBarButtonItem = nil;
    MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController popViewControllerAnimated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title =  NSLocalizedString(@"Fixed Alarm", @"fixed alarm");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [super dealloc];
    [datePicker release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


@end
