//
//  CHHourCounter.m
//  CountMyHours
//
//  Created by Matt Diephouse on 3/8/10.
//  Copyright 2010 Matt Diephouse. All rights reserved.
//

#import "CHHourCounter.h"


@implementation CHHourCounter

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (id) init
{
    self = [super init];
    
    if (self)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _calendarsToCount = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"CHCalendersToCount"]];
    }
    
    return self;
}


- (void) dealloc
{
    [_calendarsToCount release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) sharedInstance
{
    static id instance = nil;
    if (!instance)
        instance = [CHHourCounter new];
    
    return instance;
}


- (BOOL) isCountingHoursInCalendar:(CalCalendar *)calendar
{
    return [_calendarsToCount containsObject:calendar.uid];
}


- (void) startCountingHoursInCalendar:(CalCalendar *)calendar
{
    if (![self isCountingHoursInCalendar:calendar])
    {
        [_calendarsToCount addObject:calendar.uid];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_calendarsToCount forKey:@"CHCalendarsToCount"];
    }
}


- (void) stopCountingHoursInCalendar:(CalCalendar *)calendar
{
    if ([self isCountingHoursInCalendar:calendar])
    {
        [_calendarsToCount removeObject:calendar.uid];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_calendarsToCount forKey:@"CHCalendarsToCount"];
    }
}


- (NSUInteger) completedHoursForWeek:(NSDate *)weekDate
{
    return 0;
}


- (NSUInteger) totalHoursForWeek:(NSDate *)weekDate
{
    return 0;
}


@end
