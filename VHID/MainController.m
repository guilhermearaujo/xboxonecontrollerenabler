//
//  MainController.m
//  VHID
//
//  Created by alxn1 on 24.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "MainController.h"

@implementation MainController

- (id)init
{
    self = [super init];
    if(self == nil)
        return nil;

    m_MouseState    = [[VHIDDevice alloc] initWithType:VHIDDeviceTypeMouse
                                          pointerCount:6
                                           buttonCount:2
                                            isRelative:YES];

    NSLog(@"%@", m_MouseState);
    m_VirtualMouse  = [[WJoyDevice alloc] initWithHIDDescriptor:[m_MouseState descriptor]
                                                  productString:@"Virtual Alxn1 Mouse"];

    [m_MouseState setDelegate:self];
    if(m_VirtualMouse == nil || m_MouseState == nil)
        NSLog(@"error");

    return self;
}

- (void)dealloc
{
    [m_MouseState release];
    [m_VirtualMouse release];
    [super dealloc];
}

- (void)VHIDDevice:(VHIDDevice*)device stateChanged:(NSData*)state
{
    [m_VirtualMouse updateHIDState:state];
}

- (void)testView:(TestView*)view keyPressed:(TestViewKey)key
{
    NSPoint newPosition = NSZeroPoint;

    switch(key)
    {
        case TestViewKeyUp:
            newPosition.y += 0.025f;
            break;

        case TestViewKeyDown:
            newPosition.y -= 0.025f;
            break;

        case TestViewKeyLeft:
            newPosition.x -= 0.025f;
            break;

        case TestViewKeyRight:
            newPosition.x += 0.025f;
            break;
    }

    [m_MouseState setPointer:0 position:newPosition];
}

@end
