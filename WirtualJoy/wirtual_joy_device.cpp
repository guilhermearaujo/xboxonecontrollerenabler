/*
 *  wirtual_joy_device.cpp
 *  wjoy
 *
 *  Created by alxn1 on 13.07.12.
 *  Copyright 2012 alxn1. All rights reserved.
 *
 */

#include "wirtual_joy_device.h"
#include "wirtual_joy_debug.h"

#include <IOKit/usb/IOUSBHIDDriver.h>

#define super IOHIDDevice

OSDefineMetaClassAndStructors(WirtualJoyDevice, super)

bool WirtualJoyDevice::parseHidDescriptor(
                                const void *hidDescriptorData,
                                size_t      hidDescriptorDataSize)
{
    HIDPreparsedDataRef preparsedDataRef = 0;

    if(HIDOpenReportDescriptor(
                         const_cast< void* >(hidDescriptorData),
                         hidDescriptorDataSize,
                        &preparsedDataRef, 0) != kIOReturnSuccess)
    {
        return false;
    }

    bool result = (HIDGetCapabilities(preparsedDataRef, &m_Capabilities) == kIOReturnSuccess);
    HIDCloseReportDescriptor(preparsedDataRef);
    return result;
}

WirtualJoyDevice *WirtualJoyDevice::withHidDescriptor(
                                const void *hidDescriptorData,
                                size_t      hidDescriptorDataSize,
                                OSString   *productString,
                                OSString   *serialNumberString,
                                uint32_t    vendorID,
                                uint32_t    productID)
{
    WirtualJoyDevice *result = new WirtualJoyDevice();

    if(result != 0)
    {
        if(!result->init(hidDescriptorData, hidDescriptorDataSize, productString, serialNumberString, vendorID, productID))
        {
            result->release();
            result = 0;
        }
    }

    return result;
}

bool WirtualJoyDevice::init(
                const void      *hidDescriptorData,
                size_t           hidDescriptorDataSize,
                OSString        *productString,
                OSString        *serialNumberString,
                uint32_t         vendorID,
                uint32_t         productID,
                OSDictionary    *dictionary)
{
    m_ProductString         = 0;
    m_SerialNumberString    = 0;
    m_VendorID              = vendorID;
    m_ProductID             = productID;
    m_HIDReportDescriptor   = 0;
    m_StateBuffer           = 0;

    if(productString     == 0 ||
       hidDescriptorData == 0)
    {
        return false;
    }

    if(!super::init(dictionary))
        return false;

    if(!parseHidDescriptor(hidDescriptorData, hidDescriptorDataSize))
        return false;

    if(m_Capabilities.inputReportByteLength > kMaxHIDReportSize)
        return false;

    if(m_Capabilities.usagePage == kHIDPage_GenericDesktop)
    {
       if(m_Capabilities.usage == kHIDUsage_GD_Mouse ||
          m_Capabilities.usage == kHIDUsage_GD_Keyboard)
        {
            // hack for Apple HID subsystem
            OSString *str = OSString::withCString(
                                        (m_Capabilities.usage == kHIDUsage_GD_Mouse)?
                                            ("Mouse"):
                                            ("Keyboard"));

            if(str == NULL)
                return false;

            if(!setProperty("HIDDefaultBehavior", str))
            {
                str->release();
                return false;
            }

            str->release();
        }
    }

    m_HIDReportDescriptor = IOBufferMemoryDescriptor::withBytes(
                                                        hidDescriptorData,
                                                        hidDescriptorDataSize,
                                                        kIODirectionInOut);

    if(m_HIDReportDescriptor == 0)
        return false;

    m_StateBuffer = IOBufferMemoryDescriptor::withCapacity(
                                                m_Capabilities.inputReportByteLength,
                                                kIODirectionInOut);

    if(m_StateBuffer == 0)
        return false;

    memset(m_StateBuffer->getBytesNoCopy(), 0, m_StateBuffer->getLength());

    {
        static uint32_t lastId = locationIdBase;

        lastId++;
        m_LocationID = lastId;
    }

    m_ProductString         = productString;
    m_SerialNumberString    = serialNumberString;

    m_SerialNumberString->retain();
    m_ProductString->retain();

    dmsg("init");
    return true;
}

IOReturn WirtualJoyDevice::newReportDescriptor(IOMemoryDescriptor **descriptor) const
{
    IOBufferMemoryDescriptor *result = IOBufferMemoryDescriptor::withBytes(
                                                                    m_HIDReportDescriptor->getBytesNoCopy(),
                                                                    m_HIDReportDescriptor->getLength(),
                                                                    kIODirectionInOut);

    if(result == 0)
        return kIOReturnError;

    *descriptor = result;
	return kIOReturnSuccess;
}

OSString *WirtualJoyDevice::newTransportString() const
{
	return OSString::withCString("Virtual");
}

OSString *WirtualJoyDevice::newManufacturerString() const
{
    return OSString::withCString("alxn1");
}

OSString *WirtualJoyDevice::newProductString() const
{
    return OSString::withString(m_ProductString);
}

OSString *WirtualJoyDevice::newSerialNumberString() const
{
	return OSString::withString(m_SerialNumberString);
}

OSNumber *WirtualJoyDevice::newVersionNumber() const
{
	return OSNumber::withNumber(1, 32);
}

OSNumber *WirtualJoyDevice::newSerialNumber() const
{
	uint32_t number = 0;
	return OSNumber::withNumber(number, 32);
}

OSNumber *WirtualJoyDevice::newVendorIDNumber() const
{
	return OSNumber::withNumber(m_VendorID, 32);
}

OSNumber *WirtualJoyDevice::newProductIDNumber() const
{
	return OSNumber::withNumber(m_ProductID, 32);
}

OSNumber *WirtualJoyDevice::newPrimaryUsageNumber() const
{
    return OSNumber::withNumber(m_Capabilities.usage, 32);
}

OSNumber *WirtualJoyDevice::newPrimaryUsagePageNumber() const
{
    return OSNumber::withNumber(m_Capabilities.usagePage, 32);
}

OSNumber *WirtualJoyDevice::newLocationIDNumber() const
{
    return OSNumber::withNumber(m_LocationID, 32);
}

OSNumber *WirtualJoyDevice::newVendorIDSourceNumber() const
{
	uint32_t number = 0;
	return OSNumber::withNumber(number, 32);
}

OSNumber *WirtualJoyDevice::newCountryCodeNumber() const
{
	uint32_t number = 0;
	return OSNumber::withNumber(number, 32);
}

bool WirtualJoyDevice::updateState(const void *hidData, size_t hidDataSize)
{
    if(m_StateBuffer->getLength() != hidDataSize)
        return false;

    memcpy(m_StateBuffer->getBytesNoCopy(), hidData, hidDataSize);
    return (handleReport(m_StateBuffer) == kIOReturnSuccess);
}

void WirtualJoyDevice::free()
{
    if(m_ProductString != 0)
        m_ProductString->release();

    if(m_SerialNumberString != 0)
        m_SerialNumberString->release();

    if(m_HIDReportDescriptor != 0)
        m_HIDReportDescriptor->release();

    if(m_StateBuffer != 0)
        m_StateBuffer->release();

    dmsg("free");
    super::free();
}
