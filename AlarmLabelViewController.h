//
//  AlarmLabelViewController.h
//  MultipleAlarms
//
//  Created by Andrew on 1/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#define kFilename	@"randomalarms.sqlite3"

@interface AlarmLabelViewController : UIViewController <UITextFieldDelegate> {
    
    sqlite3 *database;
    IBOutlet UITextField *name;
    NSString *query;
    int newrownumber;
}
@property (nonatomic, retain) UITextField *name;

@end
