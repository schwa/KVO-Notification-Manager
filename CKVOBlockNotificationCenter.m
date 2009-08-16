//
//  CKVONotificationCenter.m
//  MOO
//
//  Created by Jonathan Wight on 6/20/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//

#import "CKVOBlockNotificationCenter.h"

#import "CKVOBlockNotificationHelper.h"

static CKVOBlockNotificationCenter *gInstance = NULL;

@interface CKVOBlockNotificationCenter ()
@property (readwrite, retain) NSMapTable *helpersForObjects;

- (id)keyForTarget:(id)inTarget keyPath:(NSString *)keyPath identifier:(NSString *)inIdentifier;
@end

#pragma mark -

@implementation CKVOBlockNotificationCenter

@synthesize helpersForObjects;

+ (CKVOBlockNotificationCenter *)instance
{
if (gInstance == NULL)
	{
	gInstance = [[self alloc] init];
	}
return(gInstance);
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
//	self.helpersForObjects = [NSMapTable mapTableWithWeakToStrongObjects];
	self.helpersForObjects = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsZeroingWeakMemory valueOptions:NSPointerFunctionsStrongMemory];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:[NSApplication sharedApplication]];

	}
return(self);
}

- (void)dealloc
{
[helpersForObjects autorelease];
helpersForObjects = NULL;
//
[super dealloc];
}

- (void)addKVOBlock:(KVOBlock)inBlock forKeyPath:(NSString *)keyPath target:(id)inTarget options:(NSKeyValueObservingOptions)options identifier:(NSString *)inIdentifier
{
id theKey = [self keyForTarget:inTarget keyPath:keyPath identifier:inIdentifier];

NSMapTable *theHelpers = [self.helpersForObjects objectForKey:inTarget];
if (theHelpers == NULL)
	{
	theHelpers = [NSMapTable mapTableWithStrongToStrongObjects];
	[self.helpersForObjects setObject:theHelpers forKey:inTarget];
	}

CKVOBlockNotificationHelper *theHelper = [theHelpers objectForKey:theKey];
if (theHelper != NULL)
	{
	[inTarget removeObserver:theHelper forKeyPath:keyPath];
	//
	[theHelpers removeObjectForKey:theKey];
	}

theHelper = [[[CKVOBlockNotificationHelper alloc] initWithTarget:inTarget keyPath:keyPath block:inBlock identifier:inIdentifier] autorelease];

[theHelpers setObject:theHelper forKey:theKey];
//
[inTarget addObserver:theHelper forKeyPath:keyPath options:options context:self];
}

- (void)removeKVOBlockForKeyPath:(NSString *)keyPath target:(id)inTarget identifier:(NSString *)inIdentifier
{
id theKey = [self keyForTarget:inTarget keyPath:keyPath identifier:inIdentifier];
NSMapTable *theHelpers = [self.helpersForObjects objectForKey:inTarget];
CKVOBlockNotificationHelper *theHelper = [theHelpers objectForKey:theKey];
if (theHelper)
	{
	[inTarget removeObserver:theHelper forKeyPath:keyPath];
	//
	[theHelpers removeObjectForKey:theKey];
	}
}

- (void)removeAllKVOBlocksForKeyPath:(NSString *)keyPath target:(id)inTarget;
{
for (CKVOBlockNotificationHelper *theHelper in self.helpersForObjects)
	{
	if ([theHelper.keyPath isEqualToString:keyPath] && theHelper.target == inTarget)
		{
		}
	}
}

#pragma mark -

- (id)keyForTarget:(id)inTarget keyPath:(NSString *)keyPath identifier:(NSString *)inIdentifier;
{
return([NSString stringWithFormat:@"%@:%@", keyPath, inIdentifier]);
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

- (void)addKVOBlock:(KVOBlock)inBlock forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options identifier:(NSString *)inIdentifier
{
[[CKVOBlockNotificationCenter instance] addKVOBlock:inBlock forKeyPath:keyPath target:self options:options identifier:inIdentifier];
}

- (void)removeKVOBlockForKeyPath:(NSString *)keyPath identifier:(NSString *)inIdentifier
{
[[CKVOBlockNotificationCenter instance] removeKVOBlockForKeyPath:keyPath target:self identifier:inIdentifier];
}

- (void)removeAllKVOBlocksForKeyPath:(NSString *)keyPath;
{
[[CKVOBlockNotificationCenter instance] removeAllKVOBlocksForKeyPath:keyPath target:self];
}

#pragma mark -

- (void)applicationWillTerminate:(NSNotification *)inNotification
{
NSLog(@"APPLICATION WILL TERMINATE");
[gInstance autorelease];
gInstance = NULL;
}

@end
