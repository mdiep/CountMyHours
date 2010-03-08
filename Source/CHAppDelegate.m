//
//  CHAppDelegate.m
//  CountMyHours
//
//  Created by Matt Diephouse on 3/7/10.
//  Copyright 2010 Matt Diephouse. All rights reserved.
//

#import "CHAppDelegate.h"

@implementation CHAppDelegate

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    [_statusItem release];
    
    [super dealloc];
}


- (void) awakeFromNib
{
    _statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [_statusItem setTitle:@"0/33h"];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:_menu];
}


@end
