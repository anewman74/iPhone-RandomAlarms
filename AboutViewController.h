//
//  AboutViewController.h
//  MultipleAlarms
//
//  Created by Andrew on 9/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView *scrollView;
}

@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;

-(void)forumButtonPressed:(UIButton *)sender;

@end
