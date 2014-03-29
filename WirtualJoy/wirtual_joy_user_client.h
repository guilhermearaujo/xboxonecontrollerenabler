/*
 *  wirtual_joy_user_client.h
 *  wjoy
 *
 *  Created by alxn1 on 13.07.12.
 *  Copyright 2012 alxn1. All rights reserved.
 *
 */

#ifndef WIRTUAL_JOY_USER_CLIENT_H
#define WIRTUAL_JOY_USER_CLIENT_H

#include <IOKit/IOUserClient.h>
#include "wirtual_joy_config.h"

class WirtualJoy;
class WirtualJoyDevice;

class WirtualJoyUserClient : public IOUserClient
{
    OSDeclareDefaultStructors(WirtualJoyUserClient)
    public:
        virtual bool initWithTask(
                            task_t           owningTask,
                            void            *securityToken,
                            UInt32           type,
                            OSDictionary    *properties);

        virtual bool start(IOService *provider);
        virtual void stop(IOService *provider);

        virtual IOReturn clientClose();
        virtual bool didTerminate(IOService *provider, IOOptionBits options, bool *defer);

        virtual IOReturn externalMethod(
                                    uint32_t                     selector,
                                    IOExternalMethodArguments   *arguments,
									IOExternalMethodDispatch    *dispatch,
                                    OSObject                    *target,
                                    void                        *reference);

    protected:
        virtual void free();

    private:
        static const size_t                     externalMethodCount = 6;
        static const IOExternalMethodDispatch   externalMethodDispatchTable[externalMethodCount];

        WirtualJoy          *m_Owner;
        WirtualJoyDevice    *m_Device;
        OSString            *m_DeviceProductString;
        OSString            *m_DeviceSerialNumberString;
        uint32_t             m_DeviceVendorID;
        uint32_t             m_DeviceProductID;

        static IOReturn _enableDevice(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args);
        static IOReturn _disableDevice(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args);
        static IOReturn _updateDeviceState(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args);
        static IOReturn _setDeviceProductString(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args);
        static IOReturn _setDeviceSerialNumberString(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args);
        static IOReturn _setDeviceVendorAndProductID(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args);

        bool openOwner(WirtualJoy *owner);
        bool closeOwner();

        IOReturn enableDevice(const void *hidDescriptorData, uint32_t hidDescriptorDataSize);
        IOReturn disableDevice();
        IOReturn updateDeviceState(const void *hidData, uint32_t hidDataSize);
        IOReturn setDeviceProductString(const void *productString, uint32_t productStringSize);
        IOReturn setDeviceSerialNumberString(const void *serialNumberString, uint32_t serialNumberStringSize);
        IOReturn setDeviceVendorAndProductID(uint32_t vendorID, uint32_t productID);
};

#endif /* WIRTUAL_JOY_USER_CLIENT_H */
