//
//  CHPrefsWindowController.m
//  CountMyHours
//
//  Created by Matt Diephouse on 3/7/10.
//  Copyright 2010 Matt Diephouse. All rights reserved.
//

#import "CHPrefsWindowController.h"


#import <CalendarStore/CalendarStore.h>

@implementation CHPrefsWindowController

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) awakeFromNib
{
    CalCalendarStore *store = [CalCalendarStore defaultCalendarStore];
    
    for (CalCalendar *calendar in [store calendars])
        [_calendarPopUp addItemWithTitle:calendar.title];
}


@end
