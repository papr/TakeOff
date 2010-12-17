//
//  OffPreferences.m
//  Off
//
//  Created by Pablo on 08.03.09.
//  Copyright 2009 fro<C>en software. All rights reserved.
//

#import "OffPreferences.h"
#import "OffController.h"

@implementation OffPreferences

- (id)init {
	if(![super initWithWindowNibName:@"OffPreffXib"]) {
		return nil;
	}
	return self;
}

- (void)awakeFromNib {
	[toggleCountdownRecorder setAnimates:YES];
	[toggleCountdownRecorder setAutosaveName:@"ToogleCountdownRecorderAutosave"];
	[[toggleCountdownRecorder cell] reloadAutosavedData];
}

- (IBAction)changeCountDown:(id)sender {
	[[NSApp delegate] willChangeValueForKey:@"menuCountdown"];
	[[NSApp delegate] didChangeValueForKey:@"menuCountdown"];
}

@end
