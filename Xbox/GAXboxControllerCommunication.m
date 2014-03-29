//
//  GAXboxControllerCommunication.m
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 28/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

#import "GAXboxControllerCommunication.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/usb/IOUSBLib.h>
#import <IOKit/usb/USBSpec.h>
#import "XboxOneButtonMap.h"

static SInt32 idVendor = 0x045e;
static SInt32 idProduct = 0x02d1;

@interface GAXboxControllerCommunication ()

@property (nonatomic) CFMutableDictionaryRef matchingDictionary;
@property (nonatomic) SInt32 score;
@property (nonatomic) io_iterator_t iterator;
@property (nonatomic) io_service_t usbRef;
@property (nonatomic) IOCFPlugInInterface **plugin;
@property (nonatomic) IOUSBConfigurationDescriptorPtr config;
@property (nonatomic) IOUSBDeviceInterface300 **usbDevice;
@property (nonatomic) IOUSBFindInterfaceRequest interfaceRequest;
@property (nonatomic) IOUSBInterfaceInterface **usbInterface;
@property (nonatomic) IOReturn returnCode;
@property (nonatomic) XboxOneButtonMap buttonMap;
@property (nonatomic) BOOL shouldPoll;

@end

@implementation GAXboxControllerCommunication

@synthesize delegate;

@synthesize matchingDictionary;
@synthesize score;
@synthesize iterator;
@synthesize usbRef;
@synthesize plugin;
@synthesize config;
@synthesize usbDevice;
@synthesize interfaceRequest;
@synthesize usbInterface;
@synthesize returnCode;
@synthesize buttonMap;
@synthesize shouldPoll;

#pragma mark - Object Life Cycle

- (id)init {
  self = [super init];
  matchingDictionary = NULL;
  iterator = 0;
  usbDevice = NULL;
  shouldPoll = NO;
  return self;
}

#pragma mark - Setup

- (int)searchForDevices {
  // Set device
  matchingDictionary = IOServiceMatching(kIOUSBDeviceClassName);
  CFDictionaryAddValue(matchingDictionary, CFSTR(kUSBVendorID), CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &idVendor));
  CFDictionaryAddValue(matchingDictionary, CFSTR(kUSBProductID), CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &idProduct));
  
  // Search for device
  IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDictionary, &iterator);
  usbRef = IOIteratorNext(iterator);
  IOObjectRelease(iterator);
  
  return usbRef > 0 ? 0 : -1;
}

- (int)openDevice {
  if (usbRef == 0) {
    return -1;
  }
  
  // Open device
  IOCreatePlugInInterfaceForService(usbRef, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugin, &score);
  IOObjectRelease(usbRef);
  (*plugin)->QueryInterface(plugin, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID300), (LPVOID)&usbDevice);
  (*plugin)->Release(plugin);
  
  returnCode = (*usbDevice)->USBDeviceOpen(usbDevice);
  
  if (returnCode == kIOReturnSuccess) {
    // Set first configuration as active
    returnCode = (*usbDevice)->GetConfigurationDescriptorPtr(usbDevice, 0, &config);
    if (returnCode != kIOReturnSuccess) {
      return returnCode;
    }
    
    (*usbDevice)->SetConfiguration(usbDevice, config->bConfigurationValue);
    return 0;
  }
  
  else {
    return returnCode;
  }
}

- (int)configureInterfaceParameters {
  // Set interface search parameters
  interfaceRequest.bInterfaceClass = kIOUSBFindInterfaceDontCare;
  interfaceRequest.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;
  interfaceRequest.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
  interfaceRequest.bAlternateSetting = kIOUSBFindInterfaceDontCare;
  (*usbDevice)->CreateInterfaceIterator(usbDevice, &interfaceRequest, &iterator);
  
  // Pick first interface
  usbRef = IOIteratorNext(iterator);
  IOObjectRelease(iterator);
  
  // Open interface
  IOCreatePlugInInterfaceForService(usbRef, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &plugin, &score);
  IOObjectRelease(usbRef);
  (*plugin)->QueryInterface(plugin, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID300), (LPVOID)&usbInterface);
  (*plugin)->Release(plugin);
  
  returnCode = (*usbInterface)->USBInterfaceOpen(usbInterface);
  if (returnCode != kIOReturnSuccess) {
    printf("Could not open interface (error: %x)\n", returnCode);
    return -1;
  }
  
  return 0;
}

#pragma mark - Operation

- (int)initializeController {
  // Send controller initialization data
  char code[] = {0x05, 0x20};
  return (*usbInterface)->WritePipe(usbInterface, 1, code, 2);
}

- (void)closeDevice {
  (*usbInterface)->USBInterfaceClose(usbInterface);
  (*usbDevice)->USBDeviceClose(usbDevice);
}

- (void)startPollingController {
  if (!shouldPoll) {
    shouldPoll = YES;
    [self performSelectorInBackground:@selector(poll) withObject:nil];
    [[[NSThread alloc] initWithTarget:self selector:@selector(poll) object:nil] start];
  }
}

- (void)stopPollingController {
  shouldPoll = NO;
}

- (void)poll {
  while (shouldPoll) {
    UInt32 numBytes = 20;
    char dataBuffer[32];
    returnCode = (*usbInterface)->ReadPipe(usbInterface, 2, dataBuffer, &numBytes);
    
    if (numBytes == 18) {
      Byte b = dataBuffer[4];
      buttonMap.sync  = (b & (1 << 0)) != 0;
      buttonMap.dummy = (b & (1 << 1)) != 0;
      buttonMap.menu  = (b & (1 << 2)) != 0;
      buttonMap.view  = (b & (1 << 3)) != 0;
      
      buttonMap.a = (b & (1 << 4)) != 0;
      buttonMap.b = (b & (1 << 5)) != 0;
      buttonMap.x = (b & (1 << 6)) != 0;
      buttonMap.y = (b & (1 << 7)) != 0;
      
      b = dataBuffer[5];
      buttonMap.dpad_up    = (b & (1 << 0)) != 0;
      buttonMap.dpad_down  = (b & (1 << 1)) != 0;
      buttonMap.dpad_left  = (b & (1 << 2)) != 0;
      buttonMap.dpad_right = (b & (1 << 3)) != 0;
      
      buttonMap.bumper_left       = (b & (1 << 4)) != 0;
      buttonMap.bumper_right      = (b & (1 << 5)) != 0;
      buttonMap.stick_left_click  = (b & (1 << 6)) != 0;
      buttonMap.stick_right_click = (b & (1 << 7)) != 0;
      
      buttonMap.trigger_left  = (dataBuffer[7] << 8) + (dataBuffer[6] & 0xff);
      buttonMap.trigger_right = (dataBuffer[9] << 8) + (dataBuffer[8] & 0xff);
      
      buttonMap.stick_left_x  = (dataBuffer[11] << 8) + dataBuffer[10];
      buttonMap.stick_left_y  = (dataBuffer[13] << 8) + dataBuffer[12];
      buttonMap.stick_right_x = (dataBuffer[15] << 8) + dataBuffer[14];
      buttonMap.stick_right_y = (dataBuffer[17] << 8) + dataBuffer[16];

      [delegate controllerDidUpdateData:buttonMap];
    }
    else if (numBytes == 6) {
      buttonMap.home = dataBuffer[4] & 1;
      [delegate controllerDidUpdateData:buttonMap];
    }
    
    [NSThread sleepForTimeInterval:0.005f];
  }
}

@end
