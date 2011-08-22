//
//  CTester.h
//  Test
//
//  Created by Jonathan Wight on 06/30/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTester : NSObject {
}

@property (readwrite, nonatomic, retain) NSString *testValue;

- (void)test;

@end
