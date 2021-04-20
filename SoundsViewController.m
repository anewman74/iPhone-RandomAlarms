//
//  SoundsViewController.m
//  MultipleAlarms
//
//  Created by Andrew on 1/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SoundsViewController.h"
#import "MultipleAlarmsAppDelegate.h"
#import "Singleton.h"
#import <AVFoundation/AVAudioPlayer.h>

@implementation SoundsViewController
@synthesize audioPlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initializeTableData {
    
    // Display names
    tableData = [[NSMutableArray alloc] initWithObjects:@"303",@"Bassy",@"Bird",@"Chainsaw",@"Church Bell",@"Cold",@"Cow",@"Crystalize",@"Doodoowa",@"Dhol Roll 70",@"Evil Laugh",@"Fall and Bounce",@"Goat",@"Hen",@"Horse",@"Krikits",@"LiquidsL",@"Logostin",@"Maddog",@"Madlab",@"Memorymoon",@"Mmmm Mmm",@"Ooh Lala",@"Pager",@"Police Siren",@"Pschycoy",@"Pygmie 1",@"Pygmie 2",@"Rock On",@"Scales",@"Siren 1",@"Siren 2",@"Siren 3",@"Sloggy",@"Snore",@"Spaz",@"Tesla",@"Thumps",@"Tic Toc",@"Tricky Hop",@"Visitors", nil];
    
    // File names
    soundFile = [[NSMutableArray alloc] initWithObjects:@"303__2.mp3",@"BASSY.mp3",@"BIRD1.mp3",@"chainsaw2.mp3",@"churchbell1.mp3",@"48456__flick3r__cold-3.mp3",@"COW.mp3",@"Arp_am_140_12_1.mp3",@"DOODOOWA.mp3",@"dhol_roll_70_M_Idea.mp3",@"evillaugh.mp3",@"11841__medialint__fall-and-bounce-arp-90bpm-e2.mp3",@"GOAT.mp3",@"hen2.mp3",@"horse1a.mp3",@"KRIKITS.mp3",@"LIQUIDSL-clipped.mp3",@"LOGOSTIN-clipped.mp3",@"MADBARK-double.mp3",@"MADLAB4.mp3",@"27568__suonho__memorymoon-space-blaster-plays-clipped.mp3",@"MMMM_MMM.mp3",@"OOH_LALA.mp3",@"pager.mp3",@"policesiren2.mp3",@"PSCHYCOY.mp3",@"PYGMIE1.mp3",@"PYGMIE2.mp3",@"Arp_am_140_11_1.mp3",@"SCALES.mp3",@"SIREN1-clipped.mp3",@"SIREN2.mp3",@"SIREN3.mp3",@"SLOGGY-extended.mp3",@"SNORE2.mp3",@"SPAZ.mp3",@"TESLA.mp3",@"str-01.mp3",@"TIC_TOC.mp3",@"3449__patchen__trickyhop-abcd.mp3",@"VISITORS.mp3", nil];
    
    arrSoundLengths = [[NSMutableArray alloc] initWithObjects:@"0.05",@"0.02",@"0.01",@"0.16",@"0.03",@"0.07",@"0.02",@"0.07",@"0.01",@"0.04",@"0.04",@"0.05",@"0.01",@"0.04",@"0.02",@"0.02",@"0.04",@"0.03",@"0.01",@"0.04",@"0.03",@"0.02",@"0.02",@"0.02",@"0.09",@"0.02",@"0.04",@"0.02",@"0.07",@"0.02",@"0.05",@"0.02",@"0.03",@"0.04",@"0.04",@"0.04",@"0.03",@"0.02",@"0.03",@"0.05",@"0.04", nil];

    //NSLog(@"table data: %@", tableData);
    //NSLog(@"sound file: %@", soundFile);
    //NSLog(@"sound length: %@", arrSoundLengths);
    
    //NSLog(@"table data count: %i", [tableData count]);
    //NSLog(@"sound file count: %i", [soundFile count]);
    //NSLog(@"sound length count: %i", [arrSoundLengths count]);
    
    [tabl reloadData];
}

#pragma mark - View lifecycle
-(void)viewWillAppear:(BOOL)animated {
    
    //NSLog(@"in view will appear in soundsVC");
    
    self.navigationItem.hidesBackButton = YES;
    
    [tabl setContentOffset:CGPointZero animated:NO];
    
    //Open database
	if(sqlite3_open([[[Singleton sharedSingleton] dataFilePath] UTF8String], &database) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database");
	}
    
    [self initializeTableData];
    
    // provide my own Save button to dismiss the keyboard
    UIBarButtonItem* editing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self action:@selector(saveData:)];
    self.navigationItem.rightBarButtonItem = editing;
    [editing release];
    
    // provide my own Cancel button to dismiss the keyboard
    UIBarButtonItem* cancelling = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self action:@selector(cancelData:)];
    self.navigationItem.leftBarButtonItem = cancelling;
    [cancelling release];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title =  NSLocalizedString(@"Sounds", @"sounds");
    
    // Create new alarm if newalarm = 1 in Singleton class.
    
}

- (void)saveData:(id)sender
{
    self.navigationItem.rightBarButtonItem = nil;
    
    newrownumber  = (int)[[Singleton sharedSingleton] getnewrownumber];
    //NSLog(@"row chosen in update method is  %i", newrownumber);
    //NSLog(@"sound name: %@", soundName);
    
    char *update = "update alarms set sound = ?, soundfile = ?, soundlength = ? where row = ?;";    
    sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK){
        
        sqlite3_bind_text(stmt, 1, [soundName UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [sound UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [soundLength UTF8String], -1, NULL);
		sqlite3_bind_int(stmt, 4, newrownumber);
        
        //NSLog(@"in sql stmt");
	}
    
	if(sqlite3_step(stmt) != SQLITE_DONE)
		NSLog(@"statement failed");
	sqlite3_finalize(stmt);
    
	sqlite3_close(database);    
    
    MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController popViewControllerAnimated:YES];
}

- (void)cancelData:(id)sender
{
    self.navigationItem.leftBarButtonItem = nil;
    MultipleAlarmsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController popViewControllerAnimated:YES];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryNone;

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    //NSLog(@"row selected: %i",[indexPath row]);
    soundName = [tableData objectAtIndex:[indexPath row]];
    sound = [soundFile objectAtIndex:[indexPath row]];
    soundLength = [arrSoundLengths objectAtIndex:[indexPath row]];
    //NSLog(@"sound selected: %@",soundName);
    //NSLog(@"sound file selected: %@",sound);
    //NSLog(@"sound length selected: %@",soundLength);
    
    // Split string to get start and end times
    NSArray *splite = [[soundFile objectAtIndex:[indexPath row]] componentsSeparatedByString:@".mp3"];
    NSString *soundtitle = [splite objectAtIndex:0];
    //NSLog(@"sound title selected: %@",soundtitle);
    
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        //NSLog(@"inside if");
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:soundtitle
                                                             ofType:@"mp3"];	
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: filePath];	
        self.audioPlayer = [[AVAudioPlayer alloc] 
                            initWithContentsOfURL:fileURL error:nil];

        [fileURL release];
        
        [self.audioPlayer play];
    }
    else {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:soundtitle
                                                             ofType:@"mp3"];	
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: filePath];	
        self.audioPlayer = [[AVAudioPlayer alloc] 
                            initWithContentsOfURL:fileURL error:nil];
        [fileURL release];
        
        [self.audioPlayer play];
        
        NSLog(@"inside else");
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [self.audioPlayer stop];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
