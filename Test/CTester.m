//
//  CTester.m
//  Test
//
//  Created by Jonathan Wight on 06/30/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CTester.h"

#import "CKVOBlockNotificationCenter.h"

@implementation CTester

@synthesize testValue;

- (void)test
{
__block NSString *theValue = NULL;
KVOBlock theBlock = ^(NSString *keyPath, id object, NSDictionary *change, id identifier) {
	theValue = [change objectForKey:@"new"];
	};

[self addObserver:self handler:theBlock forKeyPath:@"testValue" options:NSKeyValueObservingOptionNew identifier:@"FOO"];

NSLog(@"%@", theValue);
self.testValue = @"New Value";
NSLog(@"%@", theValue);

[self removeObserver:self forKeyPath:@"testValue" identifier:@"FOO"];
}

@end
