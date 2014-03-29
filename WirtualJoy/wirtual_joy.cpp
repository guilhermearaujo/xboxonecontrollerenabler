/*
 *  wirtual_joy.cpp
 *  wjoy
 *
 *  Created by alxn1 on 13.07.12.
 *  Copyright 2012 alxn1. All rights reserved.
 *
 */

#include "wirtual_joy.h"
#include "wirtual_joy_debug.h"

#define super IOService

OSDefineMetaClassAndStructors(WirtualJoy, super)
 
bool WirtualJoy::start(IOService *provider)
{
    if(!super::start(provider))
        return false;

    registerService();
    dmsg("started");
    return true;
}

bool WirtualJoy::handleOpen(
                        IOService       *forClient,
                        IOOptionBits     options,
                        void            *arg)
{
    dmsg("handleOpen");
    return (!isOpen(forClient));
}
