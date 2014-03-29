//
//  WJoyDeviceImpl.h
//  driver
//
//  Created by alxn1 on 17.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>

typedef enum
{
    WJoyDeviceMethodSelectorEnable                      = 0,
    WJoyDeviceMethodSelectorDisable                     = 1,
    WJoyDeviceMethodSelectorUpdateState                 = 2,
    WJoyDeviceMethodSelectorSetDeviceProductString      = 3,
    WJoyDeviceMethodSelectorSetDeviceSerialNumberString = 4,
    WJoyDeviceMethodSelectorSetDeviceVendorAndProductID = 5
} WJoyDeviceMethodSelector;

@interface WJoyDeviceImpl : NSObject
{
    @private
        io_connect_t m_Connection;
}

+ (BOOL)prepare;

- (BOOL)call:(WJoyDeviceMethodSelector)selector;
- (BOOL)call:(WJoyDeviceMethodSelector)selector data:(NSData*)data;
- (BOOL)call:(WJoyDeviceMethodSelector)selector string:(NSString*)string;

@end

@interface WJoyDeviceImpl (Methods)

- (BOOL)setDeviceProductString:(NSString*)string;
- (BOOL)setDeviceSerialNumberString:(NSString*)string;
- (BOOL)setDeviceVendorID:(uint32_t)vendorID productID:(uint32_t)productID;

- (BOOL)enable:(NSData*)HIDDescriptor;
- (BOOL)disable;

- (BOOL)updateState:(NSData*)HIDState;

@end
