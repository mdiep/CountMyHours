//
//  CHPrefsWindowController.m
//  CountMyHours
//
//  Created by Matt Diephouse on 3/7/10.
//  Copyright 2010 Matt Diephouse. All rights reserved.
//

#import "CHPrefsWindowController.h"


#import "CHHourCounter.h"

#import <CalendarStore/CalendarStore.h>

@implementation CHPrefsWindowController

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:CalCalendarsChangedExternallyNotification object:nil];
    
    [super dealloc];
}


- (void) awakeFromNib
{
    CHHourCounter *counter = [CHHourCounter sharedInstance];
    [_firstWeekdayPopUp selectItemWithTag:[counter firstWeekday]];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserverForName: CalCalendarsChangedExternallyNotification
                    object: nil
                     queue: nil
                usingBlock: ^(NSNotification *notification) {
                    [_calendarTableView reloadData];
                }];
}


//==================================================================================================
#pragma mark -
#pragma mark Actions
//==================================================================================================

- (IBAction) changeFirstWeekday:(id)sender
{
    CHHourCounter *counter = [CHHourCounter sharedInstance];
    [counter setFirstWeekday:[_firstWeekdayPopUp selectedTag]];
}


//==================================================================================================
#pragma mark -
#pragma mark NSTableViewDataSource Methods
//==================================================================================================

- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView
{
    CalCalendarStore *store = [CalCalendarStore defaultCalendarStore];
    return [[store calendars] count];
}


- (id) tableView: (NSTableView *)aTableView
objectValueForTableColumn: (NSTableColumn *)aTableColumn
             row: (NSInteger)rowIndex
{
    CalCalendarStore *store    = [CalCalendarStore defaultCalendarStore];
    CalCalendar      *calendar = [store.calendars objectAtIndex:rowIndex];
    CHHourCounter    *counter  = [CHHourCounter sharedInstance];
    
    if ([aTableColumn.identifier isEqualToString:@"title"])
        return calendar.title;
    else
        return [NSNumber numberWithBool:[counter isCountingHoursInCalendar:calendar]];
}


- (void) tableView: (NSTableView *)tableView
    setObjectValue: (id)value
    forTableColumn: (NSTableColumn *)column
               row: (NSInteger)rowIndex
{
    CalCalendarStore *store    = [CalCalendarStore defaultCalendarStore];
    CalCalendar      *calendar = [store.calendars objectAtIndex:rowIndex];
    CHHourCounter    *counter  = [CHHourCounter sharedInstance];
    
    if ([counter isCountingHoursInCalendar:calendar])
        [counter stopCountingHoursInCalendar:calendar];
    else
        [counter startCountingHoursInCalendar:calendar];
}


@end
