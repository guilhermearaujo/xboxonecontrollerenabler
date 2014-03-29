//
//  TestView.h
//  VHID
//
//  Created by alxn1 on 24.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TestView;

typedef enum
{
    TestViewKeyUp,
    TestViewKeyDown,
    TestViewKeyLeft,
    TestViewKeyRight
} TestViewKey;

@protocol TestViewDelegate

- (void)testView:(TestView*)view keyPressed:(TestViewKey)key;

@end

@interface TestView : NSView
{
    @private
        id<TestViewDelegate> m_Delegate;
}

- (id<TestViewDelegate>)delegate;
- (void)setDelegate:(id<TestViewDelegate>)obj;

@end
