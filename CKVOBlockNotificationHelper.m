//
//  CKVONotificationHelper.m
//  MOO
//
//  Created by Jonathan Wight on 6/20/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

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
