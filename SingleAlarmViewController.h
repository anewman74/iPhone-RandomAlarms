//
//  SingleAlarmViewController.h
//  MultipleAlarms
//
//  Created by Andrew on 1/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#define kFilename	@"randomalarms.sqlite3"

@interface SingleAlarmViewController : UIViewController {
    
    sqlite3 *database;
    IBOutlet UIDatePicker *datePicker;
    NSString *query;
    int newrownumber;
    NSDateFormatter *formatter1;
	NSDateFormatter *formatter2;
    NSDate *dateSelectedTime;
    NSDate *now;
    NSString *strSelectedTime;
}
@property (nonatomic, retain) UIDatePicker *datePicker;

@end
