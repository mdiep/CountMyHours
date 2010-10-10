//
//  CHAppDelegate.m
//  CountMyHours
//
//  Created by Matt Diephouse on 3/7/10.
//  Copyright 2010 Matt Diephouse. All rights reserved.
//

#import "CHAppDelegate.h"


#import "CHHourCounter.h"

@interface CHAppDelegate ()
- (void) _updateTimes:(id)sender;
@end


@implementation CHAppDelegate

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:CHHoursNeedToBeRecountedNotification object:nil];
    
    [_statusItem release];
    
    [super dealloc];
}


- (void) awakeFromNib
{
    _statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:_menu];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector: @selector(_updateTimes:)
               name: CHHoursNeedToBeRecountedNotification
             object: nil];
    
    [self _updateTimes:nil];
}


//==================================================================================================
#pragma mark -
#pragma mark Private Methods
//==================================================================================================

- (void) _updateTimes:(id)sender
{
    CHHourCounter *counter = [CHHourCounter sharedInstance];
    
    NSUInteger completed = [counter completedHoursForWeek:[NSDate date]];
    NSUInteger total     = [counter totalHoursForWeek:[NSDate date]];
    
    NSString *title = [NSString stringWithFormat:@"%u/%uh", completed, total];
    [_statusItem setTitle:title];
    
    NSUInteger totalLastWeek = [counter totalHoursForWeek:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*7]];
    NSString *lastWeek = [NSString stringWithFormat:@"Last Week: %uh", totalLastWeek];
    [_lastWeekItem setTitle:lastWeek];
    
    NSUInteger totalNextWeek = [counter totalHoursForWeek:[NSDate dateWithTimeIntervalSinceNow:60*60*24*7]];
    NSString *nextWeek = [NSString stringWithFormat:@"Next Week: %uh", totalNextWeek];
    [_nextWeekItem setTitle:nextWeek];
}


//==================================================================================================
#pragma mark -
#pragma mark Actions
//==================================================================================================

- (void) showPreferences:(id)sender
{
    if (![_prefsWindow isVisible])
        [_prefsWindow center];
    
    [NSApp activateIgnoringOtherApps:YES];
    [_prefsWindow makeKeyAndOrderFront:sender];
}


@end
