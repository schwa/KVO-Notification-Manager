//
//  UnitTests.m
//  Test
//
//  Created by Jonathan Wight on 09/16/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//

#import "UnitTests.h"

#import "CKVOBlockNotificationCenter.h"

@implementation UnitTests

@synthesize testValue;

- (void)testFoo
{
CKVOBlockNotificationCenter *theCenter = [[[CKVOBlockNotificationCenter alloc] init] autorelease];
STAssertEquals(theCenter.helpersForObjects.count, (NSUInteger)0, @"Initial not empty");

__block NSString *theValue = NULL;
KVOBlock theBlock = ^(NSString *keyPath, id object, NSDictionary *change, id identifier) {
	theValue = [change objectForKey:@"new"];
	};

[theCenter addKVOBlock:theBlock forKeyPath:@"testValue" target:self options:NSKeyValueObservingOptionNew identifier:NULL];

STAssertEquals(theCenter.helpersForObjects.count, (NSUInteger)1, @"Helper count != 1 (is %d)", theCenter.helpersForObjects.count);

self.testValue = @"New Value";

STAssertEqualObjects(theValue, self.testValue, @"Value not expected (is %@)", theValue);

[theCenter removeKVOBlockForKeyPath:@"testValue" target:self identifier:NULL];

STAssertEquals(theCenter.helpersForObjects.count, (NSUInteger)0, @"Initial not empty (is %d)", theCenter.helpersForObjects.count);
}

@end
