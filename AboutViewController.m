//
//  AboutViewController.m
//  MultipleAlarms
//
//  Created by Andrew on 9/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

@synthesize scrollView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//- (id)init
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    //    self = [super init];
    if (self) {
        
    }
    return self;
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Custom initialization
    
    // Get full size of screen in pixels regardless of device (iPhone 5 or 4, etc)
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float tabBarHeight = 60.0;
    
    CGRect scrollViewFrame = CGRectMake(0, 0, screenBounds.size.width, (screenBounds.size.height - tabBarHeight));
    self.scrollView = [[[UIScrollView alloc] initWithFrame:scrollViewFrame] autorelease];
    [self.view addSubview:self.scrollView];
    scrollView.delegate = self;
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setCanCancelContentTouches:NO];
    
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.clipsToBounds = YES;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    
    UILabel *sectionTitle1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 280, 20)];
    
    UILabel *qLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 65, 280, 15)];
    UILabel *question1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 280, 35)];
    UILabel *aLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 280, 15)];
    UILabel *answer1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 147, 280, 90)];
    
    UILabel *qLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 245, 280, 15)];
    UILabel *question2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 262, 280, 30)];
    UILabel *aLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 297, 280, 15)];
    UILabel *answer2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 307, 280, 150)];
    
    UILabel *qLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 459, 280, 15)];
    UILabel *question3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 476, 280, 30)];
    UILabel *aLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 510, 280, 15)];
    UILabel *answer3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 527, 280, 75)];
    
    UILabel *qLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(20, 610, 280, 15)];
    UILabel *question4 = [[UILabel alloc] initWithFrame:CGRectMake(20, 627, 280, 30)];
    UILabel *aLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(20, 660, 280, 15)];
    UILabel *answer4 = [[UILabel alloc] initWithFrame:CGRectMake(20, 680, 280, 50)];
    
    UIButton *forumButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [forumButton setFrame:CGRectMake(20, 735, 280, 40)];
    [forumButton setTitle:@"Visit Forum" forState:UIControlStateNormal];
    
    UILabel *copyright = [[UILabel alloc] initWithFrame:CGRectMake(20, 775, 280, 15)];
    
    sectionTitle1.text = @"Frequently Asked Questions";
    sectionTitle1.textAlignment = UITextAlignmentCenter;
    sectionTitle1.adjustsFontSizeToFitWidth = YES;
    sectionTitle1.font = [UIFont boldSystemFontOfSize:17];
    sectionTitle1.textColor = [UIColor blackColor];
    sectionTitle1.backgroundColor = [UIColor clearColor];
    sectionTitle1.shadowColor = [UIColor whiteColor];
    sectionTitle1.shadowOffset = CGSizeMake(0.0, 1.0);
    [scrollView addSubview:sectionTitle1];
    [sectionTitle1 release];
    
    qLabel1.text = @"QUESTION:";
    qLabel1.font = [UIFont boldSystemFontOfSize:14];
    qLabel1.textColor = [UIColor blackColor];
    qLabel1.backgroundColor = [UIColor clearColor];
    qLabel1.shadowColor = [UIColor whiteColor];
    qLabel1.shadowOffset = CGSizeMake(0.0, 1.0);
    [scrollView addSubview:qLabel1];
    [qLabel1 release];
    
    question1.text = @"I left Random Alarms open and my alarm didn't go off.";
    question1.font = [UIFont systemFontOfSize:13];
    question1.textColor = [UIColor darkGrayColor];
    question1.backgroundColor = [UIColor clearColor];
    question1.shadowColor = [UIColor whiteColor];
    question1.shadowOffset = CGSizeMake(0.0, 0.5);
    question1.numberOfLines = 2;
    [scrollView addSubview:question1];
    [question1 release];
    
    aLabel1.text = @"ANSWER:";
    aLabel1.font = [UIFont boldSystemFontOfSize:14];
    aLabel1.textColor = [UIColor blackColor];
    aLabel1.backgroundColor = [UIColor clearColor];
    aLabel1.shadowColor = [UIColor whiteColor];
    aLabel1.shadowOffset = CGSizeMake(0.0, 1.0);
    [scrollView addSubview:aLabel1];
    [aLabel1 release];
    
    answer1.text = @"iOS local notifications only work when an app is running in the background, so you need to remember to put the app in the background whenever you schedule an alarm. Don't worry, we've built reminders into the app for you!";
    answer1.font = [UIFont systemFontOfSize:13];
    answer1.textColor = [UIColor darkGrayColor];
    answer1.backgroundColor = [UIColor clearColor];
    answer1.shadowColor = [UIColor whiteColor];
    answer1.shadowOffset = CGSizeMake(0.0, 0.5);
    answer1.numberOfLines = 0;
    [scrollView addSubview:answer1];
    [answer1 release];
    
    
    
    /**************** SECOND QUESTION ******************/
    
    
    qLabel2.text = @"QUESTION:";
    qLabel2.font = [UIFont boldSystemFontOfSize:14];
    qLabel2.textColor = [UIColor blackColor];
    qLabel2.backgroundColor = [UIColor clearColor];
    qLabel2.shadowColor = [UIColor whiteColor];
    qLabel2.shadowOffset = CGSizeMake(0.0, 1.0);
    [scrollView addSubview:qLabel2];
    [qLabel2 release];
    
    question2.text = @"What else can I do with Random Alarms?";
    question2.font = [UIFont systemFontOfSize:13];
    question2.textColor = [UIColor darkGrayColor];
    question2.backgroundColor = [UIColor clearColor];
    question2.shadowColor = [UIColor whiteColor];
    question2.shadowOffset = CGSizeMake(0.0, 0.5);
    question2.numberOfLines = 0;
    [scrollView addSubview:question2];
    [question2 release];
    
    aLabel2.text = @"ANSWER:";
    aLabel2.font = [UIFont boldSystemFontOfSize:14];
    aLabel2.textColor = [UIColor blackColor];
    aLabel2.backgroundColor = [UIColor clearColor];
    aLabel2.shadowColor = [UIColor whiteColor];
    aLabel2.shadowOffset = CGSizeMake(0.0, 1.0);
    [scrollView addSubview:aLabel2];
    [aLabel2 release];
    
    answer2.text = @"Since you are free to customize the alarm title, you can use Random Alarms to provide you with one-time reminders for important events. For example, \"Meeting with Alice at 3pm tomorrow\". Or, use the random alarm feature to set helpful and inspiring messages - just put in your favorite quote, and remind yourself to be inspired all day long!";
    answer2.font = [UIFont systemFontOfSize:13];
    answer2.textColor = [UIColor darkGrayColor];
    answer2.backgroundColor = [UIColor clearColor];
    answer2.shadowColor = [UIColor whiteColor];
    answer2.shadowOffset = CGSizeMake(0.0, 0.5);
    answer2.numberOfLines = 0;
    [scrollView addSubview:answer2];
    [answer2 release];
    
    
    /**************** THIRD QUESTION ******************/
    
    
    qLabel3.text = @"QUESTION:";
    qLabel3.font = [UIFont boldSystemFontOfSize:14];
    qLabel3.textColor = [UIColor blackColor];
    qLabel3.backgroundColor = [UIColor clearColor];
    qLabel3.shadowColor = [UIColor whiteColor];
    qLabel3.shadowOffset = CGSizeMake(0.0, 1.0);
    [scrollView addSubview:qLabel3];
    [qLabel3 release];
    
    question3.text = @"How private are my reminders and alarms?";
    question3.font = [UIFont systemFontOfSize:13];
    question3.textColor = [UIColor darkGrayColor];
    question3.backgroundColor = [UIColor clearColor];
    question3.shadowColor = [UIColor whiteColor];
    question3.shadowOffset = CGSizeMake(0.0, 0.5);
    question3.numberOfLines = 0;
    [scrollView addSubview:question3];
    [question3 release];
    
    aLabel3.text = @"ANSWER:";
    aLabel3.font = [UIFont boldSystemFontOfSize:14];
    aLabel3.textColor = [UIColor blackColor];
    aLabel3.backgroundColor = [UIColor clearColor];
    aLabel3.shadowColor = [UIColor whiteColor];
    aLabel3.shadowOffset = CGSizeMake(0.0, 1.0);
    [scrollView addSubview:aLabel3];
    [aLabel3 release];
    
    answer3.text = @"All of the data is stored in a private database inside the App. None of your information is transmitted to the Internet or to any of our servers.";
    answer3.font = [UIFont systemFontOfSize:13];
    answer3.textColor = [UIColor darkGrayColor];
    answer3.backgroundColor = [UIColor clearColor];
    answer3.shadowColor = [UIColor whiteColor];
    answer3.shadowOffset = CGSizeMake(0.0, 0.5);
    answer3.numberOfLines = 0;
    [scrollView addSubview:answer3];
    [answer3 release];
    
    
    /**************** FOURTH QUESTION ******************/
    
    
    qLabel4.text = @"QUESTION:";
    qLabel4.font = [UIFont boldSystemFontOfSize:14];
    qLabel4.textColor = [UIColor blackColor];
    qLabel4.backgroundColor = [UIColor clearColor];
    qLabel4.shadowColor = [UIColor whiteColor];
    qLabel4.shadowOffset = CGSizeMake(0.0, 1.0);
    [scrollView addSubview:qLabel4];
    [qLabel4 release];
    
    question4.text = @"I don't hear any sound when I try to preview it.";
    question4.font = [UIFont systemFontOfSize:13];
    question4.textColor = [UIColor darkGrayColor];
    question4.backgroundColor = [UIColor clearColor];
    question4.shadowColor = [UIColor whiteColor];
    question4.shadowOffset = CGSizeMake(0.0, 0.5);
    question4.numberOfLines = 0;
    [scrollView addSubview:question4];
    [question4 release];
    
    aLabel4.text = @"ANSWER:";
    aLabel4.font = [UIFont boldSystemFontOfSize:14];
    aLabel4.textColor = [UIColor blackColor];
    aLabel4.backgroundColor = [UIColor clearColor];
    aLabel4.shadowColor = [UIColor whiteColor];
    aLabel4.shadowOffset = CGSizeMake(0.0, 1.0);
    [scrollView addSubview:aLabel4];
    [aLabel4 release];
    
    answer4.text = @"Random Alarms respects your \"silent mode\" settings, so in order to preview sounds, you need to disable silent mode first.";
    answer4.font = [UIFont systemFontOfSize:13];
    answer4.textColor = [UIColor darkGrayColor];
    answer4.backgroundColor = [UIColor clearColor];
    answer4.shadowColor = [UIColor whiteColor];
    answer4.shadowOffset = CGSizeMake(0.0, 0.5);
    answer4.numberOfLines = 0;
    [scrollView addSubview:answer4];
    [answer4 release];
    
    [forumButton addTarget:self action:@selector(forumButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    forumButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [scrollView addSubview:forumButton];
    
    copyright.text = @"\u00A9 Copyright 2014, The Infinite 3";
    copyright.textAlignment = UITextAlignmentCenter;
    copyright.font = [UIFont systemFontOfSize:11];
    copyright.textColor = [UIColor darkGrayColor];
    copyright.backgroundColor = [UIColor clearColor];
    copyright.shadowColor = [UIColor whiteColor];
    copyright.shadowOffset = CGSizeMake(0.0, 0.5);
    copyright.numberOfLines = 0;
    [scrollView addSubview:copyright];
    [copyright release];
    
    // This is the real height of the actual content. If it is less than the scrollView size, no scrolling will happen.
    scrollView.contentSize = CGSizeMake(320, 800);
    
}

-(void) forumButtonPressed:(UIButton *)sender {
    NSString* launchUrl = @"http://randomalarms.com/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
