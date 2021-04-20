//
//  MultipleAlarmsViewController.h
//  MultipleAlarms
//
//  Created by Andrew on 1/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#define kFilename	@"randomalarms.sqlite3"

@interface MultAlarmTableCell:UITableViewCell {
    
}
@property (retain, nonatomic) IBOutlet UILabel *lblName;
@property (retain, nonatomic) IBOutlet UILabel *lblTime;

@end

@interface MultipleAlarmsViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource> {
    
    sqlite3 *database;
    IBOutlet UIDatePicker *pickTime;
    IBOutlet UITextField *alarmnum;
    IBOutlet UITableView *tableTimes;
    IBOutlet MultAlarmTableCell *multAlarmTableCell;
    UILabel *labelTop;
    NSArray *tableData;
    NSMutableDictionary *arrTimes;
    NSString *query;
    int newrownumber;
    NSDateFormatter *formatter1;
    NSDate *timeSelectedStart;
    NSString *strSelectedStart;
    NSDate *timeSelectedEnd;
    NSString *strSelectedEnd;
    NSDate *now;
    BOOL viewJustAppeared;
    BOOL firstRowSelected;
    
    char *timeStartChosen;
    NSString *strStart;
    char *timeEndChosen;
    NSString *strEnd;
    NSString *timeRange;
    int lastRowDatabase;
    int numAlarms;
    NSString *message;
	UIAlertView *alert;
    
    NSString *strDblStart;
    NSString *strDblEnd;
}
@property (nonatomic, retain) UIDatePicker *pickTime;
@property (nonatomic, retain) UITextField *alarmnum;
@property (nonatomic, retain) UITableView *tableTimes;

@end
