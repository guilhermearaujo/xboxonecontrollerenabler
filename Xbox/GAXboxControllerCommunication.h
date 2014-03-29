//
//  GAXboxControllerCommunication.h
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 28/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XboxOneButtonMap.h"

@protocol GAXboxControllerCommunicationDelegate <NSObject>

- (void)controllerDidUpdateData:(XboxOneButtonMap)data;

@end

@interface GAXboxControllerCommunication : NSObject

@property (weak, nonatomic) id<GAXboxControllerCommunicationDelegate> delegate;

- (int)searchForDevices;
- (int)openDevice;
- (int)configureInterfaceParameters;
- (int)initializeController;
- (void)closeDevice;
- (void)startPollingController;
- (void)stopPollingController;

@end
