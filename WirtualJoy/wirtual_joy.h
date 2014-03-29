/*
 *  wirtual_joy.h
 *  wjoy
 *
 *  Created by alxn1 on 13.07.12.
 *  Copyright 2012 alxn1. All rights reserved.
 *
 */

#ifndef WIRTUAL_JOY_H
#define WIRTUAL_JOY_H

#include <IOKit/IOService.h>
#include "wirtual_joy_config.h"

class WirtualJoy : public IOService
{
    OSDeclareDefaultStructors(WirtualJoy)
    public:
        virtual bool start(IOService *provider);

        virtual bool handleOpen(
                            IOService       *forClient,
                            IOOptionBits     options,
                            void            *arg);
};

#endif /* WIRTUAL_JOY_H */
