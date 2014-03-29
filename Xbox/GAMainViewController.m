//
//  GAMainViewController.m
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 28/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

#import "GAMainViewController.h"
#import "GAXboxController.h"
#import "XboxOneButtonMap.h"
#import <VHID/VHIDDevice.h>
#import <WirtualJoy/WJoyDevice.h>

@interface GAMainViewController () <GAXboxControllerDelegate, VHIDDeviceDelegate>

@property (strong, nonatomic) IBOutlet NSImageView *image;
@property (strong, nonatomic) IBOutlet NSMatrix *radioMatrix;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioUp;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioDown;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioRight;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioLeft;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioA;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioB;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioX;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioY;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioLeftBumper;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioRightBumper;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioLeftAnalogButton;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioRightAnalogButton;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioView;
@property (strong, nonatomic) IBOutlet NSButtonCell *radioMenu;

@property (strong, nonatomic) IBOutlet NSProgressIndicator *progressLeftTrigger;
@property (strong, nonatomic) IBOutlet NSProgressIndicator *progressRightTrigger;
@property (strong, nonatomic) IBOutlet NSProgressIndicator *progressLeftAnalogX;
@property (strong, nonatomic) IBOutlet NSProgressIndicator *progressLeftAnalogY;
@property (strong, nonatomic) IBOutlet NSProgressIndicator *progressRightAnalogX;
@property (strong, nonatomic) IBOutlet NSProgressIndicator *progressRightAnalogY;

@property (strong, nonatomic) IBOutlet NSButton *connectButton;
@property (strong, nonatomic) IBOutlet NSTextField *statusLabel;
@property (strong, nonatomic) IBOutlet NSSegmentedControl *triggerButton;

@property (strong, nonatomic) GAXboxController *controller;
@property (strong, nonatomic) VHIDDevice *VHID;
@property (strong, nonatomic) WJoyDevice *virtualDevice;

- (IBAction)toggleConnection:(NSButton *)sender;
- (IBAction)triggerMode:(NSSegmentedControl *)sender;

@end

@implementation GAMainViewController

#pragma mark - View Controller Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Initialization code here.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminate:)
                                                 name:NSApplicationWillTerminateNotification
                                               object:nil];
  }
  return self;
}

- (void)appWillTerminate:(NSNotification *)notification {
  if (_controller) {
    [_controller disconnect];
  }
}

#pragma mark - Xbox Controller Delegate Methods

- (void)controllerDidConnect:(GAXboxController *)controller {
  [WJoyDevice prepare];
  [_triggerButton setEnabled:YES];
  [_controller startPolling];
  [_connectButton setTitle:@"Disconnect"];
  _VHID = [[VHIDDevice alloc] initWithType:VHIDDeviceTypeJoystick pointerCount:3 buttonCount:17 isRelative:NO];
  
  NSDictionary *properties = @{WJoyDeviceProductStringKey : @"Xbox One Controller"};
  //                               WJoyDeviceProductIDKey : @0x02d1,
  //                               WJoyDeviceVendorIDKey : @0x045e};
  _virtualDevice = [[WJoyDevice alloc] initWithHIDDescriptor:[_VHID descriptor] properties:properties];
  
  [_VHID setDelegate:self];
  
  [_statusLabel setStringValue:@"Controller connected."];
  
  [_radioMatrix setEnabled:YES];
  [_image setImage:[NSImage imageNamed:@"on"]];
}

- (void)controllerDidDisconnect:(GAXboxController *)controller {
  [_triggerButton setEnabled:NO];
  [_connectButton setTitle:@"Connect"];
  _VHID = nil;
  [_statusLabel setStringValue:@"Controller disconnected."];
  _controller = nil;

  [_radioMatrix deselectAllCells];
  [_radioMatrix setEnabled:NO];
  [_progressRightAnalogX setDoubleValue:-32768];
  [_progressRightAnalogY setDoubleValue:-32768];
  [_progressLeftAnalogX setDoubleValue:-32768];
  [_progressLeftAnalogY setDoubleValue:-32768];
  [_progressRightTrigger setDoubleValue:0];
  [_progressLeftTrigger setDoubleValue:0];
  
  [_image setImage:[NSImage imageNamed:@"off"]];
}

- (void)controllerDidUpdateData:(GAXboxController *)controller {
  [self performSelectorInBackground:@selector(updateUI:) withObject:controller];
  [self performSelectorInBackground:@selector(updateVHID:) withObject:controller];
}

- (void)controllerConnectionFailed:(GAXboxController *)controller withError:(NSString *)error errorCode:(int)code {
  [_statusLabel setStringValue:[NSString stringWithFormat:@"Error: %@ (code %d)", error, code]];
}

#pragma mark - VHID Delegate Method

- (void)VHIDDevice:(VHIDDevice *)device stateChanged:(NSData *)state {
  [_virtualDevice updateHIDState:state];
}

#pragma mark - UI update

- (void)updateUI:(GAXboxController *)controller {
  [_radioUp    setIntegerValue:[controller DPadUp]];
  [_radioDown  setIntegerValue:[controller DPadDown]];
  [_radioLeft  setIntegerValue:[controller DPadLeft]];
  [_radioRight setIntegerValue:[controller DPadRight]];
  
  [_radioA setIntegerValue:[controller A]];
  [_radioB setIntegerValue:[controller B]];
  [_radioX setIntegerValue:[controller X]];
  [_radioY setIntegerValue:[controller Y]];
  
  [_radioLeftBumper  setIntegerValue:[controller leftBumper]];
  [_radioRightBumper setIntegerValue:[controller rightBumper]];
  
  [_radioLeftAnalogButton  setIntegerValue:[controller leftAnalogButton]];
  [_radioRightAnalogButton setIntegerValue:[controller rightAnalogButton]];
  
  [_radioView setIntegerValue:[controller back]];
  [_radioMenu setIntegerValue:[controller menu]];
  
  [_progressLeftAnalogX  setDoubleValue:[controller leftAnalogX]];
  [_progressLeftAnalogY  setDoubleValue:[controller leftAnalogY]];
  [_progressRightAnalogX setDoubleValue:[controller rightAnalogX]];
  [_progressRightAnalogY setDoubleValue:[controller rightAnalogY]];
  [_progressRightTrigger setDoubleValue:[controller rightTrigger]];
  [_progressLeftTrigger  setDoubleValue:[controller leftTrigger]];
}

#pragma mark - VHID Methods

- (void)updateVHID:(GAXboxController *)controller {
  [_VHID setButton:0 pressed:[controller A]];
  [_VHID setButton:1 pressed:[controller B]];
  [_VHID setButton:2 pressed:[controller X]];
  [_VHID setButton:3 pressed:[controller Y]];
  
  [_VHID setButton:4 pressed:[controller leftBumper]];
  [_VHID setButton:5 pressed:[controller rightBumper]];
  
  if ([_controller analogTriggers]) {
    [_VHID setButton:6 pressed:NO];
    [_VHID setButton:7 pressed:NO];
  } else {
    [_VHID setButton:6 pressed:[controller leftTrigger]];
    [_VHID setButton:7 pressed:[controller rightTrigger]];
  }
  
  [_VHID setButton:8 pressed:[controller back]];
  [_VHID setButton:9 pressed:[controller menu]];
  
  [_VHID setButton:10 pressed:[controller leftAnalogButton]];
  [_VHID setButton:11 pressed:[controller rightAnalogButton]];
  
  [_VHID setButton:12 pressed:[controller DPadUp]];
  [_VHID setButton:13 pressed:[controller DPadDown]];
  [_VHID setButton:14 pressed:[controller DPadLeft]];
  [_VHID setButton:15 pressed:[controller DPadRight]];
  
  [_VHID setButton:16 pressed:[controller xboxButton]];
  
  NSPoint point = NSZeroPoint;
  point.x = [controller leftAnalogX] / ((2 << 14) - 1);
  point.y = [controller leftAnalogY] / ((2 << 14) - 1);
  [_VHID setPointer:0 position:point];
  
  point.x = [controller rightAnalogX] / ((2 << 14) - 1);
  point.y = [controller rightAnalogY] / ((2 << 14) - 1);
  [_VHID setPointer:1 position:point];
  
  if ([_controller analogTriggers]) {
    point.x = [controller leftTrigger] / ((2 << 9) - 1);
    point.y = [controller rightTrigger] / ((2 << 9) - 1);
    [_VHID setPointer:2 position:point];
  } else {
    [_VHID setPointer:2 position:NSZeroPoint];
  }
}

#pragma mark - Interface Builder Methods

- (IBAction)toggleConnection:(NSButton *)sender {
  if (!_controller) {
    _controller = [[GAXboxController alloc] init];
    [_controller setAnalogTriggers:([_triggerButton selectedSegment] == 0)];
    [_controller setDelegate:self];
  }
  
  [_controller isConnected] ? [_controller disconnect] : [_controller connect];
}

- (IBAction)triggerMode:(NSSegmentedControl *)sender {
  [_controller setAnalogTriggers:([sender selectedSegment] == 0)];
}

@end
