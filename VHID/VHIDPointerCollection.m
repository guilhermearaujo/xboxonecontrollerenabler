//
//  VHIDPointerCollection.m
//  VHID
//
//  Created by alxn1 on 23.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "VHIDPointerCollection.h"

#define HIDStatePointerSize                     2

#define HIDDescriptorBaseSize                   12
#define HIDDescriptorPointerCoordinateBase      0x30
#define HIDDescriptorPointerCoordinateBase2     0x40

#define HIDDescriptorMaxPointersBase            3
#define HIDDescriptorMaxPointersBase2           3

@implementation VHIDPointerCollection

+ (float)clipCoordinateFrom:(float)value
{
    value /= 127.0f;

    if(value < -1.0f)
        value = -1.0f;

    if(value > 1.0f)
        value = 1.0f;

    return value;
}

+ (float)clipCoordinateTo:(float)value
{
    value *= 127.0f;

    if(value < -127.0f)
        value = -127.0f;

    if(value > 127.0f)
        value = 127.0f;

    return value;
}

+ (unsigned char)translatePointerCoordinateIndex:(NSUInteger)pointerCoordinateIndex
{
    if(pointerCoordinateIndex < (HIDDescriptorMaxPointersBase * 2))
        return (HIDDescriptorPointerCoordinateBase + pointerCoordinateIndex);

    pointerCoordinateIndex -= HIDDescriptorMaxPointersBase * 2;
    if(pointerCoordinateIndex < (HIDDescriptorMaxPointersBase2 * 2))
        return (HIDDescriptorPointerCoordinateBase2 + pointerCoordinateIndex);

    return 255;
}

+ (NSData*)descriptorWithPointerCount:(NSUInteger)pointerCount
                           isRelative:(BOOL)isRelative
                            stateSize:(NSUInteger*)stateSize
{
    if(stateSize != NULL)
        *stateSize = pointerCount * HIDStatePointerSize;

    NSUInteger       reportLength       = HIDDescriptorBaseSize + pointerCount * 4;
    NSMutableData   *result             = [NSMutableData dataWithLength:reportLength];
    unsigned char   *data               = (unsigned char*)[result mutableBytes];
    NSUInteger       countCoordinates   = pointerCount * 2;
    unsigned char    coordinateIndex;

    *data = 0x05; data++; *data = 0x01; data++;                         //  USAGE_PAGE (Generic Desktop)
    for(NSUInteger i = 0; i < countCoordinates; i++)
    {
        coordinateIndex = [VHIDPointerCollection translatePointerCoordinateIndex:i];
        *data = 0x09; data++; *data = coordinateIndex; data++;          //  USAGE (X (Vx) + coordinate_index)
    }

    *data = 0x15; data++; *data = 0x81;                         data++; //  LOGICAL_MINIMUM (-127)
    *data = 0x25; data++; *data = 0x7f;                         data++; //  LOGICAL_MAXIMUM (127)
    *data = 0x75; data++; *data = 0x08;                         data++; //  REPORT_SIZE (8)
    *data = 0x95; data++; *data = pointerCount * 2;             data++; //  REPORT_COUNT (pointerCount * 2)
    *data = 0x81; data++; *data = ((isRelative)?(0x06):(0x02)); data++; //  INPUT (Data,Var,Rel/Abs)

    return result;
}

+ (NSUInteger)maxPointerCount
{
    return (HIDDescriptorMaxPointersBase + HIDDescriptorMaxPointersBase2);
}

- (id)init
{
    [[super init] release];
    return nil;
}

- (id)initWithPointerCount:(NSUInteger)pointerCount isRelative:(BOOL)isRelative
{
    self = [super init];
    if(self == nil)
        return nil;

    if(pointerCount == 0 ||
       pointerCount > [VHIDPointerCollection maxPointerCount])
    {
        [self release];
        return nil;
    }

    NSUInteger stateSize = 0;

    m_PointerCount  = pointerCount;
    m_IsRelative    = isRelative;
    m_Descriptor    = [[VHIDPointerCollection descriptorWithPointerCount:pointerCount
                                                              isRelative:isRelative
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

- (BOOL)isRelative
{
    return m_IsRelative;
}

- (NSUInteger)pointerCount
{
    return m_PointerCount;
}

- (NSPoint)pointerPosition:(NSUInteger)pointerIndex
{
    if(pointerIndex >= m_PointerCount)
        return NSZeroPoint;

    char *data = (char*)[m_State mutableBytes] + pointerIndex * HIDStatePointerSize;

    return NSMakePoint(
                 [VHIDPointerCollection clipCoordinateFrom:*data],
                -[VHIDPointerCollection clipCoordinateFrom:*(data + 1)]);
}

- (void)setPointer:(NSUInteger)pointerIndex position:(NSPoint)position
{
    if(pointerIndex >= m_PointerCount)
        return;

    char *data = (char*)[m_State mutableBytes] + pointerIndex * HIDStatePointerSize;

    *data       =  [VHIDPointerCollection clipCoordinateTo:position.x];
    *(data + 1) = -[VHIDPointerCollection clipCoordinateTo:position.y];
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
