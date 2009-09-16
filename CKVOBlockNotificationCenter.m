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

static CKVOBlockNotificationCenter *gInstance = NULL;

@interface CKVOBlockNotificationCenter ()
@property (readwrite, retain) NSMapTable *helpersForObjects;

- (id)keyForTarget:(id)inTarget keyPath:(NSString *)inKeyPath identifier:(NSString *)inIdentifier;
@end

#pragma mark -

@implementation CKVOBlockNotificationCenter

@synthesize helpersForObjects;

+ (CKVOBlockNotificationCenter *)instance
{
@synchronized(self)
	{
	if (gInstance == NULL)
		{
		gInstance = [[self alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:[NSApplication sharedApplication]];
		}
	}
return(gInstance);
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
	helpersForObjects = [[NSMapTable mapTableWithKeyOptions:NSPointerFunctionsZeroingWeakMemory valueOptions:NSPointerFunctionsStrongMemory] retain];
	}
return(self);
}

- (void)dealloc
{
[helpersForObjects autorelease];
helpersForObjects = NULL;

if (gInstance == self)
	gInstance = NULL;
//
[super dealloc];
}

#pragma mark -

- (void)addKVOBlock:(KVOBlock)inBlock forKeyPath:(NSString *)inKeyPath target:(id)inTarget options:(NSKeyValueObservingOptions)inOptions identifier:(NSString *)inIdentifier
{
NSAssert(inBlock != NULL, @"No block");
NSAssert(inKeyPath != NULL, @"No key path");
NSAssert(inTarget != NULL, @"No target");

id theKey = [self keyForTarget:inTarget keyPath:inKeyPath identifier:inIdentifier];

NSMapTable *theHelpers = [self.helpersForObjects objectForKey:inTarget];
if (theHelpers == NULL)
	{
	theHelpers = [NSMapTable mapTableWithStrongToStrongObjects];
	[self.helpersForObjects setObject:theHelpers forKey:inTarget];
	}

CKVOBlockNotificationHelper *theHelper = [theHelpers objectForKey:theKey];
if (theHelper != NULL)
	{
	[inTarget removeObserver:theHelper forKeyPath:inKeyPath];
	//
	[theHelpers removeObjectForKey:theKey];
	}

theHelper = [[[CKVOBlockNotificationHelper alloc] initWithTarget:inTarget keyPath:inKeyPath block:inBlock identifier:inIdentifier] autorelease];

[theHelpers setObject:theHelper forKey:theKey];
//
[inTarget addObserver:theHelper forKeyPath:inKeyPath options:inOptions context:self];
}

- (void)removeKVOBlockForKeyPath:(NSString *)inKeyPath target:(id)inTarget identifier:(NSString *)inIdentifier
{
NSAssert(inKeyPath != NULL, @"No key path");
NSAssert(inTarget != NULL, @"No target");

id theKey = [self keyForTarget:inTarget keyPath:inKeyPath identifier:inIdentifier];
NSMapTable *theHelpers = [self.helpersForObjects objectForKey:inTarget];
CKVOBlockNotificationHelper *theHelper = [theHelpers objectForKey:theKey];
if (theHelper)
	{
	[inTarget removeObserver:theHelper forKeyPath:inKeyPath];
	//
	[theHelpers removeObjectForKey:theKey];
	
	if (theHelpers.count == 0)
		[self.helpersForObjects removeObjectForKey:inTarget];
	}
}

- (void)removeAllKVOBlocksForKeyPath:(NSString *)inKeyPath target:(id)inTarget;
{
NSAssert(inKeyPath != NULL, @"No key path");
NSAssert(inTarget != NULL, @"No target");

for (CKVOBlockNotificationHelper *theHelper in self.helpersForObjects)
	{
	if ([theHelper.keyPath isEqualToString:inKeyPath] && theHelper.target == inTarget)
		{
		[self removeKVOBlockForKeyPath:inKeyPath target:inTarget identifier:theHelper.identifier];
		}
	}
}

#pragma mark -

- (id)keyForTarget:(id)inTarget keyPath:(NSString *)inKeyPath identifier:(NSString *)inIdentifier;
{
NSAssert(inKeyPath != NULL, @"No key path");
NSAssert(inTarget != NULL, @"No target");

return([NSString stringWithFormat:@"%x:%@:%@", inTarget, inKeyPath, inIdentifier]);
}

- (void)dump
{
for (id theObject in self.helpersForObjects)
	{
	printf("%s\n", [[theObject description] UTF8String]);
	for (NSString *theKey in [self.helpersForObjects objectForKey:theObject])
		{
		printf("\t%s\n", [[theKey description] UTF8String]);
		}
	}
}

@end

#pragma mark -

@implementation NSObject (NSObject_KVOBlockNotificationCenterExtensions)

- (void)addKVOBlock:(KVOBlock)inBlock forKeyPath:(NSString *)inKeyPath options:(NSKeyValueObservingOptions)inOptions identifier:(NSString *)inIdentifier
{
NSAssert(inBlock != NULL, @"No block");
NSAssert(inKeyPath != NULL, @"No key path");

[[CKVOBlockNotificationCenter instance] addKVOBlock:inBlock forKeyPath:inKeyPath target:self options:inOptions identifier:inIdentifier];
}

- (void)removeKVOBlockForKeyPath:(NSString *)inKeyPath identifier:(NSString *)inIdentifier
{
NSAssert(inKeyPath != NULL, @"No key path");

[[CKVOBlockNotificationCenter instance] removeKVOBlockForKeyPath:inKeyPath target:self identifier:inIdentifier];
}

- (void)removeAllKVOBlocksForKeyPath:(NSString *)inKeyPath;
{
NSAssert(inKeyPath != NULL, @"No key path");

[[CKVOBlockNotificationCenter instance] removeAllKVOBlocksForKeyPath:inKeyPath target:self];
}

#pragma mark -

+ (void)applicationWillTerminate:(NSNotification *)inNotification
{
if (gInstance)
	{
	[gInstance autorelease];
	gInstance = NULL;
	}
}

@end
