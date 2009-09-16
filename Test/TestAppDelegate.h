//
//  TestAppDelegate.h
//  Test
//
//  Created by Jonathan Wight on 09/16/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TestAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
