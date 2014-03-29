//
//  WJoyDeviceImpl.m
//  driver
//
//  Created by alxn1 on 17.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WJoyDeviceImpl.h"
#import "WJoyTool.h"

#define WJoyDeviceDriverID @"com_alxn1_driver_WirtualJoy"

@interface WJoyDeviceImpl (PrivatePart)

+ (void)registerAtExitCallback;

+ (io_service_t)findService;
+ (io_connect_t)createNewConnection;

+ (BOOL)isDriverLoaded;
+ (BOOL)loadDriver;
+ (BOOL)unloadDriver;

@end

@implementation WJoyDeviceImpl

+ (BOOL)prepare
{
    if(![WJoyDeviceImpl loadDriver])
        return NO;

    [WJoyDeviceImpl registerAtExitCallback];
    return YES;
}

- (id)init
{
    self = [super init];
    if(self == nil)
        return nil;

    if(![WJoyDeviceImpl prepare])
    {
        [self release];
        return nil;
    }

    m_Connection = [WJoyDeviceImpl createNewConnection];
    if(m_Connection == IO_OBJECT_NULL)
    {
        [self release];
        return nil;
    }

    return self;
}

- (void)dealloc
{
    if(m_Connection != IO_OBJECT_NULL)
        IOServiceClose(m_Connection);

    [super dealloc];
}

- (BOOL)call:(WJoyDeviceMethodSelector)selector
{
    return [self call:selector data:nil];
}

- (BOOL)call:(WJoyDeviceMethodSelector)selector data:(NSData*)data
{
    return (IOConnectCallMethod(
                            m_Connection,
                            selector,
                            NULL,
                            0,
                            [data bytes],
                            [data length],
                            NULL,
                            NULL,
                            NULL,
                            NULL) == KERN_SUCCESS);
}

- (BOOL)call:(WJoyDeviceMethodSelector)selector string:(NSString*)string
{
    const char *data = [string UTF8String];
    size_t      size = strlen(data) + 1; // zero-terminator

    return [self call:selector data:[NSData dataWithBytes:data length:size]];
}

@end

@implementation WJoyDeviceImpl (Methods)

- (BOOL)setDeviceProductString:(NSString*)string
{
    return [self call:WJoyDeviceMethodSelectorSetDeviceProductString string:string];
}

- (BOOL)setDeviceSerialNumberString:(NSString*)string
{
    return [self call:WJoyDeviceMethodSelectorSetDeviceSerialNumberString string:string];
}

- (BOOL)setDeviceVendorID:(uint32_t)vendorID productID:(uint32_t)productID
{
    char data[sizeof(uint32_t) * 2] = { 0 };

    memcpy(data, vendorID, sizeof(uint32_t));
    memcpy(data + sizeof(uint32_t), productID, sizeof(uint32_t));

    return [self call:WJoyDeviceMethodSelectorSetDeviceVendorAndProductID
                 data:[NSData dataWithBytes:data length:sizeof(data)]];
}

- (BOOL)enable:(NSData*)HIDDescriptor
{
    return [self call:WJoyDeviceMethodSelectorEnable data:HIDDescriptor];
}

- (BOOL)disable
{
    return [self call:WJoyDeviceMethodSelectorDisable];
}

- (BOOL)updateState:(NSData*)HIDState
{
    return [self call:WJoyDeviceMethodSelectorUpdateState data:HIDState];
}

@end

@implementation WJoyDeviceImpl (PrivatePart)

static void onApplicationExit(void)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [WJoyDeviceImpl unloadDriver];
    [pool release];
}

+ (void)registerAtExitCallback
{
    static BOOL isRegistred = NO;

    if(isRegistred)
        return;

    atexit(onApplicationExit);
    isRegistred = YES;
}

+ (io_service_t)findService
{
    io_service_t	result = IO_OBJECT_NULL;
    io_iterator_t 	iterator;

    if(IOServiceGetMatchingServices(
                                 kIOMasterPortDefault,
                                 IOServiceMatching([WJoyDeviceDriverID UTF8String]),
                                &iterator) != KERN_SUCCESS)
    {
        return result;
    }
    
    result = IOIteratorNext(iterator);
    IOObjectRelease(iterator);
    return result;
}

+ (io_connect_t)createNewConnection
{
    io_connect_t result    = IO_OBJECT_NULL;
    io_service_t service   = [WJoyDeviceImpl findService];

    if(service == IO_OBJECT_NULL)
        return result;

    if(IOServiceOpen(service, mach_task_self(), 0, &result) != KERN_SUCCESS)
        result = IO_OBJECT_NULL;

    IOObjectRelease(service);
    return result;
}

+ (BOOL)isDriverLoaded
{
    io_service_t service = [WJoyDeviceImpl findService];
    BOOL         result  = (service != IO_OBJECT_NULL);

    IOObjectRelease(service);
    return result;
}

+ (BOOL)loadDriver
{
    if([self isDriverLoaded])
        return YES;

    return [WJoyTool loadDriver];
}

+ (BOOL)unloadDriver
{
    if(![self isDriverLoaded])
        return YES;

    return [WJoyTool unloadDriver];
}

@end
