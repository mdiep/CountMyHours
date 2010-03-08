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
        _calendarsToCount = [[defaults arrayForKey:@"CHCalendarsToCount"] mutableCopy];
    }
    
    return self;
}


- (void) dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:CalCalendarsChangedExternallyNotification object:nil];
    
    [_calendarsToCount release];
    
    [super dealloc];
}


- (void) awakeFromNib
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserverForName: CalCalendarsChangedExternallyNotification
                    object: nil
                     queue: nil
                usingBlock: ^(NSNotification *notification) {
                    CalCalendarStore *store = [CalCalendarStore defaultCalendarStore];
                    
                    NSMutableArray *toRemove = [NSMutableArray new];
                    for (NSString *uid in self->_calendarsToCount)
                        if (![store calendarWithUID:uid])
                            [toRemove addObject:uid];
                    
                    if ([toRemove count])
                    {
                        [self->_calendarsToCount removeObjectsInArray:toRemove];
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:self->_calendarsToCount forKey:@"CHCalendarsToCount"];
                    }
                    
                    [toRemove release];
                }];
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
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *beginningOfWeek = nil;
    NSTimeInterval interval = 0;
    BOOL ok = [gregorian rangeOfUnit: NSWeekCalendarUnit
                           startDate: &beginningOfWeek
                            interval: &interval
                             forDate: weekDate];
    
    NSUInteger hours = 0;
    
    if (ok)
    {
        CalCalendarStore *store = [CalCalendarStore defaultCalendarStore];
        NSDate *endOfWeek = [NSDate dateWithTimeInterval:interval sinceDate:beginningOfWeek];
        
        NSPredicate *predicate = [CalCalendarStore eventPredicateWithStartDate: beginningOfWeek
                                                                       endDate: endOfWeek
                                                                     calendars: self.calendars];
        NSArray *events = [store eventsWithPredicate:predicate];
        for (CalEvent *event in events)
        {
            if (event.isAllDay)
                continue;
            
            NSTimeInterval interval = [event.endDate timeIntervalSinceDate:event.startDate];
            hours += floor(interval/60.0/60.0);
        }
    }
    
    [gregorian release];
    return hours;
}


//==================================================================================================
#pragma mark -
#pragma mark Public Properties
//==================================================================================================

- (NSArray *) calendars
{
    CalCalendarStore *store     = [CalCalendarStore defaultCalendarStore];
    NSMutableArray   *calendars = [NSMutableArray array];
    for (NSString *uid in _calendarsToCount)
    {
        CalCalendar *calendar = [store calendarWithUID:uid];
        if (calendar)
            [calendars addObject:calendar];
    }
    return calendars;
}


@end
