//
//  WJoyDevice.h
//  driver
//
//  Created by alxn1 on 17.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WJoyDeviceImpl;

FOUNDATION_EXTERN NSString *WJoyDeviceVendorIDKey;           // NSNumber (NSUInteger as uint32_t)
FOUNDATION_EXTERN NSString *WJoyDeviceProductIDKey;          // NSNumber (NSUInteger as uint32_t)
FOUNDATION_EXTERN NSString *WJoyDeviceProductStringKey;      // NSString
FOUNDATION_EXTERN NSString *WJoyDeviceSerialNumberStringKey; // NSString

@interface WJoyDevice : NSObject
{
    @private
        WJoyDeviceImpl *m_Impl;
        NSDictionary   *m_Properties;
}

+ (BOOL)prepare;

- (id)initWithHIDDescriptor:(NSData*)HIDDescriptor;
- (id)initWithHIDDescriptor:(NSData*)HIDDescriptor productString:(NSString*)productString;
- (id)initWithHIDDescriptor:(NSData*)HIDDescriptor properties:(NSDictionary*)properties;

- (NSDictionary*)properties;

- (BOOL)updateHIDState:(NSData*)HIDState;

@end
