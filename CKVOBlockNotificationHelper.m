//
//  CKVONotificationHelper.m
//  TouchCode
//
//  Created by Jonathan Wight on 6/20/09.
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

#import "CKVOBlockNotificationHelper.h"

@interface CKVOBlockNotificationHelper ()
@end

#pragma mark -

@implementation CKVOBlockNotificationHelper

@synthesize target;
@synthesize keyPath;
@synthesize block;
@synthesize identifier;

- (id)initWithTarget:(id)inTarget keyPath:(NSString *)inKeyPath block:(KVOBlock)inBlock identifier:(NSString *)inIdentifier;
{
NSAssert(inTarget != NULL, @"No target");
NSAssert(inKeyPath != NULL, @"No key path");
NSAssert(inBlock != NULL, @"No block");

if ((self = [super init]) != NULL)
	{
	target = inTarget;
	keyPath = [inKeyPath copy];
	block = [inBlock copy];
	identifier = [inIdentifier copy];
	}
return(self);
}

- (void)dealloc
{
target = NULL;
[keyPath release];
keyPath = NULL;
[block release];
block = NULL;

[identifier autorelease];
identifier = NULL;
//
[super dealloc];
}

//- (void)finalize
//{
//NSLog(@"FINALIZE %@", self);
////
//[super finalize];
//}

- (void)observeValueForKeyPath:(NSString *)inKeyPath ofObject:(id)inObject change:(NSDictionary *)inChange context:(void *)inContext
{
self.block(inKeyPath, inObject, inChange, self.identifier);
}

- (NSString *)description
{
return([NSString stringWithFormat:@"%@ (%@)", [super description], self.identifier]);
}

@end
