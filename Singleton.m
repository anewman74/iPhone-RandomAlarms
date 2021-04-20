//
//  Singleton.m
//  MultipleAlarms
//
//  Created by Andrew on 12/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Singleton.h"


@implementation Singleton
@synthesize newrownumber;
@synthesize plusclicked;

static Singleton* _sharedSingleton = nil;

+ (Singleton*)sharedSingleton {
	
	@synchronized([Singleton class]) {
		if(!_sharedSingleton)
			_sharedSingleton = [[self alloc] init];
		
		return _sharedSingleton;
	}
	return nil;
}


+ (id) alloc {
	@synchronized ([Singleton class]) {
		NSAssert(_sharedSingleton == nil, @"Attempted to allocate a second instance of a Singleton.");
		_sharedSingleton = [super alloc];
		return _sharedSingleton;
	}
	
	return nil;
}

-(id) init {
	
	self = [super init];
	
	if (self != nil) {
	} 
	return self;
}

- (NSString *)dataFilePath {
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (NSUInteger) getnewrownumber {
	return newrownumber;
}
- (void) setnewrownumber:(NSUInteger)value {
	newrownumber = value;
}

- (NSUInteger) getplusclicked {
	return plusclicked;
}
- (void) setplusclicked:(NSUInteger)value {
	plusclicked = value;
}

-(NSString *) hourAMPM: (NSString *)time {
    
    // Split string to get hour
    NSArray *splite = [time componentsSeparatedByString:@":"];
    NSString *hour = [splite objectAtIndex:0];
    NSString *min = [splite objectAtIndex:1];
    
    // Put a backslash in front of single quotes or double quotes.
    int intHour = [hour intValue];
    
    if((intHour > 12) && (intHour < 24)) {
        intHour = intHour - 12;
        strTime = [[NSString alloc] initWithFormat:@"%i:%@ pm",intHour, min];
    }
    else if ((intHour > 0) && (intHour < 12)) {
        strTime = [[NSString alloc] initWithFormat:@"%i:%@ am",intHour, min];
    }
    else if(intHour == 0) {
        intHour = 12;
        strTime = [[NSString alloc] initWithFormat:@"%i:%@ am",intHour,min];
    }
    else {
        strTime = [[NSString alloc] initWithFormat:@"%i:%@ pm",intHour,min];
    }
    
    return strTime;
}

-(NSString *) hour24: (NSString *)time {
    
    // Split string to get am/pm
    NSArray *splite = [time componentsSeparatedByString:@" "];
    NSString *num = [splite objectAtIndex:0];
    NSString *ampm = [splite objectAtIndex:1];
    
    // Split num to get hour
    NSArray *split = [num componentsSeparatedByString:@":"];
    NSString *hour = [split objectAtIndex:0];
    NSString *min = [split objectAtIndex:1];
    
    if ([ampm isEqualToString:@"pm"]) {
        
        int intHour = [hour intValue];
        
        if(intHour != 12) {
            intHour = intHour + 12;
        }
        
        hour = [NSString stringWithFormat:@"%i",intHour];
    }
    else {
        int intHour = [hour intValue];
        
        if(intHour == 12) {
            hour = @"00";
        }
    }
    
    NSString *time24 = [NSString stringWithFormat:@"%@.%@",hour,min];
    return time24;
}

-(NSString *) tomorrowDate: (NSString *)time {
    
    // Split string to get am/pm
    NSArray *splite = [time componentsSeparatedByString:@"/"];
    NSString *strYear = [splite objectAtIndex:0];
    NSString *strMonth = [splite objectAtIndex:1];
    NSString *strDay = [splite objectAtIndex:2];
    
    int year = [strYear intValue];
    int month = [strMonth intValue];
    int day = [strDay intValue];
    
    if ((month == 12) && (day == 31)) {
        year = year + 1;
        strMonth = @"01";
        strDay = @"01";
    }
    else if (((month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10)) && (day == 31)) {
        month = month + 1;
        if(month < 10) {
            strMonth = [NSString stringWithFormat:@"0%i",month];
        }
        else {
            strMonth = [NSString stringWithFormat:@"%i",month];
        }
        strDay = @"01";
    }
    else if (((month == 4) || (month == 6) || (month == 9) || (month == 11) ) && (day == 30)) {
        month = month + 1;
        if(month < 10) {
            strMonth = [NSString stringWithFormat:@"0%i",month];
        }
        else {
            strMonth = [NSString stringWithFormat:@"%i",month];
        }
        strDay = @"01";
    }
    else if ( (month == 2) && (year % 400 == 0) && (day == 29) ) {
        month = month + 1;
        strMonth = [NSString stringWithFormat:@"0%i",month];
        strDay = @"01";
    } 
    else if ( (month == 2) && (year % 100 == 0) && (year % 400 != 0) && (day == 28) ) {
        month = month + 1;
        strMonth = [NSString stringWithFormat:@"0%i",month];
        strDay = @"01";
    }
    else if ( (month == 2) && (year % 4 == 0) && (day == 29) ) {
        month = month + 1;
        strMonth = [NSString stringWithFormat:@"0%i",month];
        strDay = @"01";
    }
    else if ( (month == 2) && (year % 4 != 0) && (day == 28) ) {
        month = month + 1;
        strMonth = [NSString stringWithFormat:@"0%i",month];
        strDay = @"01";
    }
    else {
        if(month < 10) {
            strMonth = [NSString stringWithFormat:@"0%i",month];
        }
        else {
            strMonth = [NSString stringWithFormat:@"%i",month];
        }
        day = day + 1;
        if(day < 10) {
            strDay = [NSString stringWithFormat:@"0%i",day];
        }
        else {
            strDay = [NSString stringWithFormat:@"%i",day];
        }
    }
    
    NSString *date = [NSString stringWithFormat:@"%i/%@/%@",year,strMonth,strDay];
    return date;
}

@end





