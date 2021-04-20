//
//  SoundsViewController.h
//  MultipleAlarms
//
//  Created by Andrew on 1/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#define kFilename	@"randomalarms.sqlite3"
@class AVAudioPlayer;

@interface SoundsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UITableView *tabl;
    NSMutableArray *tableData;
    NSMutableArray *soundFile;
    NSMutableArray *arrSoundLengths;
    sqlite3 *database;
    NSString *query;
    int newrownumber;
    NSString *soundName;
    NSString *sound;
    NSString *soundLength;
    AVAudioPlayer *audioPlayer;
}
@property(nonatomic,retain) AVAudioPlayer *audioPlayer;

-(void)initializeTableData;


@end
