//
//  CKVONotificationHelper.m
//  MOO
//
//  Created by Jonathan Wight on 6/20/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
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
if ((self = [super init]) != NULL)
	{
	self.target = inTarget;
	self.keyPath = inKeyPath;
	block = [inBlock copy];
	identifier = [inIdentifier copy];
	}
return(self);
}

- (void)dealloc
{
self.target = NULL;
self.keyPath = NULL;
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
