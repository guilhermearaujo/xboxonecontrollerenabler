//
//  GAXboxController.m
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 28/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

#import "GAXboxController.h"
#import "GAXboxControllerCommunication.h"

@interface GAXboxController () <GAXboxControllerCommunicationDelegate>

@property (strong, nonatomic) GAXboxControllerCommunication *communication;
@property (nonatomic) XboxOneButtonMap buttonMap;

@end

@implementation GAXboxController

@synthesize buttonMap;
@synthesize communication;

#pragma mark - Object Life Cycle

- (id)init {
  self = [super init];
  
  _analogTriggers = YES;
  
  communication = [[GAXboxControllerCommunication alloc] init];
  [communication setDelegate:self];
  
  return self;
}

#pragma mark - Connection Management

- (void)connect {
  int r;
  if ((r = [communication searchForDevices]))
    [_delegate controllerConnectionFailed:self withError:@"Device not found." errorCode:r];
  
  else if ((r = [communication openDevice]))
    [_delegate controllerConnectionFailed:self withError:@"Could not open device." errorCode:r];

  else if ((r = [communication configureInterfaceParameters]))
    [_delegate controllerConnectionFailed:self withError:@"Could not configure device." errorCode:r];
  
  else if ((r = [communication initializeController]))
    [_delegate controllerConnectionFailed:self withError:@"Could not initialize device." errorCode:r];
  
  else {
    [_delegate controllerDidConnect:self];
    _connected = YES;
  }
}

- (void)disconnect {
  [self stopPolling];
  [communication closeDevice];
  _connected = NO;
  [_delegate controllerDidDisconnect:self];
}

- (void)startPolling {
  [communication startPollingController];
}

- (void)stopPolling {
  [communication stopPollingController];
}

#pragma mark - Xbox Controller Communication Delegate Method

- (void)controllerDidUpdateData:(XboxOneButtonMap)data {
  buttonMap = data;
  [_delegate controllerDidUpdateData:self];
}

#pragma mark - Buttons & Axes Outputs

- (int)DPadUp{ return buttonMap.dpad_up; }

- (int)DPadDown { return buttonMap.dpad_down; }

- (int)DPadRight { return buttonMap.dpad_right; }

- (int)DPadLeft { return buttonMap.dpad_left; }

- (int)A { return buttonMap.a; }

- (int)B { return buttonMap.b; }

- (int)X { return buttonMap.x; }

- (int)Y { return buttonMap.y; }

- (int)leftBumper { return buttonMap.bumper_left; }

- (int)rightBumper { return buttonMap.bumper_right; }

- (int)leftAnalogButton { return buttonMap.stick_left_click; }

- (int)rightAnalogButton { return buttonMap.stick_right_click; }

- (int)back { return buttonMap.view; }

- (int)menu { return buttonMap.menu; }

- (int)xboxButton { return buttonMap.home; }

- (double)leftAnalogX { return buttonMap.stick_left_x; }

- (double)leftAnalogY { return buttonMap.stick_left_y; }

- (double)rightAnalogX { return buttonMap.stick_right_x; }

- (double)rightAnalogY { return buttonMap.stick_right_y; }

- (double)leftTrigger {
  return _analogTriggers ? buttonMap.trigger_left :
          buttonMap.trigger_left > 0 ? 1023 : 0;
}

- (double)rightTrigger {
  return _analogTriggers ? buttonMap.trigger_right :
          buttonMap.trigger_right > 0 ? 1023 : 0;
}

@end
