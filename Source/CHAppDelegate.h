//
//  CHAppDelegate.h
//  CountMyHours
//
//  Created by Matt Diephouse on 3/7/10.
//  Copyright 2010 Matt Diephouse. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CHAppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSMenu *_menu;
    IBOutlet NSWindow *_prefsWindow;
    
    NSStatusItem *_statusItem;
}

- (void) showPreferences:(id)sender;

@end
