//
//  Singleton.h
//  MultipleAlarms
//
//  Created by Andrew on 12/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kFilename	@"randomalarms.sqlite3"


@interface Singleton : NSObject {
    NSUInteger newrownumber;
    NSUInteger plusclicked;
    NSString *strTime;
}
@property (nonatomic, assign) NSUInteger newrownumber;
@property (nonatomic, assign) NSUInteger plusclicked;

+ (Singleton*) sharedSingleton;
-(NSString *)dataFilePath;

- (NSUInteger) getnewrownumber;
- (void) setnewrownumber:(NSUInteger)value;

- (NSUInteger) getplusclicked;
- (void) setplusclicked:(NSUInteger)value;

-(NSString *) hourAMPM: (NSString *)time;
-(NSString *) hour24: (NSString *)time;
-(NSString *) tomorrowDate: (NSString *)time;

@end