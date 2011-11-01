//
//  NSObject_KVOBlockNotificationExtensions.m
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


#import "NSObject_KVOBlockNotificationExtensions.h"

#import "CKVOBlockNotificationHelper.h"
#include <objc/runtime.h>

#pragma mark -

static id KeyForTarget(id inObserver, id inTarget, NSString *inKeyPath, NSString *inIdentifier)
{
NSCAssert(inKeyPath != NULL, @"No key path");
NSCAssert(inTarget != NULL, @"No target");

return([NSString stringWithFormat:@"%x:%x:%@:%@", inObserver, inTarget, inKeyPath, inIdentifier]);
}

static NSString *theHelpersKey = @"NSObject_KVOBlockNotificationExtensions_Helpers";

#pragma mark -

@implementation NSObject (NSObject_KVOBlockNotificationExtensions)

- (void)addObserver:(NSObject *)observer handler:(KVOBlock)inHandler forKeyPath:(NSString *)inKeyPath options:(NSKeyValueObservingOptions)inOptions identifier:(id)inIdentifier
{
NSAssert(inHandler != NULL, @"No block");
NSAssert(inKeyPath != NULL, @"No key path");

NSMutableDictionary *theHelpers = objc_getAssociatedObject(observer, theHelpersKey);
if (theHelpers == NULL)
	{
	theHelpers = [NSMutableDictionary dictionary];
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

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)inKeyPath identifier:(id)inIdentifier
{
id theKey = KeyForTarget(observer, self, inKeyPath, inIdentifier);

NSMutableDictionary *theHelpers = objc_getAssociatedObject(observer, theHelpersKey);

CKVOBlockNotificationHelper *theHelper = [theHelpers objectForKey:theKey];

if (theHelper != NULL)
	{
	[self removeObserver:theHelper forKeyPath:inKeyPath];
	//
	[theHelpers removeObjectForKey:theKey];
	}
}

@end
