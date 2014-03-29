//
//  VHIDButtonCollection.m
//  VHID
//
//  Created by alxn1 on 23.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "VHIDButtonCollection.h"

#define HIDDescriptorSizeWithPadding    22
#define HIDDescriptorSizeWithoutPadding 16

static const unsigned char buttonMasks[] =
{
    1, 2, 4, 8, 16, 32, 64, 128
};

@implementation VHIDButtonCollection

+ (NSData*)descriptorWithButtonCount:(NSUInteger)buttonCount
                           stateSize:(NSUInteger*)stateSize
{
    NSUInteger       paddingBits    = (8 - buttonCount % 8) % 8;
    NSMutableData   *result         = [NSMutableData dataWithCapacity:HIDDescriptorSizeWithPadding];

    if(stateSize != NULL)
        *stateSize = (buttonCount + paddingBits) / 8;

    [result setLength:((paddingBits == 0)?
                            (HIDDescriptorSizeWithoutPadding):
                            (HIDDescriptorSizeWithPadding))];

    unsigned char *data = (unsigned char*)[result mutableBytes];

    *data = 0x05; data++; *data = 0x09;         data++; //  USAGE_PAGE (Button)
    *data = 0x19; data++; *data = 0x01;         data++; //  USAGE_MINIMUM (Button 1)
    *data = 0x29; data++; *data = buttonCount;  data++; //  USAGE_MAXIMUM (Button buttonCount)
    *data = 0x15; data++; *data = 0x00;         data++; //  LOGICAL_MINIMUM (0)
    *data = 0x25; data++; *data = 0x01;         data++; //  LOGICAL_MAXIMUM (1)
    *data = 0x95; data++; *data = buttonCount;  data++; //  REPORT_COUNT (buttonCount)
    *data = 0x75; data++; *data = 0x01;         data++; //  REPORT_SIZE (1)
    *data = 0x81; data++; *data = 0x02;         data++; //  INPUT (Data, Var, Abs)

    if(paddingBits == 0)
        return result;

    *data = 0x95; data++; *data = 0x1;          data++; //  REPORT_COUNT (1)
    *data = 0x75; data++; *data = paddingBits;  data++; //  REPORT_SIZE (paddingBits)
    *data = 0x81; data++; *data = 0x03;         data++; //  INPUT (Cnst, Var, Abs)

    return result;
}

+ (NSUInteger)maxButtonCount
{
    return 255;
}

- (id)init
{
    [[super init] release];
    return nil;
}

- (id)initWithButtonCount:(NSUInteger)buttonCount
{
    self = [super init];
    if(self == nil)
        return nil;

    if(buttonCount == 0 ||
       buttonCount > [VHIDButtonCollection maxButtonCount])
    {
        [self release];
        return nil;
    }

    NSUInteger stateSize = 0;

    m_ButtonCount   = buttonCount;
    m_Descriptor    = [[VHIDButtonCollection descriptorWithButtonCount:buttonCount
                                                             stateSize:&stateSize] retain];

    m_State         = [[NSMutableData alloc] initWithLength:stateSize];

    [self reset];

    return self;
}

- (void)dealloc
{
    [m_Descriptor release];
    [m_State release];
    [super dealloc];
}

- (NSUInteger)buttonCount
{
    return m_ButtonCount;
}

- (BOOL)isButtonPressed:(NSUInteger)buttonIndex
{
    if(buttonIndex >= m_ButtonCount)
        return NO;

    NSUInteger       buttonByte = buttonIndex / 8;
    NSUInteger       buttonBit  = buttonIndex % 8;
    unsigned char   *data       = (unsigned char*)[m_State mutableBytes];

    return ((data[buttonByte] & buttonMasks[buttonBit]) != 0);
}

- (void)setButton:(NSUInteger)buttonIndex pressed:(BOOL)pressed
{
    if(buttonIndex >= m_ButtonCount)
        return;

    NSUInteger       buttonByte = buttonIndex / 8;
    NSUInteger       buttonBit  = buttonIndex % 8;
    unsigned char   *data       = (unsigned char*)[m_State mutableBytes];

    if(pressed)
        data[buttonByte] |= buttonMasks[buttonBit];
    else
        data[buttonByte] &= ~(buttonMasks[buttonBit]);
}

- (void)reset
{
    memset([m_State mutableBytes], 0, [m_State length]);
}

- (NSData*)descriptor
{
    return [[m_Descriptor retain] autorelease];
}

- (NSData*)state
{
    return [[m_State retain] autorelease];
}

@end
