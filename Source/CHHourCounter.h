//
//  CHHourCounter.h
//  CountMyHours
//
//  Created by Matt Diephouse on 3/8/10.
//  Copyright 2010 Matt Diephouse. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#import <CalendarStore/CalendarStore.h>

extern NSString * const CHHoursNeedToBeRecountedNotification;

@interface CHHourCounter : NSObject
{
    NSMutableArray *_calendarsToCount;
}

@property (readonly) NSArray *calendars;

+ (id) sharedInstance;

- (BOOL) isCountingHoursInCalendar:(CalCalendar *)calendar;
- (void) startCountingHoursInCalendar:(CalCalendar *)calendar;
- (void) stopCountingHoursInCalendar:(CalCalendar *)calendar;

- (NSUInteger) firstWeekday;
- (void) setFirstWeekday:(NSUInteger)weekDay;

- (NSUInteger) completedHoursForWeek:(NSDate *)weekDate;
- (NSUInteger) totalHoursForWeek:(NSDate *)weekDate;

@end
