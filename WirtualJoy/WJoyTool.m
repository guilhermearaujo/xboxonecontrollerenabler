//
//  WJoyTool.m
//  driver
//
//  Created by alxn1 on 17.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WJoyTool.h"
#import "WJoyToolInterface.h"
#import "WJoyAdminToolRight.h"

#define WJoyDeviceDriverName @"wjoy.kext"

@interface WJoyTool (PrivatePart)

+ (NSBundle*)bundle;
+ (NSString*)toolPath;
+ (NSString*)driverPath;

+ (BOOL)repairToolRights;
+ (BOOL)doCommand:(NSString*)command argument:(NSString*)argument;
+ (BOOL)doLoadOrUnloadCommand:(NSString*)command;

@end

@implementation WJoyTool

+ (BOOL)loadDriver
{
    return [self doLoadOrUnloadCommand:WJoyToolLoadDriverCommand];
}

+ (BOOL)unloadDriver
{
	return YES;
	// return [self doLoadOrUnloadCommand:WJoyToolUnloadDriverCommand];
}

@end

@implementation WJoyTool (PrivatePart)

+ (NSBundle*)bundle
{
    return [NSBundle bundleForClass:[self class]];
}

+ (NSString*)toolPath
{
    return [[[self bundle] resourcePath]
                stringByAppendingPathComponent:WJoyToolName];
}

+ (NSString*)driverPath
{
    return [[[self bundle] resourcePath]
                stringByAppendingPathComponent:WJoyDeviceDriverName];
}

+ (BOOL)repairToolRights
{
    WJoyAdminToolRight *rights = [[[WJoyAdminToolRight alloc] init] autorelease];

    if(![rights obtain])
        return NO;

    char *args[] =
    {
        (char*)[WJoyToolRepairRightsCommand UTF8String],
        0
    };

    FILE *toolOutput = NULL;
    if(AuthorizationExecuteWithPrivileges(
                                     [rights authRef],
                                     [[self toolPath] UTF8String],
                                     kAuthorizationFlagDefaults,
                                     args,
                                    &toolOutput) != noErr)
    {
        [rights discard];
        return NO;
    }

    char buffer[64];
    while(YES)
    {
        if(fread(buffer, sizeof(buffer), 1, toolOutput) <= 0)
            break;
    }

    fclose(toolOutput);
    [rights discard];
    return YES;
}

+ (BOOL)doCommand:(NSString*)command argument:(NSString*)argument
{
    NSTask *task = [[NSTask alloc] init];

    [task setLaunchPath:[self toolPath]];
    [task setArguments:[NSArray arrayWithObjects:command, argument, nil]];
    [task launch];
    [task waitUntilExit];

    BOOL result = ([task terminationStatus] == EXIT_SUCCESS);

    [task release];
    return result;
}

+ (BOOL)doLoadOrUnloadCommand:(NSString*)command
{
    if([self doCommand:command argument:[self driverPath]])
        return YES;

    if(![self repairToolRights])
        return NO;

    return [self doCommand:command argument:[self driverPath]];
}

- (id)init
{
    [[super init] release];
    return nil;
}

@end
