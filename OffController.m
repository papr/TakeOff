//
//  OffController.m
//  Take Off
//
//  Created by Pablo on 19.04.09.
//  Copyright 2009 RandomCode. All rights reserved.
//

#import "OffController.h"

NSString * const OCWillStartCountdown = @"OCWillStartCountdown";
NSString * const OCDidStopCountdown = @"OCDidStopCountdown";

NSString * const Off_Countdown = @"Countdown";
NSString * const Off_DisplaySleep = @"DisplaySleep";
NSString * const Off_Screensaver = @"Screensaver";
NSString * const Off_Suspend = @"Suspend";
NSString * const Off_Shutdown = @"Shutdown";

NSString * const OC_ShowCountdownInMenubar = @"ShowCountdownInMenubar";
NSString * const OC_ShowCountdownOnFloatingWindow = @"ShowCountdownOnFloatingWindow";

@implementation OffController

@synthesize running, textAsBig, textFont;
@synthesize leftTime;

+ (void)initialize {
	NSMutableDictionary *vals = [NSMutableDictionary dictionary];
	NSString *s = @"00:00:05";
	[vals setObject:s	forKey:Off_Countdown];
	[vals setObject:[NSNumber numberWithBool:YES] forKey:Off_DisplaySleep];
	[vals setObject:[NSNumber numberWithBool:YES] forKey:Off_Screensaver];
	[vals setObject:[NSNumber numberWithBool:YES] forKey:Off_Suspend];
	[vals setObject:[NSNumber numberWithBool:YES] forKey:Off_Shutdown];
	[vals setObject:[NSNumber numberWithBool:NO] forKey:OC_ShowCountdownInMenubar];
	[vals setObject:[NSNumber numberWithBool:YES] forKey:OC_ShowCountdownOnFloatingWindow];
	[[NSUserDefaults standardUserDefaults] registerDefaults:vals];
}

- (id)init {
	[super init];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(handleCountdownStart:)
			   name:OCWillStartCountdown
			 object:nil];
	[nc addObserver:self 
		   selector:@selector(handleCountdownStop:)
			   name:OCDidStopCountdown
			 object:nil];
	[self setRunning:NO];
	self.textFont = @"Helvetica Neue";
	icon = [NSImage imageNamed:@"Off-20.png"];
//	runIcon = [NSImage imageNamed:@"Off-running-20.png"];
	return self;
}

- (void)awakeFromNib {
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem retain];
	[statusItem setImage:icon];
	[statusItem setAlternateImage:icon];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
//	[statusItem setTitle:@"!!"];
	[floatText setTextColor:[NSColor whiteColor]];
	[self menuCountdown];
}

- (void)dealloc {
	[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
	[statusItem release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

#pragma mark CORE

- (NSTimeInterval)getTimeIntervalFromString:(NSString *)countDown {
	NSArray *a = [countDown componentsSeparatedByString:@":"];
	int i = [a count];
	NSTimeInterval ti;
	if(i == 0) {
		return -1;
	} else if (i == 1) {
		double seconds	=	[[a objectAtIndex:0] doubleValue];
		ti = seconds;		
	} else if (i == 2) {
		double minutes	=	[[a objectAtIndex:0] doubleValue]*60;
		double seconds	=	[[a objectAtIndex:1] doubleValue];
		ti = minutes + seconds;
	} else if (i == 3) {
		double hours	=	[[a objectAtIndex:0] doubleValue]*3600;
		double minutes	=	[[a objectAtIndex:1] doubleValue]*60;
		double seconds	=	[[a objectAtIndex:2] doubleValue];
		ti = hours + minutes + seconds;	
	} else {
		return -2;
	}
	
	return ti;
}

- (NSString *)getStringFromTimeInterval:(NSTimeInterval)ti {
	NSString *s;
	int hours = ti / 3600;
	ti = ti - (3600 * hours);
	int mins = ti / 60;
	ti = ti - (60 * mins);
	int secs = ti;
	
	NSString *secsStr = [[NSNumber numberWithInt:secs] stringValue];
	if([secsStr length] == 1) {
		secsStr = [NSString stringWithFormat:@"0%@", secsStr];
	}
	NSString *minsStr = [[NSNumber numberWithInt:mins] stringValue];
	if([minsStr length] == 1) {
		minsStr = [NSString stringWithFormat:@"0%@", minsStr];
	}
	
	s = [NSString stringWithFormat:@"%i:%@:%@", hours, minsStr, secsStr];
//	NSLog(@"s = %@", s);
	return s;
}

- (int)performTakeOffProccessWithArguments:(NSArray *)args {
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"OffBin" ofType:nil]];
	[task setArguments:args];
	[task launch];
	[task waitUntilExit];
	int status = [task terminationStatus];
	[task release];
	[[NSNotificationCenter defaultCenter] postNotification:
	 [NSNotification notificationWithName:OCDidStopCountdown
								   object:nil]];
	return status;
}

- (NSArray *)executeArguments {
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	NSMutableArray *args = [NSMutableArray array];
	if([d boolForKey:Off_DisplaySleep])
		[args addObject:@"sleepdisplay"];
	if([d boolForKey:Off_Screensaver])
		[args addObject:@"screensaver"];
	if([d boolForKey:Off_Suspend])
		[args addObject:@"suspend"];
	if([d boolForKey:Off_Shutdown])
		[args addObject:@"shutdown"];
	return args;
}

#pragma mark UI

- (IBAction)startUICountdown:(id)sender {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	if(!running) {
		[nc postNotification:[NSNotification notificationWithName:OCWillStartCountdown
														   object:nil]];
	} else {
		[nc postNotification:[NSNotification notificationWithName:OCDidStopCountdown
														   object:nil]];		
	}
}

- (IBAction)openPreferences:(id)sender {
	[NSApp activateIgnoringOtherApps:YES];
	if(!prefs) {
		prefs = [[OffPreferences alloc] init];
	}
	[prefs showWindow:self];
	[[prefs window] makeKeyAndOrderFront:self];
}

- (IBAction)openAboutBox:(id)sender {
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:self];
}

#pragma mark NOTIFICATION & TIMER

- (void)handleCountdownStart:(NSNotification *)note {
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	entireTime = [self getTimeIntervalFromString:[d stringForKey:Off_Countdown]];
	if(entireTime < 0) {
		NSBeep();
		NSLog(@"-[OffController countdownTime]: ErrorCode = %f", entireTime);
		return;
	}
	[self setRunning:YES];
//	[statusItem setImage:runIcon]; // change icon
	[takeOffItem setState:NSOnState];
	[takeOffItem setTitle:@"Stop Take Off"];
	[isRunningItem setHidden:NO];
	[leftTimeItem setHidden:NO];
	[self willChangeValueForKey:@"leftTime"];
	[self setLeftTime:entireTime];
	[self didChangeValueForKey:@"leftTime"];
	NSArray *exeargs = [self executeArguments];
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:[NSNumber numberWithDouble:entireTime] forKey:@"entireTime"];
	[dic setObject:exeargs forKey:@"exeArguments"];
	if(entireTime != 0) {
		countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1
														  target:self
														selector:@selector(decreaseLeftTime:)
														userInfo:dic
														 repeats:YES];	
	} else {
		[self performTakeOffProccessWithArguments:exeargs];
	}
	[floatingWindow setDefaultButtonCell:stopButtonCell];
}

- (void)handleCountdownStop:(NSNotification *)note {
	[countdownTimer invalidate];
	countdownTimer = nil;
	[self setRunning:NO];
	[isRunningItem setHidden:YES];
	[leftTimeItem setHidden:YES];
	[takeOffItem setState:NSOffState];
//	[statusItem setImage:icon]; // change icon
	[statusItem setTitle:nil];
	[floatingWindow orderOut:self];
	[floatingWindow close];
	[floatText setStringValue:@""];
	[takeOffItem setTitle:@"Start Take Off"];
}

- (void)decreaseLeftTime:(NSTimer *)aTimer {
	if([self leftTime] != 0) {
		[self willChangeValueForKey:@"leftTime"];
		double newTime = [self leftTime] - 1; 
		[self setLeftTime:newTime];
		[self didChangeValueForKey:@"leftTime"];
	}
	if([self leftTime] == 0) {
		NSArray *a = [self executeArguments];
		if(![[[aTimer userInfo] objectForKey:@"exeArguments"] isEqualTo:a]) {
			NSLog(@"Wow. Someone changed the execution arguments. Let's take the new ones...");
		}
		[self performTakeOffProccessWithArguments:a];
		return;
	}
}

#pragma mark DELEGATES

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	if([self running]) {
		NSAlert *a = [NSAlert alertWithMessageText:@"Are you sure you want to quit Take Off?"
									 defaultButton:@"Don't Quit"
								   alternateButton:@"Quit"
									   otherButton:nil
						 informativeTextWithFormat:@"A countdown is still running."];
		int i = [a runModal];
		if(i == 1)
			return NSTerminateCancel;
	}
	
	[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
	[statusItem release];
	
	return NSTerminateNow;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	[theApplication hide:self];
	return NO;
}

- (void)didChangeValueForKey:(NSString *)key {
	if([key isEqualToString:@"leftTime"]) {
		NSString *s = [self getStringFromTimeInterval:[self leftTime]];
		[leftTimeItem setTitle:
		 [NSString stringWithFormat:@"Time Left: %@",s]];
		if([[NSUserDefaults standardUserDefaults] boolForKey:OC_ShowCountdownInMenubar]) {
			[statusItem setTitle:s];
		} else {
			if(![[statusItem title] isEqualToString:@""] || [statusItem title] != nil)
				[statusItem setTitle:nil];
		}
		if([[NSUserDefaults standardUserDefaults] boolForKey:OC_ShowCountdownOnFloatingWindow]) {
			if(![floatingWindow isVisible])
				[floatingWindow setIsVisible:YES];
			if(![NSApp isActive])
				[NSApp activateIgnoringOtherApps:YES];
			if(![floatingWindow isKeyWindow])
				[floatingWindow makeKeyAndOrderFront:self];
			[floatingWindow center];
			[floatText setStringValue:s];
			[[floatText superview] setNeedsDisplay:YES];
		} else {
			[floatingWindow orderOut:self];
			[floatingWindow close];
			[floatText setStringValue:@""];
		}
	} else if ([key isEqualToString:@"menuCountdown"]) {
		[self menuCountdown];
	}
//	[statusMenu update];
}

- (BOOL)windowShouldClose:(id)window {
	NSLog(@"ask");
	if(self.running)
		return NO;
	else
		return YES;
}

#pragma mark ACCESSORS


- (NSString *)menuCountdown {
	NSString *unformt = [[NSUserDefaults standardUserDefaults] stringForKey:Off_Countdown];
	NSString *formt = [self getStringFromTimeInterval:[self getTimeIntervalFromString:unformt]];
	[[NSUserDefaults standardUserDefaults] setObject:formt forKey:Off_Countdown];
	
	NSString *s = [NSString stringWithFormat:@"Countdown: %@",
				   [[NSUserDefaults standardUserDefaults]
					stringForKey:Off_Countdown]];
	[countdownTimeItem performSelectorOnMainThread:@selector(setTitle:)
										withObject:s
									 waitUntilDone:NO];
	return s;
}

@end
