//
//  EditAlarmViewController.h
//  MultipleAlarms
//
//  Created by Andrew on 9/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#define kFilename	@"randomalarms.sqlite3"

@class AlarmLabelViewController;
@class SingleAlarmViewController;
@class MultipleAlarmsViewController;
@class SoundsViewController;

@interface EditAlarmViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    AlarmLabelViewController *alarmLabelVC;
    SoundsViewController *soundsVC;
    SingleAlarmViewController *singleVC;
    MultipleAlarmsViewController *multVC;

    IBOutlet UITableView *tabl;
    NSMutableArray *tableData;
    NSMutableArray *tableResult;
    sqlite3 *database;
    IBOutlet UISwitch *snoozes;
    int snoozeValue;
    NSString *query;
    int newrownumber;
    NSString *alarmLabel;
    NSString *soundLabel;
    int snoozeSaved;
    char *singleTimeChosen;
    NSString *strSingleTime;
    char *timeStartChosen;
    NSString *strStart;
    char *timeEndChosen;
    NSString *strEnd;
    NSString *timeRange;
    int lastRowDatabase;
    int numAlarms;
    NSString *strAlarms;
    NSString *message;
	UIAlertView *alert;
}
@property (nonatomic,retain) AlarmLabelViewController *alarmLabelVC;
@property (nonatomic, retain) SoundsViewController *soundsVC;
@property (nonatomic,retain) SingleAlarmViewController *singleVC;
@property (nonatomic,retain) MultipleAlarmsViewController *multVC;
@property (nonatomic,retain) UITableView *tabl;
@property (nonatomic, retain) NSMutableArray *tableData;
@property (nonatomic, retain) UISwitch *snoozes;

-(void)initializeTableData;

@end
