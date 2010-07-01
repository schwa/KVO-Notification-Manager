//
//  UnitTests.h
//  Test
//
//  Created by Jonathan Wight on 09/16/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface UnitTests : SenTestCase {
	NSString *testValue;
}

@property (readwrite, copy) NSString *testValue;

@end
