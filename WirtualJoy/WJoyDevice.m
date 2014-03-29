//
//  WJoyDevice.m
//  driver
//
//  Created by alxn1 on 17.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WJoyDevice.h"

#import "WJoyDeviceImpl.h"

NSString *WJoyDeviceVendorIDKey             = @"WJoyDeviceVendorIDKey";
NSString *WJoyDeviceProductIDKey            = @"WJoyDeviceProductIDKey";
NSString *WJoyDeviceProductStringKey        = @"WJoyDeviceProductStringKey";
NSString *WJoyDeviceSerialNumberStringKey   = @"WJoyDeviceSerialNumberStringKey";

@implementation WJoyDevice

+ (BOOL)prepare
{
    return [WJoyDeviceImpl prepare];
}

- (id)init
{
    [[super init] release];
    return nil;
}

- (id)initWithHIDDescriptor:(NSData*)HIDDescriptor
{
    return [self initWithHIDDescriptor:HIDDescriptor properties:nil];
}

- (id)initWithHIDDescriptor:(NSData*)HIDDescriptor productString:(NSString*)productString
{
    NSDictionary *properties = [NSDictionary
                                        dictionaryWithObject:productString
                                                      forKey:WJoyDeviceProductStringKey];

    return [self initWithHIDDescriptor:HIDDescriptor properties:properties];
}

- (id)initWithHIDDescriptor:(NSData*)HIDDescriptor properties:(NSDictionary*)properties
{
    self = [super init];
    if(self == nil)
        return nil;

    uint32_t     vendorID           = [[properties objectForKey:WJoyDeviceVendorIDKey] unsignedIntegerValue];
    uint32_t     productID          = [[properties objectForKey:WJoyDeviceProductIDKey] unsignedIntegerValue];
    NSString    *productString      = [properties objectForKey:WJoyDeviceProductStringKey];
    NSString    *serialNumberString = [properties objectForKey:WJoyDeviceSerialNumberStringKey];

    m_Impl = [[WJoyDeviceImpl alloc] init];
    if(m_Impl == nil)
    {
        [self release];
        return nil;
    }

    if(productString != nil)
        [m_Impl setDeviceProductString:productString];

    if(serialNumberString != nil)
        [m_Impl setDeviceSerialNumberString:serialNumberString];

    if(vendorID != 0 || productID != 0)
        [m_Impl setDeviceVendorID:vendorID productID:productID];

    if(![m_Impl enable:HIDDescriptor])
    {
        [self release];
        return nil;
    }

    m_Properties = [properties copy];
    return self;
}

- (void)dealloc
{
    [m_Properties release];
    [m_Impl release];
    [super dealloc];
}

- (NSDictionary*)properties
{
    return [[m_Properties retain] autorelease];
}

- (BOOL)updateHIDState:(NSData*)HIDState
{
    return [m_Impl updateState:HIDState];
}

@end
