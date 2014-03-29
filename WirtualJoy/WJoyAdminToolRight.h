//
//  WJoyAdminToolRight.h
//  driver
//
//  Created by alxn1 on 18.05.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface WJoyAdminToolRight : NSObject
{
    @private
        AuthorizationRef m_AuthRef;
}

- (BOOL)isObtained;
- (BOOL)obtain;
- (void)discard;

- (AuthorizationRef)authRef;

@end
