//
//  CTester.m
//  Test
//
//  Created by Jonathan Wight on 06/30/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CTester.h"

#import "NSObject_KVOBlock.h"

@interface CTester ()
- (void)testIdentifiers;
- (void)testTokens;
@end

#pragma mark -

@implementation CTester

@synthesize testValue;

- (void)test
    {
    [self testIdentifiers];
    [self testTokens];
    }

- (void)testIdentifiers
    {
    [self addKVOBlockForKeyPath:@"testValue" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld identifier:@"my_handler" handler:^(NSString *keyPath, id object, NSDictionary *change) {
        NSLog(@"I see you changed value from \"%@\" to \"%@\"", [change objectForKey:NSKeyValueChangeOldKey], [change objectForKey:NSKeyValueChangeNewKey]);
        }];

    self.testValue = @"A horse";
    self.testValue = @"is a horse";
    self.testValue = @"of course";
    self.testValue = @"of course.";
    self.testValue = NULL;

    [self removeKVOBlockForKeyPath:@"testValue" identifier:@"my_handler"];
    }

- (void)testTokens
    {
    id theToken = [self addKVOBlockForKeyPath:@"testValue" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld handler:^(NSString *keyPath, id object, NSDictionary *change) {
        NSLog(@"I see you changed value from \"%@\" to \"%@\"", [change objectForKey:NSKeyValueChangeOldKey], [change objectForKey:NSKeyValueChangeNewKey]);
        }];

    self.testValue = @"A horse";
    self.testValue = @"is a horse";
    self.testValue = @"of course";
    self.testValue = @"of course.";
    self.testValue = NULL;

    [self removeKVOBlockForToken:theToken];
    }

@end
