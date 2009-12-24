//
//  CKVOBlockNotificationCenter.m
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


#import "CKVOBlockNotificationCenter.h"

#import "CKVOBlockNotificationHelper.h"
#include <objc/runtime.h>

#pragma mark -

//- (void)removeKVOBlockForKeyPath:(NSString *)inKeyPath target:(id)inTarget identifier:(NSString *)inIdentifier
//{
//NSAssert(inKeyPath != NULL, @"No key path");
//NSAssert(inTarget != NULL, @"No target");
//
//id theKey = [self keyForTarget:inTarget keyPath:inKeyPath identifier:inIdentifier];
//NSMapTable *theHelpers = [self.helpersForObjects objectForKey:inTarget];
//CKVOBlockNotificationHelper *theHelper = [theHelpers objectForKey:theKey];
//if (theHelper)
//	{
//	[inTarget removeObserver:theHelper forKeyPath:inKeyPath];
//	//
//	[theHelpers removeObjectForKey:theKey];
//	
//	if (theHelpers.count == 0)
//		[self.helpersForObjects removeObjectForKey:inTarget];
//	}
//}
//
//- (void)removeAllKVOBlocksForKeyPath:(NSString *)inKeyPath target:(id)inTarget;
//{
//NSAssert(inKeyPath != NULL, @"No key path");
//NSAssert(inTarget != NULL, @"No target");
//
//for (CKVOBlockNotificationHelper *theHelper in self.helpersForObjects)
//	{
//	if ([theHelper.keyPath isEqualToString:inKeyPath] && theHelper.target == inTarget)
//		{
//		[self removeKVOBlockForKeyPath:inKeyPath target:inTarget identifier:theHelper.identifier];
//		}
//	}
//}
//
//#pragma mark -
//
static id KeyForTarget(id inObserver, id inTarget, NSString *inKeyPath, NSString *inIdentifier)
{
NSCAssert(inKeyPath != NULL, @"No key path");
NSCAssert(inTarget != NULL, @"No target");

return([NSString stringWithFormat:@"%x:%x:%@:%@", inObserver, inTarget, inKeyPath, inIdentifier]);
}

#pragma mark -

@implementation NSObject (NSObject_KVOBlockNotificationCenterExtensions)

- (void)addObserver:(NSObject *)observer handler:(KVOBlock)inHandler forKeyPath:(NSString *)inKeyPath options:(NSKeyValueObservingOptions)inOptions identifier:(id)inIdentifier
{
NSAssert(inHandler != NULL, @"No block");
NSAssert(inKeyPath != NULL, @"No key path");

static NSString *theHelpersKey = @"NSObject_KVOBlockNotificationCenterExtensions_Helpers";

NSMapTable *theHelpers = objc_getAssociatedObject(observer, theHelpersKey);
if (theHelpers == NULL)
	{
	theHelpers = [NSMapTable mapTableWithStrongToStrongObjects];
	objc_setAssociatedObject(observer, theHelpersKey, theHelpers, OBJC_ASSOCIATION_RETAIN);
	}

id theKey = KeyForTarget(observer, self, inKeyPath, inIdentifier);

CKVOBlockNotificationHelper *theHelper = [theHelpers objectForKey:theKey];
if (theHelper != NULL)
	{
	[self removeObserver:theHelper forKeyPath:inKeyPath];
	//
	[theHelpers removeObjectForKey:theKey];
	}

theHelper = [[[CKVOBlockNotificationHelper alloc] initWithTarget:self keyPath:inKeyPath block:inHandler identifier:inIdentifier] autorelease];

[theHelpers setObject:theHelper forKey:theKey];
//
[self addObserver:theHelper forKeyPath:inKeyPath options:inOptions context:self];
}

- (void)removeObserver:(NSObject *)observer handler:(KVOBlock)inHandler forKeyPath:(NSString *)keyPath
{
//NSAssert(inKeyPath != NULL, @"No key path");
//
//[[CKVOBlockNotificationCenter instance] removeKVOBlockForKeyPath:inKeyPath target:self identifier:inIdentifier];
}

@end
