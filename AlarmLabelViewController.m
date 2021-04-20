//
//  AlarmLabelViewController.m
//  MultipleAlarms
//
//  Created by Andrew on 1/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "AlarmLabelViewController.h"
#import "MultipleAlarmsAppDelegate.h"
#import "Singleton.h"

@implementation AlarmLabelViewController
@synthesize name;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle.
-(void)viewWillAppear:(BOOL)animated {
    
    //NSLog(@"in alarmlabel VC");
    
	//Open database
	if(sqlite3_open([[[Singleton sharedSingleton] dataFilePath] UTF8String], &database) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database");
    }
    
    newrownumber  = (int)[[Singleton sharedSingleton] getnewrownumber];
    //NSLog(@"row chosen in update method is  %i", newrownumber);
    
    // Check the updated values.
	query = [[NSString alloc] initWithFormat: @"SELECT name FROM alarms where row = '%i'",newrownumber];     
    //NSLog(@"query - %@", query);
    
	sqlite3_stmt *statement;
	if(sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, nil) == SQLITE_OK){
		while(sqlite3_step(statement) == SQLITE_ROW){
			char *nameChosen = (char *)sqlite3_column_text(statement, 0);
            //NSLog(@"name chosen in details view is  %s", nameChosen);
            name.text = [NSString stringWithFormat: @"%s", nameChosen];
		}
		sqlite3_finalize(statement);
	}
    
    // Show keyboard
    [name becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
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
    
}
- (void)viewDidLoad
{
    self.title =  NSLocalizedString(@"Alarm Label", @"quote");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - methods for the keyboard scrolling effect.
- (void)saveData:(id)sender
{
    newrownumber  = (int)[[Singleton sharedSingleton] getnewrownumber];
    //NSLog(@"row chosen in save data method is  %i", newrownumber);
    
    char *update = "update alarms set name = ? where row = ?;";    
    sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK){
		sqlite3_bind_text(stmt, 1, [name.text UTF8String], -1, NULL);
		sqlite3_bind_int(stmt, 2, newrownumber);
        
        //NSLog(@"in sql stmt");
	}
    
	if(sqlite3_step(stmt) != SQLITE_DONE)
		NSLog(@"statement failed");
	sqlite3_finalize(stmt);
    
    // finish typing text/dismiss the keyboard by removing it as the first responder
    [self.name resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;   // this will remove the "save" button
    
    MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController popViewControllerAnimated:NO];
}

- (void)cancelData:(id)sender
{
    [self.name resignFirstResponder];
    self.navigationItem.leftBarButtonItem = nil;
    
    MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController popViewControllerAnimated:NO];
}

- (void)keyboardWillShow:(NSNotification *)aNotification 
{
    // the keyboard is showing so resize the table's height
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
	[[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
	frame.size.height = 415;
    frame.size.height -= keyboardRect.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}

-(BOOL) textFieldShouldReturn: (UITextField *) theTextField {	
	
    newrownumber  = (int)[[Singleton sharedSingleton] getnewrownumber];
    //NSLog(@"row chosen in save data method is  %i", newrownumber);
    
    char *update = "update alarms set name = ? where row = ?;";    
    sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK){
		sqlite3_bind_text(stmt, 1, [name.text UTF8String], -1, NULL);
		sqlite3_bind_int(stmt, 2, newrownumber);
        
        //NSLog(@"in sql stmt");
	}
    
	if(sqlite3_step(stmt) != SQLITE_DONE)
		NSLog(@"statement failed");
	sqlite3_finalize(stmt);
    
	[theTextField resignFirstResponder];
	[self becomeFirstResponder];
	
	return YES;
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    sqlite3_close(database);
    [self.name resignFirstResponder];
    [self becomeFirstResponder];
    name.text = [NSString stringWithFormat:@""];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


@end
