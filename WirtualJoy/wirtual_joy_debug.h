/*
 *  wirtual_joy_debug.h
 *  wjoy
 *
 *  Created by alxn1 on 12.07.12.
 *  Copyright 2011 alxn1. All rights reserved.
 *
 */

#ifndef WIRTUAL_JOY_DEBUG_H
#define WIRTUAL_JOY_DEBUG_H

#include <libkern/libkern.h>

#ifdef DEBUG

    #define dmsg(message) \
                printf("%s - %s (%d): %s\n", \
                    __FILE__, __PRETTY_FUNCTION__, __LINE__, message)

	#define dmsgf(format, params ...) \
                printf("%s - %s (%d): " format "\n", \
                    __FILE__, __PRETTY_FUNCTION__, __LINE__, params)

#else /* DEBUG */

	#define dmsg(message)
	#define dmsgf(format, params ...)

#endif /* DEBUG */

#endif /* WIRTUAL_JOY_DEBUG_H */
