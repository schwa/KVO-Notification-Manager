//
//  UnitTests.m
//  Test
//
//  Created by Jonathan Wight on 09/16/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//

#import "UnitTests.h"

#import "NSObject_KVOBlockNotificationExtensions.h"

@implementation UnitTests

@synthesize testValue;

- (void)testFoo
{
__block NSString *theValue = NULL;
KVOBlock theBlock = ^(NSString *keyPath, id object, NSDictionary *change, id identifier) {
	theValue = [change objectForKey:@"new"];
	};

[self addObserver:self handler:theBlock forKeyPath:@"testValue" options:NSKeyValueObservingOptionNew identifier:@"FOO"];

self.testValue = @"New Value";

STAssertEqualObjects(theValue, self.testValue, @"Value not expected (is %@)", theValue);

[self removeObserver:self forKeyPath:@"testValue" identifier:@"FOO"];
}

@end
