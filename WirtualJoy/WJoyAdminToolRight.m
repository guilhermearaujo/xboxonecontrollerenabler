//
//  WJoyAdminToolRight.m
//  driver
//
//  Created by alxn1 on 18.05.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WJoyAdminToolRight.h"

@implementation WJoyAdminToolRight

- (id)init
{
    self = [super init];
    if(self == nil)
        return nil;

    m_AuthRef = NULL;

    return self;
}

- (void)dealloc
{
    [self discard];
    [super dealloc];
}

- (BOOL)isObtained
{
    return (m_AuthRef != NULL);
}

- (BOOL)obtain
{
    if([self isObtained])
        return YES;

	AuthorizationItem   right       = { "com.alxn1.wjoy.adminRights", 0, NULL, 0 };
	AuthorizationRights rightSet    = { 1, &right };

    if(AuthorizationCreate(
                         NULL,
                         kAuthorizationEmptyEnvironment,
                         kAuthorizationFlagDefaults,
                        &m_AuthRef) != noErr)
    {
        m_AuthRef = NULL;
        return NO;
    }

	AuthorizationFlags flags = kAuthorizationFlagDefaults |
                               kAuthorizationFlagExtendRights |
                               kAuthorizationFlagInteractionAllowed |
                               kAuthorizationFlagPreAuthorize;

	if(AuthorizationCopyRights(
                         m_AuthRef,
                        &rightSet, 
                         kAuthorizationEmptyEnvironment,
                         flags,
                         NULL) != noErr)
    {
        [self discard];
        return NO;
    }

    return YES;
}

- (void)discard
{
    if(![self isObtained])
        return;

    AuthorizationFree(m_AuthRef, kAuthorizationFlagDestroyRights);
    m_AuthRef = NULL;
}

- (AuthorizationRef)authRef
{
    return m_AuthRef;
}

@end
