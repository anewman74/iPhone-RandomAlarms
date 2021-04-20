//
//  FrontViewController.h
//  MultipleAlarms
//
//  Created by Andrew on 9/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditAlarmViewController;
#import <sqlite3.h>
#define kFilename	@"randomalarms.sqlite3"


@interface FrontViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    EditAlarmViewController *editAlarm;
    IBOutlet UITableView *tabl;
    sqlite3 *database;
    NSString *createSQL;
    NSString *query;
    NSMutableArray *arrAlarms;
    NSDictionary *dictAlarmDetails;
    NSMutableArray *arrRandAlarms;
    NSMutableArray *arrShortRandAlarmString;
    NSMutableArray *arrRemainingRandAlarms;
    NSMutableArray *arrNotifications;
    NSDictionary *dictNotification;
    NSString *strRow;
    int rownumber;
    
    int newrownumber;
    char *alarmName;
    NSString *alarmLabel;
    NSString *nameCheck;
    NSString *soundLabel;
    NSString *soundLength;
    float floatSoundLength;
    int snoozeSaved;
    NSString *strSnooze;
    int numalarms;
    NSString *alarmnum;
    char *singleTimeChosen;
    NSDate *dateTimeChosen;
    NSString *strSingleTime;
    NSString *strDbleSingleTime;
    NSMutableDictionary *dictSetSingleAlarms;
    NSMutableArray *arrDictSingleAlarm;
    char *timeStartChosen;
    NSString *strStart;
    NSString *strStartStraight;
    NSString *strStartHr;
    NSString *strStartMin;
    char *timeEndChosen;
    NSString *strEnd;
    NSString *strEndStraight;
    NSString *strEndHr;
    NSString *strEndMin;
    NSString *timeRange;
    NSString *randAlarm;
    NSString *randHr;
    NSString *randMin;
    int intRandMin;
    NSString *timeAlarm;
    NSString *timeAlarmComplete;
    float timeSnoo;
    NSString *timeSnooze;
    NSString *snoozeAlarmComplete;
    UITableViewCell *lastClickedCell;
    NSString *title;
    NSString *message;
	UIAlertView *alert;
    NSString *strAlarmON;
    int alarmON;
    
    UIApplication *application;
    UIApplication *application2;
    UIApplication *application3;
    UIApplication *application4;
    NSArray *oldNotifications;
    UILocalNotification *reminder;
    UILocalNotification *reminder2;
    
    NSDate *dateTime;
    double doubleTime;
    NSDate *now;
    double doubleNow;
    NSString *nowStr;
    NSString *nowYearStr;
    NSString *nowYearStrTomorrow;
    NSString *strNowStraight;
    NSString *strNowHr;
    NSString *strNowMin;
    NSString *nowStrStraightMin;
    NSDateFormatter *dateFormatter;
    NSDateFormatter *dateFormatterTest;
    int randomAlarmSounded;
    BOOL randomAlarmsSET;
    BOOL singleAlarmSET;
    int fromAppEnterForeground;
    int alarmIsSet;
    NSString *existingSnoozeTime;
    BOOL snoozeAfterAlarm;
}

@property (nonatomic, retain) EditAlarmViewController *editAlarm;
@property (nonatomic,retain) UITableView *tabl;

-(void)createArrayNotifications;
-(void)applicationWillTerminate:(NSNotification *)notification;
-(void)applicationDidEnterBackground:(NSNotification *)notification;
-(void)applicationWillEnterForeground:(NSNotification *)notification;
-(void)setNotification:(NSDate *)timedate soundLab:(NSString *)titleSound alarmLabel:(NSString *)titleName lengthSound:(float)floatLengthSound;
-(int)getRandomAlarm:(int)startString endStri:(int)endString;

@end
