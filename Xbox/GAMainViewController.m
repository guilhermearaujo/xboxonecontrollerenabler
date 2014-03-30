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

typedef enum {
  Disconnected,
  Ready
} StatusID;

@interface GAMainViewController () <GAXboxControllerDelegate, VHIDDeviceDelegate>

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
@property (strong, nonatomic) IBOutlet NSButton *calibrationButton;
@property (strong) IBOutlet NSButton *resetButton;
@property (strong, nonatomic) IBOutlet NSSegmentedControl *triggerButton;
@property (strong, nonatomic) IBOutlet NSTextField *statusLabel;

@property (strong, nonatomic) GAXboxController *controller;
@property (strong, nonatomic) VHIDDevice *VHID;
@property (strong, nonatomic) WJoyDevice *virtualDevice;

@property (nonatomic) BOOL isCalibrating;
@property (nonatomic) StatusID statusID;

- (IBAction)toggleConnection:(NSButton *)sender;
- (IBAction)startCalibration:(NSButton *)sender;
- (IBAction)triggerMode:(NSSegmentedControl *)sender;
- (IBAction)resetCalibration:(NSButton *)sender;

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
    _statusID = Disconnected;
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
  
  _statusID = Ready;
  
  [_statusLabel setStringValue:@"Controller connected."];
  [self executeBlock:^{
    [self setStatus];
  } after:1.5];
  
  [_radioMatrix setEnabled:YES];
  [_calibrationButton setEnabled:YES];
  [_resetButton setEnabled:YES];
}

- (void)controllerDidDisconnect:(GAXboxController *)controller {
  [_connectButton setTitle:@"Connect"];
  [_triggerButton setEnabled:NO];
  [_calibrationButton setEnabled:NO];
  [_resetButton setEnabled:NO];
  
  _statusID = Disconnected;
  [self setStatus];
  
  _VHID = nil;
  _controller = nil;
  
  [self cleanUI];
}

- (void)controllerDidUpdateData:(GAXboxController *)controller {
  [self performSelectorInBackground:@selector(updateVHID:) withObject:controller];
  
  if (!_isCalibrating)
    [self performSelectorInBackground:@selector(updateUI:) withObject:controller];
  
  else if ([controller A] || [controller DPadUp]    || [controller leftBumper]  ||
           [controller B] || [controller DPadDown]  || [controller rightBumper] ||
           [controller X] || [controller DPadLeft]  || [controller view]        ||
           [controller Y] || [controller DPadRight] || [controller menu])
    _isCalibrating = NO;
}

- (void)controllerConnectionFailed:(GAXboxController *)controller withError:(NSString *)error errorCode:(int)code {
  [_statusLabel setStringValue:[NSString stringWithFormat:@"Error: %@ (code %d)", error, code]];
  [self executeBlock:^ {
    [self setStatus];
  } after:1.5];
}

#pragma mark - VHID Delegate Method

- (void)VHIDDevice:(VHIDDevice *)device stateChanged:(NSData *)state {
  [_virtualDevice updateHIDState:state];
}

#pragma mark - UI Management

- (void)cleanUI {
  [_radioMatrix deselectAllCells];
  [_radioMatrix setEnabled:NO];
  [_progressRightAnalogX setDoubleValue:-1];
  [_progressRightAnalogY setDoubleValue:-1];
  [_progressLeftAnalogX  setDoubleValue:-1];
  [_progressLeftAnalogY  setDoubleValue:-1];
  [_progressRightTrigger setDoubleValue:0];
  [_progressLeftTrigger  setDoubleValue:0];
}

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
  
  [_radioView setIntegerValue:[controller view]];
  [_radioMenu setIntegerValue:[controller menu]];
  
  [_progressLeftAnalogX  setDoubleValue:[controller leftAnalogX]];
  [_progressLeftAnalogY  setDoubleValue:[controller leftAnalogY]];
  [_progressRightAnalogX setDoubleValue:[controller rightAnalogX]];
  [_progressRightAnalogY setDoubleValue:[controller rightAnalogY]];
  [_progressRightTrigger setDoubleValue:[controller rightTrigger]];
  [_progressLeftTrigger  setDoubleValue:[controller leftTrigger]];
}

- (void)setStatus {
  NSString *status;
  
  switch (_statusID) {
    case Disconnected:
      status = @"Controller disconnected.";
      break;
      
    case Ready:
      status = @"Ready to use.";
      break;
  }
  
  [_statusLabel setStringValue:status];
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
  
  [_VHID setButton:8 pressed:[controller view]];
  [_VHID setButton:9 pressed:[controller menu]];
  
  [_VHID setButton:10 pressed:[controller leftAnalogButton]];
  [_VHID setButton:11 pressed:[controller rightAnalogButton]];
  
  [_VHID setButton:12 pressed:[controller DPadUp]];
  [_VHID setButton:13 pressed:[controller DPadDown]];
  [_VHID setButton:14 pressed:[controller DPadLeft]];
  [_VHID setButton:15 pressed:[controller DPadRight]];
  
  [_VHID setButton:16 pressed:[controller xboxButton]];
  
  NSPoint point = NSZeroPoint;
  point.x = [controller leftAnalogX];
  point.y = [controller leftAnalogY];
  [_VHID setPointer:0 position:point];
  
  point.x = [controller rightAnalogX];
  point.y = [controller rightAnalogY];
  [_VHID setPointer:1 position:point];
  
  if ([_controller analogTriggers]) {
    point.x = [controller leftTrigger];
    point.y = [controller rightTrigger];
    [_VHID setPointer:2 position:point];
  } else {
    [_VHID setPointer:2 position:NSZeroPoint];
  }
}

#pragma mark - Interface Builder Methods

- (IBAction)toggleConnection:(NSButton *)sender {
  if (!_controller) {
    _controller = [[GAXboxController alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Offset"]) {
      [_controller setLeftAnalogXOffset:[[NSUserDefaults standardUserDefaults] floatForKey:@"Offset_LX"]];
      [_controller setLeftAnalogYOffset:[[NSUserDefaults standardUserDefaults] floatForKey:@"Offset_LY"]];
      [_controller setRightAnalogXOffset:[[NSUserDefaults standardUserDefaults] floatForKey:@"Offset_RX"]];
      [_controller setRightAnalogYOffset:[[NSUserDefaults standardUserDefaults] floatForKey:@"Offset_RY"]];
    }
    
    [_controller setAnalogTriggers:([_triggerButton selectedSegment] == 0)];
    [_controller setDelegate:self];
  }
  
  [_controller isConnected] ? [_controller disconnect] : [_controller connect];
}

- (IBAction)startCalibration:(NSButton *)sender {
  [_calibrationButton setTitle:@"Calibrating"];
  [_calibrationButton setEnabled:NO];
  [_resetButton setEnabled:NO];
  
  [self resetCalibration:nil];
  
  [_statusLabel setStringValue:@"Move both analog sticks in circles. Then release them and press any button."];
  
  _isCalibrating = YES;
  [self performSelectorInBackground:@selector(calibrate) withObject:nil];
}

- (IBAction)triggerMode:(NSSegmentedControl *)sender {
  [_controller setAnalogTriggers:([sender selectedSegment] == 0)];
}

- (IBAction)resetCalibration:(NSButton *)sender {
  [_controller setLeftAnalogXOffset:0];
  [_controller setLeftAnalogYOffset:0];
  [_controller setRightAnalogXOffset:0];
  [_controller setRightAnalogYOffset:0];
  
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Offset"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Offset_LX"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Offset_LY"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Offset_RX"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Offset_RY"];

  if (sender) {
    [_statusLabel setStringValue:@"Calibration reset."];
    [self executeBlock:^{
      [self setStatus];
    } after:1.5];
  }
}

#pragma mark - Calibration

- (void)calibrate {
  float minLX = 0, minLY = 0, minRX = 0, minRY = 0,
  maxLX = 0, maxLY = 0, maxRX = 0, maxRY = 0;
  
  while (_isCalibrating) {
    if (_controller.leftAnalogX < minLX)
      minLX = _controller.leftAnalogX;
    
    if (_controller.leftAnalogY < minLY)
      minLY = _controller.leftAnalogY;
    
    if (_controller.rightAnalogX < minRX)
      minRX = _controller.rightAnalogX;
    
    if (_controller.rightAnalogY < minRY)
      minRY = _controller.rightAnalogY;
    
    
    if (_controller.leftAnalogX > maxLX)
      maxLX = _controller.leftAnalogX;
    
    if (_controller.leftAnalogY > maxLY)
      maxLY = _controller.leftAnalogY;
    
    if (_controller.rightAnalogX > maxRX)
      maxRX = _controller.rightAnalogX;
    
    if (_controller.rightAnalogY > maxRY)
      maxRY = _controller.rightAnalogY;
  }
  
  [_controller setLeftAnalogXOffset:(maxLX + minLX) / 2];
  [_controller setLeftAnalogYOffset:(maxLY + minLY) / 2];
  [_controller setRightAnalogXOffset:(maxRX + minRX) / 2];
  [_controller setRightAnalogYOffset:(maxRY + minRY) / 2];
  
  [_statusLabel setStringValue:@"Calibration completed."];
  [self executeBlock:^{
    [self setStatus];
  } after:1.5];
  
  [_calibrationButton setTitle:@"Calibrate"];
  [_calibrationButton setEnabled:YES];
  [_resetButton setEnabled:YES];
  
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Offset"];
  [[NSUserDefaults standardUserDefaults] setFloat:(maxLX + minLX) / 2 forKey:@"Offset_LX"];
  [[NSUserDefaults standardUserDefaults] setFloat:(maxLY + minLY) / 2 forKey:@"Offset_LY"];
  [[NSUserDefaults standardUserDefaults] setFloat:(maxRX + minRX) / 2 forKey:@"Offset_RX"];
  [[NSUserDefaults standardUserDefaults] setFloat:(maxRY + minRY) / 2 forKey:@"Offset_RY"];
}

#pragma mark - Utils

- (void) executeBlock:(void (^)(void))block after:(NSTimeInterval)seconds {
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@end
