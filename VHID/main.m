//
//  main.m
//  VHID
//
//  Created by alxn1 on 24.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VHIDDevice;

@protocol VHIDDeviceDelegate

- (void)VHIDDevice:(VHIDDevice*)device stateChanged:(NSData*)state;

@end

@interface VHIDDevice : NSObject
{
    @private
        NSData                  *m_Descriptor;
        NSMutableData           *m_State;
        id<VHIDDeviceDelegate>   m_Delegate;
}

- (NSData*)descriptor;
- (NSData*)state;

- (void)reset;

- (id<VHIDDeviceDelegate>)delegate;
- (void)setDelegate:(id<VHIDDeviceDelegate>)obj;

@end

typedef enum VHIDMouseButtonType {
    VHIDMouseButtonTypeLeft,
    VHIDMouseButtonTypeCenter,
    VHIDMouseButtonTypeRight
} VHIDMouseButtonType;

@interface VHIDMouse : VHIDDevice

- (BOOL)isButtonPressed:(VHIDMouseButtonType)button;
- (void)setButton:(VHIDMouseButtonType)button pressed:(BOOL)pressed;

- (void)updatePosition:(NSPoint)delta;

@end

@interface VHIDKeyboard : VHIDDevice

@end

typedef enum VHIDJoystickAxisType {
    VHIDJoystickAxisTypeX,
    VHIDJoystickAxisTypeY,
    VHIDJoystickAxisTypeZ,
    VHIDJoystickAxisTypeRX,
    VHIDJoystickAxisTypeRY,
    VHIDJoystickAxisTypeRZ
} VHIDJoystickAxisType;

typedef enum VHIDJoystickAxisValueType {
    VHIDJoystickAxisValueType8Bit,
    VHIDJoystickAxisValueType16Bit
} VHIDJoystickAxisValueType;

@interface VHIDJoystickAxisSet : NSObject

- (NSUInteger)count;
- (BOOL)isContain:(VHIDJoystickAxisType)axis;
- (VHIDJoystickAxisValueType)valueType:(VHIDJoystickAxisType)axis;

@end

@interface VHIDMutableJoystickAxisSet : VHIDJoystickAxisSet

- (void)add:(VHIDJoystickAxisType)axis valueType:(VHIDJoystickAxisValueType)valueType;
- (void)remove:(VHIDJoystickAxisType)axis;

@end

#define VHIDJoystickMaxButtonCount 255

@interface VHIDJoystick : VHIDDevice

- (id)initWithButtonCount:(NSUInteger)buttonCount
                     axes:(VHIDJoystickAxisSet*)axes;

- (NSUInteger)buttonCount;
- (VHIDJoystickAxisSet*)axes;

- (BOOL)isButtonPressed:(NSUInteger)button;
- (void)setButton:(NSUInteger)button pressed:(BOOL)pressed;

- (CGFloat)axisValue:(VHIDJoystickAxisType)axis;
- (void)setAxis:(VHIDJoystickAxisType)axis value:(CGFloat)value;

@end

@interface VHIDXBox360Joystick : VHIDJoystick

@end

int main(int argC, char *argV[])
{
    return NSApplicationMain(argC, (const char**)argV);
}
