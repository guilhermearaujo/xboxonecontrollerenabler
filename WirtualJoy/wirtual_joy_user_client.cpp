/*
 *  wirtual_joy_user_client.cpp
 *  wjoy
 *
 *  Created by alxn1 on 13.07.12.
 *  Copyright 2012 alxn1. All rights reserved.
 *
 */

#include "wirtual_joy.h"
#include "wirtual_joy_user_client.h"
#include "wirtual_joy_device.h"
#include "wirtual_joy_debug.h"

#define super IOUserClient

OSDefineMetaClassAndStructors(WirtualJoyUserClient, super)

const IOExternalMethodDispatch WirtualJoyUserClient::externalMethodDispatchTable[externalMethodCount] =
{
    {
        (IOExternalMethodAction) WirtualJoyUserClient::_enableDevice,
        0, kIOUCVariableStructureSize, 0, 0
    },

    {
        (IOExternalMethodAction) WirtualJoyUserClient::_disableDevice,
        0, 0, 0, 0
    },

    {
        (IOExternalMethodAction) WirtualJoyUserClient::_updateDeviceState,
        0, kIOUCVariableStructureSize, 0, 0
    },

    {
        (IOExternalMethodAction) WirtualJoyUserClient::_setDeviceProductString,
        0, kIOUCVariableStructureSize, 0, 0
    },

    {
        (IOExternalMethodAction) WirtualJoyUserClient::_setDeviceSerialNumberString,
        0, kIOUCVariableStructureSize, 0, 0
    },

    {
        (IOExternalMethodAction) WirtualJoyUserClient::_setDeviceVendorAndProductID,
        0, kIOUCVariableStructureSize, 0, 0
    }
};

static bool checkString(const char *str, size_t maxLength)
{
    while(maxLength > 0)
    {
        if(*str == 0)
            return true;

        maxLength--;
        str++;
    }

    return false;
}

IOReturn WirtualJoyUserClient::_enableDevice(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    return target->enableDevice(args->structureInput, args->structureInputSize);
}

IOReturn WirtualJoyUserClient::_disableDevice(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    return target->disableDevice();
}

IOReturn WirtualJoyUserClient::_updateDeviceState(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    return target->updateDeviceState(args->structureInput, args->structureInputSize);
}

IOReturn WirtualJoyUserClient::_setDeviceProductString(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    return target->setDeviceProductString(args->structureInput, args->structureInputSize);
}

IOReturn WirtualJoyUserClient::_setDeviceSerialNumberString(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    return target->setDeviceSerialNumberString(args->structureInput, args->structureInputSize);
}

IOReturn WirtualJoyUserClient::_setDeviceVendorAndProductID(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    const char *data        = static_cast< const char* >(args->structureInput);
    size_t      dataSize    = args->structureInputSize;

    if(data == 0 || dataSize < (sizeof(uint32_t) * 2))
        return kIOReturnBadArgument;

    uint32_t vendorID   = 0;
    uint32_t productID  = 0;

    memcpy(&vendorID, data, sizeof(int32_t));
    memcpy(&productID, data + sizeof(uint32_t), sizeof(uint32_t));

    return target->setDeviceVendorAndProductID(vendorID, productID);
}

bool WirtualJoyUserClient::openOwner(WirtualJoy *owner)
{
    if(owner == 0 || isInactive())
        return false;

    if(!owner->open(this))
        return false;

    m_Owner = owner;
    return true;
}

bool WirtualJoyUserClient::closeOwner()
{
    if(m_Owner != 0)
    {
        if(m_Owner->isOpen(this))
            m_Owner->close(this);

        m_Owner = 0;
    }

    disableDevice();
    return true;
}

bool WirtualJoyUserClient::initWithTask(
                                task_t           owningTask,
                                void            *securityToken,
                                UInt32           type,
                                OSDictionary    *properties)
{
    if(!super::initWithTask(owningTask, securityToken, type, properties))
        return false;

    m_Owner                     = 0;
    m_Device                    = 0;
    m_DeviceProductString       = OSString::withCString("WJoy Virtual HID Device");
    m_DeviceSerialNumberString  = OSString::withCString("000000000000");
    m_DeviceVendorID            = 0;
    m_DeviceProductID           = 0;

    dmsg("initWithTask");
    return true;
}

void WirtualJoyUserClient::free()
{
    if(m_DeviceProductString != 0)
        m_DeviceProductString->release();

    if(m_DeviceSerialNumberString != 0)
        m_DeviceSerialNumberString->release();

    dmsg("free");
    super::free();
}

bool WirtualJoyUserClient::start(IOService *provider)
{
    WirtualJoy *owner = OSDynamicCast(WirtualJoy, provider);
    if(owner == 0)
        return false;

    if(!super::start(provider))
        return false;

    if(!openOwner(owner))
    {
        super::stop(provider);
        return false;
    }

    dmsgf("start, provider: %p", provider);
    return true;
}

void WirtualJoyUserClient::stop(IOService *provider)
{
    dmsgf("stop, provider: %p", provider);
    closeOwner();
    super::stop(provider);
}

IOReturn WirtualJoyUserClient::clientClose()
{
    dmsg("clientClose");
    closeOwner();
    terminate();
    return kIOReturnSuccess;
}

bool WirtualJoyUserClient::didTerminate(IOService *provider, IOOptionBits options, bool *defer)
{
    dmsg("didTerminate");
    closeOwner();
	*defer = false;
	return super::didTerminate(provider, options, defer);
}

IOReturn WirtualJoyUserClient::externalMethod(
                                    uint32_t                     selector,
                                    IOExternalMethodArguments   *arguments,
									IOExternalMethodDispatch    *dispatch,
                                    OSObject                    *target,
                                    void                        *reference)
{
    dmsg("externalMehtod");

    if(selector < externalMethodCount)
    {
        dispatch = const_cast< IOExternalMethodDispatch* >(&externalMethodDispatchTable[selector]);
        if(target == 0)
            target = this;
    }
        
	return super::externalMethod(selector, arguments, dispatch, target, reference);
}

IOReturn WirtualJoyUserClient::enableDevice(const void *hidDescriptorData, uint32_t hidDescriptorDataSize)
{
    dmsgf("enableDevice, param size = %d", hidDescriptorDataSize);

    if(m_Device != 0)
    {
        IOReturn result = disableDevice();
        if(result != kIOReturnSuccess)
            return result;
    }

    m_Device = WirtualJoyDevice::withHidDescriptor(
                                            hidDescriptorData,
                                            hidDescriptorDataSize,
                                            m_DeviceProductString,
                                            m_DeviceSerialNumberString,
                                            m_DeviceVendorID,
                                            m_DeviceProductID);

    if(m_Device == 0)
        return kIOReturnDeviceError;

    if(!m_Device->attach(this))
    {
        m_Device->release();
        m_Device = 0;
        return kIOReturnDeviceError;
    }

    if(!m_Device->start(this))
    {
        m_Device->detach(this);
        m_Device->release();
        m_Device = 0;
        return kIOReturnDeviceError;
    }

    return kIOReturnSuccess;
}

IOReturn WirtualJoyUserClient::disableDevice()
{
    dmsg("disableDevice");

    if(m_Device != 0)
    {
        m_Device->terminate(kIOServiceRequired);
        m_Device->release();
        m_Device = 0;
    }

    return kIOReturnSuccess;
}

IOReturn WirtualJoyUserClient::updateDeviceState(const void *hidData, uint32_t hidDataSize)
{
    // dmsgf("updateDeviceState, param size = %d", hidDataSize);

    if(m_Device == 0)
        return kIOReturnNoDevice;

    if(!m_Device->updateState(hidData, hidDataSize))
        return kIOReturnDeviceError;

    return kIOReturnSuccess;
}

IOReturn WirtualJoyUserClient::setDeviceProductString(const void *productString, uint32_t productStringSize)
{
    dmsgf("setDeviceProductString, productString size = %d", productStringSize);

    if(m_Device != 0)
        return kIOReturnBusy;

    if(!checkString(static_cast< const char* >(productString), productStringSize))
        return kIOReturnInvalid;

    OSString *newStr = OSString::withCString(static_cast< const char* >(productString));
    if(newStr == 0)
        return kIOReturnNoMemory;

    if(m_DeviceProductString != 0)
        m_DeviceProductString->release();

    m_DeviceProductString = newStr;

    dmsgf("newProductString = %s", newStr->getCStringNoCopy());
    return kIOReturnSuccess;
}

IOReturn WirtualJoyUserClient::setDeviceSerialNumberString(const void *serialNumberString, uint32_t serialNumberStringSize)
{
    dmsgf("setDeviceSerialNumberString, serialNumberString size = %d", serialNumberStringSize);

    if(m_Device != 0)
        return kIOReturnBusy;

    if(!checkString(static_cast< const char* >(serialNumberString), serialNumberStringSize))
        return kIOReturnInvalid;

    OSString *newStr = OSString::withCString(static_cast< const char* >(serialNumberString));
    if(newStr == 0)
        return kIOReturnNoMemory;

    if(m_DeviceSerialNumberString != 0)
        m_DeviceSerialNumberString->release();

    m_DeviceSerialNumberString = newStr;

    dmsgf("newSerialNumberString = %s", newStr->getCStringNoCopy());
    return kIOReturnSuccess;
}

IOReturn WirtualJoyUserClient::setDeviceVendorAndProductID(uint32_t vendorID, uint32_t productID)
{
    dmsgf("setDeviceVendorAndProductID, vendorID = %d, productID = %d", vendorID, productID);

    if(m_Device != 0)
        return kIOReturnBusy;

    m_DeviceVendorID    = vendorID;
    m_DeviceProductID   = productID;

    return kIOReturnSuccess;
}
