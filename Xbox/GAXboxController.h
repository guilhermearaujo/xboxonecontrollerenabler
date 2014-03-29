//
//  GAXboxController.h
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 28/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GAXboxControllerDelegate;

@interface GAXboxController : NSObject

@property (nonatomic, getter = isConnected) BOOL connected;
@property (nonatomic) BOOL analogTriggers;
@property (weak, nonatomic) id<GAXboxControllerDelegate> delegate;

- (void)connect;
- (void)disconnect;
- (void)startPolling;
- (void)stopPolling;

- (int)DPadUp;
- (int)DPadDown;
- (int)DPadRight;
- (int)DPadLeft;

- (int)A;
- (int)B;
- (int)X;
- (int)Y;

- (int)leftBumper;
- (int)rightBumper;

- (int)leftAnalogButton;
- (int)rightAnalogButton;

- (int)back;
- (int)menu;
- (int)xboxButton;

- (double)leftAnalogX;
- (double)leftAnalogY;
- (double)rightAnalogX;
- (double)rightAnalogY;

- (double)leftTrigger;
- (double)rightTrigger;

@end

@protocol GAXboxControllerDelegate <NSObject>

- (void)controllerDidConnect:(GAXboxController *)controller;
- (void)controllerDidDisconnect:(GAXboxController *)controller;
- (void)controllerDidUpdateData:(GAXboxController *)controller;
- (void)controllerConnectionFailed:(GAXboxController *)controller withError:(NSString *)error errorCode:(int)code;

@end