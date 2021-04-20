//
//  FrontViewController.m
//  MultipleAlarms
//
//  Created by Andrew on 9/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FrontViewController.h"
#import "EditAlarmViewController.h"
#import "MultipleAlarmsAppDelegate.h"
#import "Singleton.h"
#import "Utils.h"

@implementation FrontViewController
@synthesize editAlarm;
@synthesize tabl;


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
    
    [super viewWillAppear:animated];
    
//    NSLog(@"inside view will appear");
    
    //Set up the cell
    tabl.separatorColor = [UIColor clearColor];
    tabl.backgroundColor = [UIColor clearColor];
    [tabl setContentOffset:CGPointZero animated:NO];
    
    //Open database
	if(sqlite3_open([[[Singleton sharedSingleton] dataFilePath] UTF8String], &database) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database");
	}
	
	char *errorMsg;
	createSQL = @"CREATE TABLE IF NOT EXISTS alarms (row integer primary key,timestart varchar(25),timeend varchar(25), doublestart double, doubleend double, name varchar(25), sound varchar(255), soundfile varchar(255),soundLength varchar(25), snooze integer,typealarm integer, numalarms integer, doubleexactstring double, timeexactstring varchar(25), alarmon integer );";
    
	if(sqlite3_exec(database, [createSQL UTF8String],NULL,NULL,&errorMsg) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert1(0,@"Error creating table: %s", errorMsg);
	}
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // provide my own Save button to dismiss the keyboard
    UIBarButtonItem* addAlarm = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			  target:self action:@selector(createAlarm:)];
    self.navigationItem.rightBarButtonItem = addAlarm;
    [addAlarm release];
    
    // Registering application did enter background.
    if (!application) {
        application = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:application];
    }
    
    // Registering application will terminate.
    if (!application2) {
        application2 = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:application2];
    }
    
    // Registering application will enter foreground.
    if (!application3) {
        application3 = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:application3];
    }
    
    // If the App had previously set alarms but the phone had then been turned completely off, then the notifications,
    // will not work correctly the following day. So, we will delete all notifications and any alarms stored in
    // NSDefaults.
    application4 = [UIApplication sharedApplication];
    oldNotifications = [application4 scheduledLocalNotifications];
    if ([oldNotifications count] > 0) {
        [application4 cancelAllLocalNotifications];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"0" forKey:@"randomAlarmSounded"];
    [defaults setObject:@"0" forKey:@"snoozeSetToRun"];
    [defaults synchronize];
    
    [self createArrayNotifications];
    
    fromAppEnterForeground = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSLog(@"view did load");
    
    // Do any additional setup after loading the view from its nib.
    self.title =  @"Random Alarms";
}


- (void)createAlarm:(id)sender
{
    // If selected a row, then existing random alarms and snooze should be ignored.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"0" forKey:@"randomAlarmSounded"];
    //NSLog(@"random alarm sounded: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"randomAlarmSounded"]);
    
    [defaults setObject:@"0" forKey:@"snoozeSetToRun"];
    [defaults synchronize];
    
    //NSLog(@"snoozeSetToRun in create alarm: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"snoozeSetToRun"]);
    
    self.navigationItem.rightBarButtonItem = nil;
    //NSLog(@"in create alarm method");
    
    int plusclicked = 1;
    [[Singleton sharedSingleton] setplusclicked:plusclicked];
    //NSLog(@"plusclicked saved in Singleton is  %i", plusclicked);
    
    //Save alarm data into sqlite.
    char *insert = "INSERT INTO alarms (name, sound, soundfile, soundlength) VALUES(?,?,?,?);";	
    //NSLog(@"insert: %s", insert);
	sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(database, insert, -1, &stmt, nil) == SQLITE_OK){
        sqlite3_bind_text(stmt, 1, [@"Alarm" UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [@"cold" UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [@"48456__flick3r__cold-3.mp3" UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [@"0.07" UTF8String], -1, NULL);
        //NSLog(@"in sql insert stmt");
	}
	if(sqlite3_step(stmt) != SQLITE_DONE)
		NSLog(@"statement failed");
    sqlite3_finalize(stmt);
    
    // Get the last DB entry made to carry to next view in singleton to use in update.
	query =  @"SELECT row FROM alarms order by row desc limit 1"; 	
	sqlite3_stmt *stateme;
	if(sqlite3_prepare_v2(database, [query UTF8String],-1, &stateme, nil) == SQLITE_OK){
		while(sqlite3_step(stateme) == SQLITE_ROW){
			int row = sqlite3_column_int(stateme, 0);
			[[Singleton sharedSingleton] setnewrownumber:row];		    
            //NSLog(@"after plus clicked - last row saved : %i", row); 
		}
		sqlite3_finalize(stateme);
	}
    
	sqlite3_close(database);
    
    
    if (self.editAlarm == nil)
	{
		EditAlarmViewController *aDetail = [[EditAlarmViewController alloc] initWithNibName: @"EditAlarmViewController" bundle:[NSBundle mainBundle]];
		self.editAlarm = aDetail;
		[aDetail release];
	}	
	MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.navController pushViewController:editAlarm animated:NO];
}

-(void)createArrayNotifications {
    //NSLog(@"inside create array notifications.");
    
    arrNotifications = 0;
	arrNotifications = [[NSMutableArray alloc] init]; //initialize the array
    
    alarmIsSet = 0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    dateTime = [[NSDate alloc] init];
    
    arrAlarms = 0;
	arrAlarms = [[NSMutableArray alloc] init]; //initialize the array
    
    // Get all the dates for the goal chosen
	query = [[NSString alloc] initWithFormat: @"SELECT name, soundfile, soundLength, snooze, timeexactstring, doublestart,doubleend, numalarms, alarmon, doubleexactstring, row, timestart, timeend FROM alarms order by row desc"]; 
    
    //NSLog(@"query - %@", query);
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, nil) == SQLITE_OK){
        while(sqlite3_step(statement) == SQLITE_ROW){
            
            dictAlarmDetails = 0;
            dictAlarmDetails = [[NSMutableDictionary alloc] init];
            
            alarmName = (char *)sqlite3_column_text(statement, 0);
            alarmLabel = [NSString stringWithFormat: @"%s",alarmName];
            //NSLog(@"alarm label: %@", alarmLabel);
            
            char *sound = (char *)sqlite3_column_text(statement, 1);
            //NSLog(@"sound for alarm is  %s", sound);
            
            soundLabel = [NSString stringWithFormat: @"%s",sound];
            
            soundLength = [NSString stringWithFormat:@"%s", (char *)sqlite3_column_text(statement,2)];
            //NSLog(@"sound length : %@", soundLength);
            
            snoozeSaved = sqlite3_column_int(statement, 3);	
            strSnooze = [NSString stringWithFormat:@"%i",snoozeSaved];
            //NSLog(@"snooze for alarm : %@", strSnooze);
            
            singleTimeChosen = (char *)sqlite3_column_text(statement, 4);
            strSingleTime = [[NSString alloc] initWithFormat:@"%s",singleTimeChosen];
            //NSLog(@"single alarm is  %@", strSingleTime);
            
            // If single time not set, then get the multiple alarm times.
            if ([strSingleTime isEqualToString:@"(null)"]) {
                //NSLog(@"single alarm is in if %@", strSingleTime);
                
                strStart = [NSString stringWithFormat:@"%f",sqlite3_column_double(statement, 5)];
                strEnd = [NSString stringWithFormat:@"%f",sqlite3_column_double(statement, 6)];
                
                //NSLog(@"time start is  %@", strStart);
                //NSLog(@"time end is  %@", strEnd);
                
                timeRange = [[NSString alloc] initWithFormat:@"%@ - %@",strStart,strEnd];
                //NSLog(@"time range for alarm in else is  %@", timeRange);
                [dictAlarmDetails setValue:timeRange forKey:@"alarmTimes"];
                
                numalarms = sqlite3_column_int(statement, 7);
                if (numalarms == 1) {
                    alarmnum = @"1 alarm";
                }
                else {
                    alarmnum = [[NSString alloc] initWithFormat:@"%i alarms",numalarms];
                }
                
                timeStartChosen = (char *)sqlite3_column_text(statement, 11);
                strStart = [[NSString alloc] initWithFormat:@"%s",timeStartChosen];
                timeEndChosen = (char *)sqlite3_column_text(statement, 12);
                strEnd = [[NSString alloc] initWithFormat:@"%s",timeEndChosen];
                //NSLog(@"time start is  %@", strStart);
                //NSLog(@"time end is  %@", strEnd);
                
                timeRange = [[NSString alloc] initWithFormat:@"%@ - %@",strStart,strEnd];
                //NSLog(@"time range for alarm in else is  %@", timeRange);
                [dictAlarmDetails setValue:timeRange forKey:@"strAlarmTimes"];
            }
            else {
                //Save string of double single time into singleTimeString
                strDbleSingleTime = [NSString stringWithFormat:@"%f",sqlite3_column_double(statement, 9)];
                [dictAlarmDetails setValue:strDbleSingleTime forKey:@"alarmTimes"];
                alarmnum = @"1 alarm";
                
                //Save string of single time
                strSingleTime = [[Singleton sharedSingleton] hourAMPM:strSingleTime];
                [dictAlarmDetails setValue:strSingleTime forKey:@"strAlarmTimes"];
            }
            
            // See if there is an alarm on
            if (sqlite3_column_int(statement, 8) == 1) {
                alarmIsSet = 1;
            }
            
            [dictAlarmDetails setValue:[NSString stringWithFormat:@"%i", sqlite3_column_int(statement, 8)] forKey:@"alarmOn"];
            [dictAlarmDetails setValue:[NSString stringWithFormat:@"%i", sqlite3_column_int(statement, 10)] forKey:@"rowNum"];
            [dictAlarmDetails setValue:alarmLabel forKey:@"alarmName"];
            [dictAlarmDetails setValue:alarmnum forKey:@"alarmNum"];
            [dictAlarmDetails setValue:soundLabel forKey:@"alarmSound"];
            [dictAlarmDetails setValue:soundLength forKey:@"soundLength"];
            [dictAlarmDetails setValue:strSnooze forKey:@"alarmSnooze"];
            //NSLog(@"dict: %@", dictAlarmDetails);
            
            // Add dictionary to array of alarms.
            [arrAlarms addObject:dictAlarmDetails];
            
            //NSLog(@"alarmON test: %@",[dictAlarmDetails valueForKey:@"alarmOn"]);
        }
        sqlite3_finalize(statement);
    }
    
    [tabl reloadData];
    
    //NSLog(@"array alarms: %@",arrAlarms);
    
    arrRandAlarms = 0;
    arrRandAlarms = [[NSMutableArray alloc]init]; //initialize the array
    
    arrRemainingRandAlarms = 0;
    arrRemainingRandAlarms = [[NSMutableArray alloc]init]; //initialize the array
    
    arrShortRandAlarmString = 0;
    arrShortRandAlarmString = [[NSMutableArray alloc]init]; //initialize the array
    
    arrDictSingleAlarm = 0;
    arrDictSingleAlarm = [[NSMutableArray alloc]init]; //initialize the array
    
    // Make the notifications.
    application4 = [UIApplication sharedApplication];
    oldNotifications = [application4 scheduledLocalNotifications];
    
    // Clear out old notifications before scheduling new ones.
    if ([oldNotifications count] > 0) {
        [application4 cancelAllLocalNotifications];
    }
    
    //NSLog(@"arr alarms - %@", arrAlarms);
    
    // If a multiple alarm just sounded, then we only want to get the existing mutliple alarms once.
    int existingMultipleAlarmCount = 0;
    
    // Set bool on so we make arrDictSingleAlarm empty in NSUserDefaults unless a single alarm is set.
    singleAlarmSET = NO;
    
    // Set bool on so we make arrRandAlarm and arrRemainingRandAlarms empty in NSUserDefaults unless random alarms are set.
    randomAlarmsSET = NO;
    
    // Loop through array to see which alarms are set to on.
    for (int i=0; i<[arrAlarms count]; i++) {
        
        dictSetSingleAlarms = 0;
        dictSetSingleAlarms = [[NSMutableDictionary alloc]init]; //initialize the dictionary
        
        dictNotification = 0;
        dictNotification = [[NSDictionary alloc] init];
        
        dictAlarmDetails = 0;
        dictAlarmDetails = [[NSMutableDictionary alloc]init]; //initialize the dictionary
        dictAlarmDetails = [arrAlarms objectAtIndex:i];
        
        // Get the alarmON value in each row
        strAlarmON = [dictAlarmDetails valueForKey:@"alarmOn"];
        //NSLog(@"alarmON string chosen - %@", strAlarmON);
        alarmON = [strAlarmON intValue];
        
        // Get value for snoozeAfterAlarm
        snoozeAfterAlarm = [[[NSUserDefaults standardUserDefaults]objectForKey:
                            @"snoozeSetToRun"] intValue];
        //NSLog(@"snoozeAfterAlarm: %i", snoozeAfterAlarm);
        
        // If the alarm is set to ON.
        if (alarmON == 1) {
            
            //NSLog(@"alarmON  inside if - %@", strAlarmON);
            
            // Get now
            now = [NSDate date];
            doubleNow = [now timeIntervalSince1970];
            
            // Sound.
            soundLabel = [dictAlarmDetails valueForKey:@"alarmSound"];
            //NSLog(@"sound in app background:  %@", soundLabel);
            
            // Alarm Title.
            alarmLabel = [dictAlarmDetails valueForKey:@"alarmName"];
            //NSLog(@"sound in app background:  %@", alarmLabel);
            
            // Sound file length.
            floatSoundLength = [[dictAlarmDetails valueForKey:@"soundLength"] floatValue];
            floatSoundLength = floatSoundLength * 100;
            //NSLog(@"sound length in seconds: %f", floatSoundLength);
            
            // If there was an existing snooze alarm that the user wants to sound.
            if (snoozeAfterAlarm == 1) {
                
                existingSnoozeTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"existingsnoozetime"];
                //NSLog(@"existing snooze time in if: %@",existingSnoozeTime);
                
                double dblTimeAlarm = [existingSnoozeTime doubleValue];
                dateTime = [NSDate dateWithTimeIntervalSince1970:dblTimeAlarm];
                //NSLog(@"ns date existing snooze alarm GMT: %@", dateTime);
                
                // Call Notifications method.
                dictNotification = [NSDictionary dictionaryWithObjectsAndKeys:
                                    dateTime, @"time",
                                    soundLabel,@"soundTitle",
                                    alarmLabel,@"alarmLabel",
                                    [dictAlarmDetails valueForKey:@"soundLength"],@"soundLength",
                                    nil];
                
                //NSLog(@"dictNotification: %@",dictNotification);
                [arrNotifications addObject:dictNotification];
                
                // Put the snooze boolen back to '0' so we can re-set all alarms after it sounds.
                [defaults setObject:@"0" forKey:@"snoozeSetToRun"];
                //NSLog(@"new snoozeAfterAlarm after the snooze alarm has been set: %i", [[[NSUserDefaults standardUserDefaults]objectForKey:@"snoozeSetToRun"] intValue]);
            }
            else {
                // Time chosen.
                timeAlarm = [dictAlarmDetails valueForKey:@"alarmTimes"];
                
                // Single Alarm.
                if([timeAlarm rangeOfString:@"-"].location == NSNotFound) {
                    
                    //NSLog(@"This is a Single Alarm as the string doesn't include -");
                    
                    // Set bool on so we don't make arrDictSingleAlarm empty in NSUserDefaults.
                    singleAlarmSET = YES;
                    
                    //NSLog(@"doubleNow: %f", doubleNow);
                    
                    // Time chosen.
                    //NSLog(@"single time chosen in app background  %@", timeAlarm);
                    double dblTimeAlarm = [timeAlarm doubleValue];
                    
                    // Get singleTime today.
                    // Continuous loop is necessary if now is greater than one day ago
                    for (;;) {
                        //NSLog(@"in for infinite loop to get dblTimeAlarm");
                        
                        // Add an extra day to dblTimeAlarm if dblTimeAlarm is less than doubleNow.
                        if (dblTimeAlarm < doubleNow) {
                            dblTimeAlarm = dblTimeAlarm + (24 * 60 * 60);
                            //NSLog(@"dblTimeAlarm in if: %f", dblTimeAlarm);
                        }
                        else{
                            //NSLog(@"dblTimeAlarm is greater then doubleNow");
                            break;
                        }
                    }
                    //NSLog(@"dblTimeAlarm: %f", dblTimeAlarm);
                    
                    timeAlarm = [NSString stringWithFormat:@"%f",dblTimeAlarm];
                    
                    // Set a single alarm unless the alarm has just gone off.
                    if(dblTimeAlarm > (doubleNow + 60)) {
                        // Add alarm to array so we know if it caused the 'App Did Enter Foreground' so we can give alert to close App to start 'Snooze' alarm.
                        [dictSetSingleAlarms setValue:timeAlarm forKey:@"singleTimeAlarm"];
                        [dictSetSingleAlarms setValue:[dictAlarmDetails valueForKey:@"alarmSnooze"] forKey:@"snoozeValue"];
                        //NSLog(@"set in dictSetSingleAlarms: %@",dictSetSingleAlarms);
                        
                        dateTime = [NSDate dateWithTimeIntervalSince1970:dblTimeAlarm];
                        
                        //NSLog(@"ns date time alarm GMT: %@", dateTime);                            
                        //NSLog(@"sound: %@", soundLabel);
                        
                        dictNotification = [NSDictionary dictionaryWithObjectsAndKeys:
                                            dateTime, @"time",
                                            soundLabel,@"soundTitle",
                                            alarmLabel,@"alarmLabel",
                                            [dictAlarmDetails valueForKey:@"soundLength"],@"soundLength",
                                            nil];
                        
                        //NSLog(@"dictNotification: %@",dictNotification);
                        [arrNotifications addObject:dictNotification];
                        
                        // Get the snooze
                        strSnooze = [dictAlarmDetails valueForKey:@"alarmSnooze"];
                        snoozeSaved = [strSnooze intValue];
                        if (snoozeSaved == 1) {
                            
                            //NSLog(@"Double time: %f",dblTimeAlarm);
                            doubleTime = dblTimeAlarm + (9 * 60);
                            //NSLog(@"Double time: %f",doubleTime);
                            
                            dateTime = [NSDate dateWithTimeIntervalSince1970:doubleTime];
                            //NSLog(@"ns date snooze alarm GMT: %@", dateTime);
                            
                            snoozeAlarmComplete = [NSString stringWithFormat:@"%f",doubleTime];
                            //NSLog(@"snoozeAlarmComplete: %@", snoozeAlarmComplete);
                            
                            // Save snooze time in dict alarm details.
                            [dictSetSingleAlarms setValue:snoozeAlarmComplete forKey:@"snoozetime"];
                            
                            dictNotification = [NSDictionary dictionaryWithObjectsAndKeys:
                                                dateTime, @"time",
                                                soundLabel,@"soundTitle",
                                                alarmLabel,@"alarmLabel",
                                                [dictAlarmDetails valueForKey:@"soundLength"],@"soundLength",
                                                nil];
                            
                            //NSLog(@"dictNotification: %@",dictNotification);
                            [arrNotifications addObject:dictNotification];
                            
                        }
                        // Add alarm to array so we know if it caused the 'App Did Enter Foreground' so we can give alert to close App to start 'Snooze' alarm.
                        [arrDictSingleAlarm addObject:dictSetSingleAlarms];
                    }
                }
                // Multiple Alarms
                else {
                    //NSLog(@"Multiple Alarms includes -");
                    
                    // Set bool on so we don't make arrRandAlarm and arrRemainingRandAlarms empty in NSUserDefaults.
                    randomAlarmsSET = YES;
                    randomAlarmSounded = [[[NSUserDefaults standardUserDefaults] objectForKey:@"randomAlarmSounded"] intValue];
                    
                    // If a random alarm has NOT just sounded, then create random alarms array.
                    if (randomAlarmSounded == 0) {
                        
                        //NSLog(@"Random alarm not just sounded: %i", randomAlarmSounded);
                        //NSLog(@"time chosen in app background  %@", timeAlarm);
                        
                        // Split string to get start and end times
                        NSArray *splite = [timeAlarm componentsSeparatedByString:@" - "];
                        strStart = [splite objectAtIndex:0];
                        strEnd = [splite objectAtIndex:1];
                        
                        int intStart = [strStart intValue];
                        int intEnd = [strEnd intValue];
                        //NSLog(@"int start %i", intStart);
                        //NSLog(@"int end: %i", intEnd);
                        //NSLog(@"double now: %f", doubleNow);
                        
                        // Make intEnd a day later if it is after intStart.
                        if (intEnd <= intStart) {
                            intEnd = intEnd + (24 * 60 * 60);
                            //NSLog(@"int end in if %i", intEnd);
                        }
                        
                        // Get intStart and intEnd relevant for today.
                        // Continuous loop is necessary if now is greater than one day ago
                        for (;;) {
                            //NSLog(@"in for infinite loop to get intStart and intEnd");
                            
                            // Add an extra day to intStart if intStart is less than (doubleNow - five minutes).
                            if (intStart < (doubleNow - 300)) {
                                intStart = intStart + (24 * 60 * 60);
                                intEnd = intEnd + (24 * 60 * 60);
                                //NSLog(@"int start in if: %i", intStart);
                                //NSLog(@"int end in if %i", intEnd);
                                break;
                            }
                            else if( (intStart < doubleNow) && (intStart > (doubleNow - 300)) ){
                                intStart = doubleNow;
                                if (intEnd <= intStart) {
                                    intEnd = intEnd + (24 * 60 * 60);
                                }
                                break;
                            }
                            else{
                                //NSLog(@"int start is greater then doubleNow");
                                break;
                            }
                        }
                        
                        // Set up formatter ..... testing
                        dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setLocale:[NSLocale systemLocale]];
                        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                        dateFormatter.dateFormat=@"YYYY/MM/dd HH:mm";

                        // Get the number of random alarms value.
                        numalarms = [[dictAlarmDetails valueForKey:@"alarmNum"] intValue];
                        //NSLog(@"Num alarms: %i", numalarms);
                        
                        // Get the random alarms.
                        for (int i=0; i < numalarms; i++) { 
                            
                            // Get a random alarm that hasn't already been included in the array of random alarms with the same time (in minute).
                            for (;;) {
                                //NSLog(@"in for infinite loop");
                                int intRandAlarm = [self getRandomAlarm:intStart endStri:intEnd];
                                randAlarm = [NSString stringWithFormat:@"%i",intRandAlarm];
                                //NSLog(@"rand Alarm: %@", randAlarm);
                                
                                //NSLog(@"int end added extra day: %i", intRandAlarm);
                                double dblRandAlarm = intRandAlarm;
                                NSDate *dateRanAla = [NSDate dateWithTimeIntervalSince1970:dblRandAlarm];
                                //NSLog(@"date time next day for intEnd: %@", dateRanAla);
                                
                                // Set up formatter
                                dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setLocale:[NSLocale systemLocale]]; 
                                [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]]; 
                                dateFormatter.dateFormat=@"YYYY/MM/dd HH:mm"; 
                                
                                NSString *strRanA = [dateFormatter stringFromDate:dateRanAla];
                                //NSLog(@"str ran a: %@", strRanA);
                                
                                // Get now string
                                NSString *nowString = [dateFormatter stringFromDate:now]; 
                                //NSLog(@"now string: %@", nowString);
                                
                                if ( (![arrShortRandAlarmString containsObject:strRanA]) && (![strRanA isEqualToString:nowString]) ) {
                                    [arrShortRandAlarmString addObject:strRanA];
                                    //NSLog(@"in infinite loop array : %@", arrShortRandAlarmString);
                                    break;
                                }
                            }
                            //NSLog(@"arr short rand alarm string: %@",arrShortRandAlarmString);
                            
                            [arrRandAlarms addObject:randAlarm];
                            
                            double dblTimeAlarm = [randAlarm doubleValue];
                            dateTime = [NSDate dateWithTimeIntervalSince1970:dblTimeAlarm];
                            //NSLog(@"ns date time alarm GMT: %@", dateTime); 
                            
                            dictNotification = [NSDictionary dictionaryWithObjectsAndKeys:
                                                              dateTime, @"time",
                                                              soundLabel,@"soundTitle",
                                                              alarmLabel,@"alarmLabel",
                                                              [dictAlarmDetails valueForKey:@"soundLength"],@"soundLength",
                                                              nil];
                            
                            //NSLog(@"dictNotification: %@",dictNotification);
                            [arrNotifications addObject:dictNotification];
                        }
                        //NSLog(@"arr rand alarm: %@", arrRandAlarms);
                    }
                    // A random alarm just sounded, so use existing random alarms array.
                    else {
                        // Only loop through existing rand alarms (newArrRandAlarms) to create arrRandAlarms.
                        if (existingMultipleAlarmCount < 1) {
                            
                            existingMultipleAlarmCount++;
                            arrRemainingRandAlarms = [[NSUserDefaults standardUserDefaults]objectForKey:@"remainingrandomalarms"];
                            
                            //NSLog(@"Random alarm just sounded: %i", randomAlarmSounded);
                            //NSLog(@"arr rand alarms beg: %@", arrRandAlarms);
                            //NSLog(@"arr remaining rand alarms beg: %@", arrRemainingRandAlarms);
                            
                            for (int i=0; i < [arrRemainingRandAlarms count]; i++) {
                                
                                [arrRandAlarms addObject:[arrRemainingRandAlarms objectAtIndex:i]];
                                
                                double dblTimeAlarm = [[arrRemainingRandAlarms objectAtIndex:i] doubleValue];
                                dateTime = [NSDate dateWithTimeIntervalSince1970:dblTimeAlarm];
                                //NSLog(@"ns date time alarm GMT of remaining rand alarm: %@", dateTime);
                                
                                dictNotification = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                  dateTime, @"time",
                                                                  soundLabel,@"soundTitle",
                                                                  alarmLabel,@"alarmLabel",
                                                                  [dictAlarmDetails valueForKey:@"soundLength"],@"soundLength",
                                                                  nil];
                                
                                //NSLog(@"dictNotification: %@",dictNotification);
                                [arrNotifications addObject:dictNotification];
                            }
                        }
                        //NSLog(@"arr rand alarms end: %@", arrRandAlarms);
                    }
                }
            }
        }
    }
    
    // Make arrRandAlarm and arrRemainingRandAlarms empty in NSUserDefaults.
    if (randomAlarmsSET == NO) {
        [arrRemainingRandAlarms removeAllObjects];
        [arrRandAlarms removeAllObjects];
        [defaults setObject:arrRemainingRandAlarms forKey:@"remainingrandomalarms"];
        [defaults setObject:arrRandAlarms forKey:@"newrandomalarms"];
    }
    else {
        [defaults setObject:arrRemainingRandAlarms forKey:@"remainingrandomalarms"];
        [defaults setObject:arrRandAlarms forKey:@"newrandomalarms"];
    }
    
    // Make the arrRandAlarm arrRemainingRandAlarms empty in NSUserDefaults.
    if (singleAlarmSET == NO) {
        // Save array of single alarms in NSUserDefaults.
        [arrDictSingleAlarm removeAllObjects];
        [defaults setObject:arrDictSingleAlarm forKey:@"arraydictsinglealarm"];
    }
    else {
        // Save array of single alarms in NSUserDefaults.
        [defaults setObject:arrDictSingleAlarm forKey:@"arraydictsinglealarm"];
    }
    
    // Save array of notifications in NSUserDefaults.
    [defaults setObject:arrNotifications forKey:@"arrayNot"];
    [defaults synchronize];
    
//    NSLog(@"At end of createArrayNotifications method, arrNotification: %@",arrNotifications);
    
    [self setAlarms];
}

-(void) setAlarms {
    // for testing
//    NSString *testString = [[NSString alloc] initWithString:@""];
//    for (int i=0; i < [arrNotifications count]; i++) {
//        
//        dictNotification = 0;
//        dictNotification = [[NSDictionary alloc] init];
//        
//        dictNotification = [arrNotifications objectAtIndex:i];
//        dateFormatterTest = [[NSDateFormatter alloc] init];
//        [dateFormatterTest setLocale:[NSLocale systemLocale]];
//        [dateFormatterTest setTimeZone:[NSTimeZone systemTimeZone]];
//        dateFormatterTest.dateFormat=@"MM/dd HH:mm";
//        NSString *testi = [NSString stringWithFormat:@"%@ ",[dateFormatterTest stringFromDate:[dictNotification valueForKey:@"time"]]];
//        testString = [testString stringByAppendingString:testi];
//        
//    }
//    NSLog(@"testing: %@",testString);
    
    // Clear out old notifications before scheduling new ones.
    application4 = [UIApplication sharedApplication];
    oldNotifications = [application4 scheduledLocalNotifications];
    if ([oldNotifications count] > 0) {
        [application4 cancelAllLocalNotifications];
    }
    
    arrNotifications = 0;
    arrNotifications = [[NSMutableArray alloc]init]; //initialize the array
    
    arrNotifications = [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayNot"];
    
    for (int i=0; i < [arrNotifications count]; i++) {
        
        dictNotification = 0;
        dictNotification = [[NSDictionary alloc] init];
        
        dictNotification = [arrNotifications objectAtIndex:i];
        
        //NSLog(@"dict notification: %@", dictNotification);
        
        // Date Time.
        dateTime = [dictNotification valueForKey:@"time"];
        //NSLog(@"dateTime in app background:  %@", dateTime);
        
        // Sound.
        soundLabel = [dictNotification valueForKey:@"soundTitle"];
        //NSLog(@"sound in app background:  %@", soundLabel);
        
        // Alarm Title.
        alarmLabel = [dictNotification valueForKey:@"alarmLabel"];
        //NSLog(@"sound in app background:  %@", alarmLabel);
        
        // Sound file length.
        floatSoundLength = [[dictNotification valueForKey:@"soundLength"] floatValue];
        floatSoundLength = floatSoundLength * 100;
        //NSLog(@"sound length in seconds: %f", floatSoundLength);
        
        // Create notification.
        [self setNotification:dateTime soundLab:soundLabel alarmLabel:alarmLabel lengthSound:floatSoundLength];
    }
    
    [Utils hideHUD:nil];
    
    //NSLog(@"fromAppEnterForeground: %i",fromAppEnterForeground);
    
    if( ([arrAlarms count] > 0) && (fromAppEnterForeground == 0) && (alarmIsSet == 1) ) {
        //Alert view message.
        message = [[NSString alloc] initWithFormat:
                   @"Close the app to start the alarm.\n\n If you turn your phone off completely, open up this App again and click the 'Save' button once in the Edit Alarm view to reset all alarms."];
        
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
}


-(void)applicationDidEnterBackground:(NSNotification *)notification {
    //NSLog(@"arr notifications in background");
}

-(int)getRandomAlarm:(int)startInt endStri:(int)endInt {
    
    //NSLog(@"inside get random alarms.");
    // Get a random number
    int rand = (arc4random()%(endInt-startInt))+startInt;
    //NSLog(@"int rand: %i", rand);
    return rand;
}

-(void)applicationWillEnterForeground:(NSNotification *)notification {
    //NSLog(@"App will enter foreground so start timer again");
    
    fromAppEnterForeground = 1;
    
    // If there are existing alarms.
    if ( ([[[NSUserDefaults standardUserDefaults] objectForKey:@"newrandomalarms"] count] > 0) || ([[[NSUserDefaults standardUserDefaults] objectForKey:@"arraydictsinglealarm"] count] > 0) ) {
        [Utils startActivityIndicator:@"Setting alarms ..."];
    }
    
    // get previous notifications
    [self performSelector:@selector(getPreviousNotifications) withObject:self afterDelay:1.0 ];
}

-(void) getPreviousNotifications {
    application4 = [UIApplication sharedApplication];
    oldNotifications = [application4 scheduledLocalNotifications];
    
    // Clear out old notifications before scheduling new ones.
    if ([oldNotifications count] > 0) {
        [application4 cancelAllLocalNotifications];
    }
    
    // User wants the snooze to sound after the alarm has already sounded.
    existingSnoozeTime = @"";
    
    // Save snooze in NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:existingSnoozeTime forKey:@"existingsnoozetime"];
    //NSLog(@"existing snooze time in ns user defaults: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"existingsnoozetime"]);
    
    arrRemainingRandAlarms = 0;
    arrRemainingRandAlarms = [[NSMutableArray alloc]init]; //initialize the array
    
    arrDictSingleAlarm = 0;
    arrDictSingleAlarm = [[NSMutableArray alloc]init]; //initialize the array
    
    arrRandAlarms = 0;
    arrRandAlarms = [[NSMutableArray alloc]init]; //initialize the array
    
    arrRandAlarms = [[NSUserDefaults standardUserDefaults] objectForKey:@"newrandomalarms"];
//    NSLog(@"arr rand alarms in foreground: %@",arrRandAlarms);
//    NSLog(@"array remaining alarms in foreground: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"remainingrandomalarms"]);
    
    // Get now
    now = [NSDate date];
    doubleNow = [now timeIntervalSince1970];
    
    for (int i=0; i < [arrRandAlarms count]; i++) {
        
        NSString *singleStr = [arrRandAlarms objectAtIndex:i];
//        NSLog(@"single rand alarm date string: %@", singleStr);
//        NSLog(@"doubleNow: %f", doubleNow);
        double dblTimeAlarm = [singleStr doubleValue];
        double dblTimeAlarm2 = dblTimeAlarm + 3600; // 1 hour extra
//        NSLog(@"dblTimeAlarm: %f", dblTimeAlarm);
//        NSLog(@"dblTimeAlarm2: %f", dblTimeAlarm2);
        
        // // If the random alarm went off in last hour, set random alarm sounded and don't include this double in array of remaining random alarms.
        if ( (dblTimeAlarm < doubleNow) && (dblTimeAlarm2 > doubleNow) ) {
//            NSLog(@"This alarm from the array just sounded.");
            [defaults setObject:@"1" forKey:@"randomAlarmSounded"];
//            NSLog(@"random alarm sounded: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"randomAlarmSounded"]);
        }
        else {
//            NSLog(@"This alarm from the array has not sounded yet so load into new array.");
            // only load the remaining alarms - not ones already sounded.
            [arrRemainingRandAlarms addObject:[arrRandAlarms objectAtIndex:i]];
        }
    }
//    NSLog(@"remaining arr rand alarms end: %@", arrRemainingRandAlarms);
    
    // Reset randomAlarmSounded if the last one just sounded.
    if([arrRandAlarms count] == 1){
//        NSLog(@"This alarm from the array just sounded and arrRandAlarms count = 1");
        [defaults setObject:@"0" forKey:@"randomAlarmSounded"];
//        NSLog(@"random alarm sounded: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"randomAlarmSounded"]);
    }
    
    // Save arrRemainingRandAlarms in NSUserDefaults so we can use this value  in AppDidEnterBackground.
    [defaults setObject:arrRemainingRandAlarms forKey:@"remainingrandomalarms"];
    
//    NSLog(@"array remaining alarms from ns user defaults: %@",[[NSUserDefaults standardUserDefaults]objectForKey:
//                                                               @"remainingrandomalarms"]);
    
    
    // Get array of single alarms from NSUserDefaults.
    arrDictSingleAlarm = [[NSUserDefaults standardUserDefaults] objectForKey:@"arraydictsinglealarm"];
//    NSLog(@"array dict single alarm in ns user defaults in foreground: %@",arrDictSingleAlarm);
    
    // If the App was opened because the single alarm went off:
    if ([arrDictSingleAlarm count] > 0) {
        
        for (int i=0; i < [arrDictSingleAlarm count]; i++) {
            
            NSDictionary *dictSingleAlarm = [arrDictSingleAlarm objectAtIndex:i];
            
            NSString *singleStr = [dictSingleAlarm objectForKey:@"singleTimeAlarm"];
            NSString *snoozeStr = [dictSingleAlarm objectForKey:@"snoozeValue"];
            
//            NSLog(@"single alarm date string: %@", singleStr);
//            NSLog(@"single alarm snooze value: %@", snoozeStr);
            
//            NSLog(@"doubleNow: %f", doubleNow);
            double dblTimeAlarm = [singleStr doubleValue];
            
            
            double dblTimeAlarm2 = dblTimeAlarm + 600; // 10 minutes.
//            NSLog(@"dblTimeAlarm: %f", dblTimeAlarm);
//            NSLog(@"dblTimeAlarm2: %f", dblTimeAlarm2);
            
            existingSnoozeTime = [dictSingleAlarm objectForKey:@"snoozetime"];
//            NSLog(@"single alarm snooze time: %@", existingSnoozeTime);
            
            // If the single alarm just went off, set the snooze time.
            if ( (dblTimeAlarm < doubleNow) && (dblTimeAlarm2 > doubleNow) && ([snoozeStr intValue] == 1) ) {
//                NSLog(@"inside if statement for single time in app foreground");
                
                // User wants the snooze to sound after the alarm has already sounded.
                [defaults setObject:@"1" forKey:@"snoozeSetToRun"];
                
                // Save snooze time in NSUserDefaults
                [defaults setObject:existingSnoozeTime forKey:@"existingsnoozetime"];
                
//                NSLog(@"existing snooze time in ns user defaults: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"existingsnoozetime"]);
            }
            else {
//                NSLog(@"inside else statement for single time in app foreground");
                // User doesn't want the snooze to sound after the alarm has already sounded.
                [defaults setObject:@"0" forKey:@"snoozeSetToRun"];
            }
            
            // If the snooze time just went off then we need to reset 'snoozeSetToRun to '0'.
            double snoozeTime = [existingSnoozeTime doubleValue];
//            NSLog(@"snoozeTime: %f", snoozeTime);
            
            // If you slept through the alarm, then set snoozeToRun to 0 so all alarms will be reset.
            if (snoozeTime < doubleNow) {
//                NSLog(@"inside if statement for snooze time in app foreground");
                
                [defaults setObject:@"0" forKey:@"snoozeSetToRun"];
//                NSLog(@"snoozeSetToRun in ns user defaults: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"snoozeSetToRun"]);
            }
        }
    }
    
    [defaults synchronize];
    
    // create array of notifications of alarms.
    [self createArrayNotifications];
    
}

-(void)setNotification:(NSDate *)timedate soundLab:(NSString *)titleSound alarmLabel:(NSString *)titleName lengthSound:(float)floatLengthSound {
    
    // Create 25 notifications of the alarm running 3 seconds after each sound ends.
    for (int i=0; i<26; i++) {
        
        reminder = [[[UILocalNotification alloc] init] autorelease];
        if(reminder) {
            reminder.fireDate = timedate;
            reminder.timeZone = [NSTimeZone defaultTimeZone];
            reminder.repeatInterval = 0;
            reminder.soundName = titleSound;
            reminder.alertBody = [NSString stringWithFormat:@"%@%@", titleName, @". Tap to stop alarm."];
            [application4 scheduleLocalNotification:reminder];
        }
        
        doubleTime = [timedate timeIntervalSince1970];
        doubleTime = doubleTime + floatLengthSound + 3;
        
        timedate = [NSDate dateWithTimeIntervalSince1970:doubleTime];
        //NSLog(@"ns date time alarm GMT: %@", timedate);
    }
}


-(void)applicationWillTerminate:(NSNotification *)notification {
    
    sqlite3_close(database);
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrAlarms count];
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
    
    dictAlarmDetails = [arrAlarms objectAtIndex:indexPath.row];
    
	// Set up the cell
    //cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:bgImage]] autorelease];
    cell.textLabel.text = [dictAlarmDetails valueForKey:@"strAlarmTimes"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:19.0];
    cell.textLabel.shadowColor = [UIColor whiteColor];
    cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@", [dictAlarmDetails valueForKey:@"alarmName"], [dictAlarmDetails valueForKey:@"alarmNum"]];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.shadowColor = [UIColor whiteColor];
    cell.detailTextLabel.shadowOffset = CGSizeMake(0.0, 0.75);
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    
    UISwitch *choose = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = choose;
    
    // Put yes if they have been set on previously
    if([[dictAlarmDetails valueForKey:@"alarmOn"] intValue] == 1) {
        [choose setOn:YES animated:NO];
    }
    else {
        [choose setOn:NO animated:NO];
    }
    
    [choose addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [choose release];
    
	return cell;
}

-(void) switchChanged:(id)sender {
    
    fromAppEnterForeground = 0;

    // If selected a row, then existing random alarms and snooze should be ignored.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"0" forKey:@"randomAlarmSounded"];
//    NSLog(@"random alarm sounded: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"randomAlarmSounded"]);
    
    [defaults setObject:@"0" forKey:@"snoozeSetToRun"];
    [defaults synchronize];
    
    UISwitch *switchInCell = (UISwitch *)sender;
    UITableViewCell *cell = (UITableViewCell*)switchInCell.superview.superview;
    NSIndexPath *indexPath = [tabl indexPathForCell:cell];
//    NSLog(@"index path row of switch changed: %li", (long)[indexPath row]); 
    
    NSInteger row = [indexPath row];
//    NSLog(@"row clicked - indexPath - %li",(long)row);
    int count = (int)[arrAlarms count];
	
	for (int i=0; i<count; i++) {
		if(row == i)
		{
            dictAlarmDetails = [arrAlarms objectAtIndex:row];
            strRow = [dictAlarmDetails valueForKey:@"rowNum"];
//            NSLog(@"db row string chosen - %@", strRow);
            rownumber = [strRow intValue];
//            NSLog(@"row number in db is  %i", rownumber);
            
            // Get the alarmON value in db/arrAlarmON
            strAlarmON = [dictAlarmDetails valueForKey:@"alarmOn"];
            //NSLog(@"alarmON string chosen - %@", strAlarmON);
            alarmON = [strAlarmON intValue];
            
            //NSLog(@"arr AlarmON before switch - %@", [dictAlarmDetails valueForKey:@"alarmOn"]);
            // Switch the alarmON value.
            if(alarmON == 1) {
                alarmON = 0;
                strAlarmON = [NSString stringWithFormat:@"%i",alarmON];
                [dictAlarmDetails setValue:strAlarmON forKey:@"alarmOn"];
                
                char *update = "update alarms set alarmon = ? where row = ?;";    
                sqlite3_stmt *stmt;
                if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK){
                    sqlite3_bind_int(stmt, 1, alarmON);
                    sqlite3_bind_int(stmt, 2, rownumber);
                    
                    //NSLog(@"in sql stmt");
                }
                
                if(sqlite3_step(stmt) != SQLITE_DONE)
                    NSLog(@"statement failed");
                sqlite3_finalize(stmt);
            }
            else {
                alarmON = 1;
                strAlarmON = [NSString stringWithFormat:@"%i",alarmON];
                [dictAlarmDetails setValue:strAlarmON forKey:@"alarmOn"];
                
                //NSLog(@"alarmON after switch - %i", alarmON);
                //NSLog(@"arr AlarmON after switch - %@", [dictAlarmDetails valueForKey:@"alarmOn"]);
                
                char *update = "update alarms set alarmon = ? where row = ?;";    
                sqlite3_stmt *stmt;
                if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK){
                    sqlite3_bind_int(stmt, 1, alarmON);
                    sqlite3_bind_int(stmt, 2, rownumber);
                    
                    //NSLog(@"in sql stmt");
                }
                
                if(sqlite3_step(stmt) != SQLITE_DONE)
                    NSLog(@"statement failed");
                sqlite3_finalize(stmt);
            }
		}
	}
    
    [Utils startActivityIndicator:@"Setting alarms ..."];
    
    // create array of notifications of alarms.
    [self performSelector:@selector(createArrayNotifications) withObject:self afterDelay:1.0 ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    fromAppEnterForeground = 0;
	
    // If selected a row, then existing random alarms and snooze should be ignored.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"0" forKey:@"randomAlarmSounded"];
    //NSLog(@"random alarm sounded: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"randomAlarmSounded"]);

    [defaults setObject:@"0" forKey:@"snoozeSetToRun"];
    [defaults synchronize];
    
    //NSLog(@"snoozeSetToRun in table select row: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"snoozeSetToRun"]);
    
    NSInteger row = [indexPath row];
    //NSLog(@"row clicked - indexPath - %i",row);
    
    int count = (int)[arrAlarms count];
	
	for (int i=0; i<count; i++) {
		if(row == i)
		{   
            dictAlarmDetails = [arrAlarms objectAtIndex:indexPath.row];
            strRow = [dictAlarmDetails valueForKey:@"rowNum"];
            //NSLog(@"table row string chosen - %@", strRow);
            rownumber = [strRow intValue];
			
			[[Singleton sharedSingleton] setnewrownumber:rownumber];
            //NSLog(@"row number selected in FrontVC saved in Singleton is  %i", rownumber);
		}
	}
    
    int plusclicked = 0;
    [[Singleton sharedSingleton] setplusclicked:plusclicked];
    //NSLog(@"plusclicked saved in Singleton is  %i", plusclicked);
    
    //Go to edit alarm view.
    if (self.editAlarm == nil)
    {
        EditAlarmViewController *aDetail = [[EditAlarmViewController alloc] initWithNibName: @"EditAlarmViewController" bundle:[NSBundle mainBundle]];
        self.editAlarm = aDetail;
        [aDetail release];
    }
    
    MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:editAlarm animated:NO];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(BOOL)tableView:(UITableView *) tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tabl setEditing:editing animated:YES];
    [self.tabl setAllowsSelectionDuringEditing:YES];
}
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"delete button clicked");
    fromAppEnterForeground = 0;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger row = [indexPath row];
        //NSLog(@"row clicked - indexPath - %i",row);
        
        row = row+1;
        int count = (int)[arrAlarms count];
        int statusCode = 0;
        
        for (int i=1; i<count+1; i++) {
            if(row == i)
            {            
                dictAlarmDetails = [arrAlarms objectAtIndex:indexPath.row];
                strRow = [dictAlarmDetails valueForKey:@"rowNum"];
                //NSLog(@"table row string chosen - %@", strRow);
                rownumber = [strRow intValue];
                
                // Delete log in DB.
                char *update = "delete from alarms where row = ?;";
                sqlite3_stmt *stmt;
                
                if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK){
                    sqlite3_bind_int(stmt, 1, rownumber);
                    statusCode = sqlite3_step(stmt);
                }
                sqlite3_finalize(stmt);
                
                // Did we actually modify a row?
                if (sqlite3_changes(database) != 0) {
                    NSLog(@"Row changed");
                } else {
                    NSLog(@"sql status code %i", statusCode);
                    NSLog(@"DB rownumber %i", rownumber);
                    //Alert view message.
                    message = [[NSString alloc] initWithFormat:
                               @"There was a problem deleting your alarm."];
                    
                    alert = [[UIAlertView alloc] initWithTitle:nil
                                                       message:message
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
                    [alert show];
                }
                break;
            }
        }
        
        [Utils startActivityIndicator:@"Setting alarms ..."];
        
        // create array of notifications of alarms.
        [self performSelector:@selector(createArrayNotifications) withObject:self afterDelay:1.0 ];
    }
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

-(void)viewWillDisappear:(BOOL)animated {
    //NSLog(@"in view will disappear in front vc");
    self.navigationItem.leftBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
