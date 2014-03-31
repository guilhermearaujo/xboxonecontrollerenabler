//
//  GAAppDelegate.m
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 26/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

#import "GAAppDelegate.h"
#import "GAMainViewController.h"

@interface GAAppDelegate ()

@property (strong, nonatomic) GAMainViewController *masterViewController;
@property (strong) id activity;

@end

@implementation GAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
  self.masterViewController = [[GAMainViewController alloc] initWithNibName:@"GAMainViewController" bundle:nil];
  

  [self.window.contentView addSubview:self.masterViewController.view];
  self.masterViewController.view.frame = ((NSView*)self.window.contentView).bounds;
  
  if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)]) {
    self.activity = [[NSProcessInfo processInfo] beginActivityWithOptions:0x00FFFFFF reason:@"Receiving Controller Data"];
  }
}

@end
