//
//  OffController.h
//  Take Off
//
//  Created by Pablo on 19.04.09.
//  Copyright 2009 RandomCode. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <iLifeControls/NFHUDWindow.h>
#import "OffPreferences.h"
#import "TransparentWindow.h"

extern NSString * const OCWillStartCountdown;
extern NSString * const OCDidStopCountdown;

extern NSString * const Off_Countdown;
extern NSString * const Off_DisplaySleep;
extern NSString * const Off_Screensaver;
extern NSString * const Off_Suspend;
extern NSString * const Off_Shutdown;

extern NSString * const OC_ShowCountdownInMenubar;
extern NSString * const OC_ShowCountdownOnFloatingWindow;

@interface OffController : NSObject {
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *takeOffItem;
	IBOutlet NSMenuItem *leftTimeItem;
	IBOutlet NSMenuItem *isRunningItem;
	IBOutlet NSMenuItem *countdownTimeItem;
	
	IBOutlet NSPanel *floatingWindow;	
	IBOutlet NSButtonCell *stopButtonCell;
	IBOutlet NSTextField *floatText;
	BOOL textAsBig;
	
	OffPreferences *prefs;
	
	NSStatusItem *statusItem;
	BOOL running;
	NSString *menuCountdown;
	NSTimer *countdownTimer;
	double entireTime;
	double leftTime;
	NSImage *icon;
//	NSImage *runIcon;
	
	NSString *textFont;
}

- (IBAction)startUICountdown:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)openAboutBox:(id)sender;
- (int)performTakeOffProccessWithArguments:(NSArray *)args;
- (NSTimeInterval)getTimeIntervalFromString:(NSString *)countDown;
- (NSString *)getStringFromTimeInterval:(NSTimeInterval)ti;
- (NSArray *)executeArguments;

@property BOOL running;
@property BOOL textAsBig;
@property (copy) NSString *textFont;
@property (readonly, copy) NSString *menuCountdown;
@property double leftTime;
@end
