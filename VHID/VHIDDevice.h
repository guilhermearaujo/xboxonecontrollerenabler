//
//  VHIDDevice.h
//  VHID
//
//  Created by alxn1 on 23.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    VHIDDeviceTypeMouse,
    VHIDDeviceTypeJoystick
} VHIDDeviceType;

@class VHIDDevice;
@class VHIDButtonCollection;
@class VHIDPointerCollection;

@protocol VHIDDeviceDelegate

- (void)VHIDDevice:(VHIDDevice*)device stateChanged:(NSData*)state;

@end

@interface VHIDDevice : NSObject
{
    @private
        VHIDDeviceType           m_Type;
        VHIDButtonCollection    *m_Buttons;
        VHIDPointerCollection   *m_Pointers;
        NSData                  *m_Descriptor;
        NSMutableData           *m_State;

        id<VHIDDeviceDelegate>   m_Delegate;
}

+ (NSUInteger)maxButtonCount;
+ (NSUInteger)maxPointerCount;

- (id)initWithType:(VHIDDeviceType)type
      pointerCount:(NSUInteger)pointerCount
       buttonCount:(NSUInteger)buttonCount
        isRelative:(BOOL)isRelative;

- (VHIDDeviceType)type;

- (BOOL)isRelative;
- (NSUInteger)buttonCount;
- (NSUInteger)pointerCount;

- (BOOL)isButtonPressed:(NSUInteger)buttonIndex;
- (void)setButton:(NSUInteger)buttonIndex pressed:(BOOL)pressed;

// [-1, +1] ;)
- (NSPoint)pointerPosition:(NSUInteger)pointerIndex;
- (void)setPointer:(NSUInteger)pointerIndex position:(NSPoint)position;

- (void)reset;

- (NSData*)descriptor;
- (NSData*)state;

- (id<VHIDDeviceDelegate>)delegate;
- (void)setDelegate:(id<VHIDDeviceDelegate>)obj;

@end
