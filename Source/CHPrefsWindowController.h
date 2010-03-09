//
//  CHPrefsWindowController.h
//  CountMyHours
//
//  Created by Matt Diephouse on 3/7/10.
//  Copyright 2010 Matt Diephouse. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CHPrefsWindowController : NSWindowController <NSTableViewDataSource>
{
    IBOutlet NSPopUpButton *_firstWeekdayPopUp;
    IBOutlet NSTableView *_calendarTableView;
}

- (IBAction) changeFirstWeekday:(id)sender;

@end
