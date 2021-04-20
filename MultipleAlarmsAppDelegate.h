//
//  MultipleAlarmsAppDelegate.h
//  MultipleAlarms
//
//  Created by Andrew on 9/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NavigationController;

@interface MultipleAlarmsAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UITabBarController *rootController;
    IBOutlet NavigationController *navController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
@property (nonatomic, retain) IBOutlet NavigationController *navController;

@end
