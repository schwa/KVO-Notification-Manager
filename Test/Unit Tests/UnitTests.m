//
//  UnitTests.m
//  TouchCode
//
//  Created by Jonathan Wight on 09/16/09.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOXICSOFTWARE.COM OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import "UnitTests.h"

#import "NSObject_KVOBlock.h"

@interface UnitTests ()
@property (readwrite, nonatomic, retain) NSString *testValue;
@property (readwrite, nonatomic, retain) id token;
@end

#pragma mark -

@implementation UnitTests

@synthesize testValue;
@synthesize token;

- (void)setUp
    {
    testValue = NULL;
    token = NULL;
    }
    
- (void)tearDown
    {
    testValue = NULL;
    token = NULL;
    }

- (void)testTokens
    {
    __block NSString *theOldValue = @"";
    __block NSString *theNewValue = @"";

    self.testValue = @"1";
    STAssertEqualObjects(theOldValue, @"", @"Failed.");
    STAssertEqualObjects(theNewValue, @"", @"Failed.");
    
    NSString *theToken = [self addKVOBlockForKeyPath:@"testValue" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld handler:^(NSString *keyPath, id object, NSDictionary *change) {
        theOldValue = [change objectForKey:NSKeyValueChangeOldKey];
        theNewValue = [change objectForKey:NSKeyValueChangeNewKey];
        }];

    self.testValue = @"2";
    STAssertEqualObjects(theOldValue, @"1", @"Failed.");
    STAssertEqualObjects(theNewValue, @"2", @"Failed.");

    self.testValue = @"3";
    STAssertEqualObjects(theOldValue, @"2", @"Failed.");
    STAssertEqualObjects(theNewValue, @"3", @"Failed.");

    theOldValue = @"";
    theNewValue = @"";
    
    [self removeKVOBlockForToken:theToken];
    
    self.testValue = @"4";
    STAssertEqualObjects(theOldValue, @"", @"Failed.");
    STAssertEqualObjects(theNewValue, @"", @"Failed.");
    }

- (void)testOneShot
    {
    __block NSString *theOldValue = @"";
    __block NSString *theNewValue = @"";

    self.testValue = @"1";
    STAssertEqualObjects(theOldValue, @"", @"Failed.");
    STAssertEqualObjects(theNewValue, @"", @"Failed.");
    
    [self addOneShotKVOBlockForKeyPath:@"testValue" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld handler:^(NSString *keyPath, id object, NSDictionary *change) {
        theOldValue = [change objectForKey:NSKeyValueChangeOldKey];
        theNewValue = [change objectForKey:NSKeyValueChangeNewKey];
        }];

    self.testValue = @"2";
    STAssertEqualObjects(theOldValue, @"1", @"Failed.");
    STAssertEqualObjects(theNewValue, @"2", @"Failed.");

    self.testValue = @"3";
    STAssertEqualObjects(theOldValue, @"1", @"Failed.");
    STAssertEqualObjects(theNewValue, @"2", @"Failed.");
    }

@end
