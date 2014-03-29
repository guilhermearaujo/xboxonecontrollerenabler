//
//  VHIDDevice.m
//  VHID
//
//  Created by alxn1 on 23.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "VHIDDevice.h"
#import "VHIDButtonCollection.h"
#import "VHIDPointerCollection.h"

#define HIDDescriptorMouseAdditionalBytes       12
#define HIDDescriptorJoystickAdditionalBytes    10

@interface VHIDDevice (PrivatePart)

- (NSData*)createDescriptor;

@end

@implementation VHIDDevice

+ (NSUInteger)maxButtonCount
{
    return [VHIDButtonCollection maxButtonCount];
}

+ (NSUInteger)maxPointerCount
{
    return [VHIDPointerCollection maxPointerCount];
}

- (id)init
{
    [[super init] release];
    return nil;
}

- (id)initWithType:(VHIDDeviceType)type
      pointerCount:(NSUInteger)pointerCount
       buttonCount:(NSUInteger)buttonCount
        isRelative:(BOOL)isRelative
{
    self = [super init];

    m_Type      = type;
    m_Buttons   = [[VHIDButtonCollection alloc] initWithButtonCount:buttonCount];
    m_Pointers  = [[VHIDPointerCollection alloc] initWithPointerCount:pointerCount
                                                           isRelative:isRelative];

    m_State     = [[NSMutableData alloc]
                                initWithLength:
                                    [[m_Buttons state] length] +
                                    [[m_Pointers state] length]];

    if(m_Buttons  == nil || m_Pointers == nil)
    {
        [self release];
        return nil;
    }

    m_Descriptor = [[self createDescriptor] retain];

    return self;
}

- (void)dealloc
{
    [m_Buttons release];
    [m_Pointers release];
    [m_Descriptor release];
    [m_State release];
    [super dealloc];
}

- (VHIDDeviceType)type
{
    return m_Type;
}

- (BOOL)isRelative
{
    if(m_Pointers == nil)
        return NO;

    return [m_Pointers isRelative];
}

- (NSUInteger)buttonCount
{
    return [m_Buttons buttonCount];
}

- (NSUInteger)pointerCount
{
    return [m_Pointers pointerCount];
}

- (BOOL)isButtonPressed:(NSUInteger)buttonIndex
{
    return [m_Buttons isButtonPressed:buttonIndex];
}

- (void)setButton:(NSUInteger)buttonIndex pressed:(BOOL)pressed
{
    if(buttonIndex >= [self buttonCount] ||
       [self isButtonPressed:buttonIndex] == pressed)
    {
        return;
    }

    [m_Buttons setButton:buttonIndex pressed:pressed];

    if(m_Delegate != nil)
        [m_Delegate VHIDDevice:self stateChanged:[self state]];
}

- (NSPoint)pointerPosition:(NSUInteger)pointerIndex
{
    if(m_Pointers == nil)
        return NSZeroPoint;

    return [m_Pointers pointerPosition:pointerIndex];
}

- (void)setPointer:(NSUInteger)pointerIndex position:(NSPoint)position
{
    if(pointerIndex >= [self pointerCount] ||
       NSEqualPoints([self pointerPosition:pointerIndex], position))
    {
        return;
    }

    [m_Pointers setPointer:pointerIndex position:position];

    if(m_Delegate != nil)
        [m_Delegate VHIDDevice:self stateChanged:[self state]];
}

- (void)reset
{
    [m_Buttons reset];
    [m_Pointers reset];

    if(m_Delegate != nil)
        [m_Delegate VHIDDevice:self stateChanged:[self state]];
}

- (NSData*)descriptor
{
    return [[m_Descriptor retain] autorelease];
}

- (NSData*)state
{
    unsigned char   *data           = [m_State mutableBytes];
    NSData          *buttonState    = [m_Buttons state];
    NSData          *pointerState   = [m_Pointers state];

    if(buttonState != nil)
    {
        memcpy(
            data,
            [buttonState bytes],
            [buttonState length]);
    }

    if(pointerState != nil)
    {
        memcpy(
            data + [buttonState length],
            [pointerState bytes],
            [pointerState length]);
    }

    return [[m_State retain] autorelease];
}

- (id<VHIDDeviceDelegate>)delegate
{
    return m_Delegate;
}

- (void)setDelegate:(id<VHIDDeviceDelegate>)obj
{
    m_Delegate = obj;
}

@end

@implementation VHIDDevice (PrivatePart)

- (NSData*)createDescriptor
{
    BOOL             isMouse        = (m_Type == VHIDDeviceTypeMouse);
    NSData          *buttonsHID     = [m_Buttons descriptor];
    NSData          *pointersHID    = [m_Pointers descriptor];
    NSMutableData   *result         = [NSMutableData dataWithLength:
                                                        [buttonsHID length] +
                                                        [pointersHID length] +
                                                        ((isMouse)?
                                                            (HIDDescriptorMouseAdditionalBytes):
                                                            (HIDDescriptorJoystickAdditionalBytes))];

    unsigned char   *data           = [result mutableBytes];
    unsigned char    usage          = ((isMouse)?(0x02):(0x05));

    *data = 0x05; data++; *data = 0x01; data++;      // USAGE_PAGE (Generic Desktop)
    *data = 0x09; data++; *data = usage; data++;     // USAGE (Mouse/Game Pad)
    *data = 0xA1; data++; *data = 0x01; data++;      // COLLECTION (Application)

    if(isMouse)
    {
        *data = 0x09; data++; *data = 0x01; data++;  // USAGE (Pointer)
    }

    *data = 0xA1; data++; *data = 0x00; data++;      // COLLECTION (Physical)

    if(buttonsHID != nil)
    {
        memcpy(data, [buttonsHID bytes], [buttonsHID length]);
        data += [buttonsHID length];
    }

    if(pointersHID != nil)
    {
        memcpy(data, [pointersHID bytes], [pointersHID length]);
        data += [pointersHID length];
    }

    *data = 0xC0; data++; // END_COLLECTION
    *data = 0xC0; data++; // END_COLLECTION

    return result;
}

@end
