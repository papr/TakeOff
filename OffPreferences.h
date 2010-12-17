//
//  OffPreferences.h
//  Off
//
//  Created by Pablo on 08.03.09.
//  Copyright 2009 fro<C>en software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/ShortcutRecorder.h>

@interface OffPreferences : NSWindowController {
	IBOutlet SRRecorderControl *toggleCountdownRecorder;
}

- (IBAction)changeCountDown:(id)sender;

@end
