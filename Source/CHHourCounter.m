//
//  CHHourCounter.m
//  CountMyHours
//
//  Created by Matt Diephouse on 3/8/10.
//  Copyright 2010 Matt Diephouse. All rights reserved.
//

#import "CHHourCounter.h"


NSString * const CHHoursNeedToBeRecountedNotification = @"CHHoursNeedToBeRecountedNotification";

@interface CHHourCounter ()
- (NSDate *) _beginningOfWeek:(NSDate *)weekDate;
- (NSDate *) _endOfWeek:(NSDate *)weekDate;
- (NSUInteger) _hoursBetweenBegin:(NSDate *)beginDate end:(NSDate *)endDate;
- (void) _postRecountNotification;
@end


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
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver: self
               selector: @selector(_eventsChanged:)
                   name: CalEventsChangedExternallyNotification
                 object: nil];
        [nc addObserver: self
               selector: @selector(_calendarsChanged:)
                   name: CalCalendarsChangedExternallyNotification
                 object: nil];
    }
    
    return self;
}


- (void) dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:CalEventsChangedExternallyNotification    object:nil];
    [nc removeObserver:self name:CalCalendarsChangedExternallyNotification object:nil];
    
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
        
        [self _postRecountNotification];
    }
}


- (void) stopCountingHoursInCalendar:(CalCalendar *)calendar
{
    if ([self isCountingHoursInCalendar:calendar])
    {
        [_calendarsToCount removeObject:calendar.uid];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_calendarsToCount forKey:@"CHCalendarsToCount"];
        
        [self _postRecountNotification];
    }
}


- (NSUInteger) completedHoursForWeek:(NSDate *)weekDate
{
    NSDate *beginningOfWeek = [self _beginningOfWeek:weekDate];
    return [self _hoursBetweenBegin:beginningOfWeek end:[NSDate date]];
}


- (NSUInteger) totalHoursForWeek:(NSDate *)weekDate
{
    NSDate *beginningOfWeek = [self _beginningOfWeek:weekDate];
    NSDate *endOfWeek       = [self _endOfWeek:weekDate];
    return [self _hoursBetweenBegin:beginningOfWeek end:endOfWeek];
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


//==================================================================================================
#pragma mark -
#pragma mark Private Methods
//==================================================================================================

- (NSDate *) _beginningOfWeek:(NSDate *)weekDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *beginningOfWeek = nil;
    NSTimeInterval interval = 0;
    BOOL ok = [gregorian rangeOfUnit: NSWeekCalendarUnit
                           startDate: &beginningOfWeek
                            interval: &interval
                             forDate: weekDate];
    [gregorian release];
    
    if (!ok)
        return nil;
    return beginningOfWeek;
}


- (NSDate *) _endOfWeek:(NSDate *)weekDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *beginningOfWeek = nil;
    NSTimeInterval interval = 0;
    BOOL ok = [gregorian rangeOfUnit: NSWeekCalendarUnit
                           startDate: &beginningOfWeek
                            interval: &interval
                             forDate: weekDate];
    [gregorian release];
    
    if (!ok)
        return nil;
    
    NSDate *endOfWeek = [NSDate dateWithTimeInterval:interval sinceDate:beginningOfWeek];
    return endOfWeek;
}


- (NSUInteger) _hoursBetweenBegin:(NSDate *)beginDate end:(NSDate *)endDate
{
    NSUInteger hours = 0;
    
    if (beginDate && endDate)
    {
        CalCalendarStore *store = [CalCalendarStore defaultCalendarStore];
        
        NSPredicate *predicate = [CalCalendarStore eventPredicateWithStartDate: beginDate
                                                                       endDate: endDate
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
    
    return hours;
}


- (void) _postRecountNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:CHHoursNeedToBeRecountedNotification object:self];
}


//==================================================================================================
#pragma mark -
#pragma mark Notifications
//==================================================================================================

- (void) _calendarsChanged:(NSNotification *)notification
{
    CalCalendarStore *store = [CalCalendarStore defaultCalendarStore];
    
    NSMutableArray *toRemove = [NSMutableArray new];
    for (NSString *uid in _calendarsToCount)
        if (![store calendarWithUID:uid])
            [toRemove addObject:uid];
    
    if ([toRemove count])
    {
        [_calendarsToCount removeObjectsInArray:toRemove];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_calendarsToCount forKey:@"CHCalendarsToCount"];
    }
    
    [toRemove release];
    
    [self _postRecountNotification];
}


- (void) _eventsChanged:(NSNotification *)notification
{
    [self _postRecountNotification];
}


@end
