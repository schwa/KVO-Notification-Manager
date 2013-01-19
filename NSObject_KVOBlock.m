//
//  NSObject_KVOBlock.m
//  TouchCode
//
//  Created by Jonathan Wight on 07/24/11.
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

#import "NSObject_KVOBlock.h"

#import <objc/runtime.h>

@interface CKVOBlockHelper : NSObject
- (id)initWithObject:(id)inObject;
- (id)makeKeyForKeyPath:(NSString *)inKeyPath;
- (NSString *)keypathForKey:(id)inKey;
- (id)canonicalKeyForKey:(id)inKey;
- (void)setHandler:(KVOFullBlock)inHandler forKey:(id)inKey;
- (void)removeHandlerForKey:(id)inKey;
- (void)dump;
@end

#pragma mark -

@implementation NSObject (NSObject_KVOBlock)

static void *KVO;

- (id)addKVOBlockForKeyPath:(NSString *)inKeyPath options:(NSKeyValueObservingOptions)inOptions handler:(KVOFullBlock)inHandler
    {
    NSParameterAssert(inHandler);
    NSParameterAssert(inKeyPath);
    NSParameterAssert([NSThread isMainThread]); // TODO -- remove and grow a pair.

    CKVOBlockHelper *theHelper = [self helper:YES];
	NSParameterAssert(theHelper != NULL);

    id theKey = [theHelper makeKeyForKeyPath:inKeyPath];

	[theHelper setHandler:inHandler forKey:theKey];

    void *theContext = (__bridge void *)theKey;
    [self addObserver:theHelper forKeyPath:inKeyPath options:inOptions context:theContext];

    return(theKey);
    }
    
- (void)removeKVOBlockForToken:(id)inToken
    {
    CKVOBlockHelper *theHelper = [self helper:NO];
    NSParameterAssert(theHelper != NULL);
	
    void *theContext = (__bridge void *)[theHelper canonicalKeyForKey:inToken];
    NSString *theKeyPath = [theHelper keypathForKey:inToken];
    [self removeObserver:theHelper forKeyPath:theKeyPath context:theContext];

	[theHelper removeHandlerForKey:inToken];
    }

#pragma mark -

- (id)addOneShotKVOBlockForKeyPath:(NSString *)inKeyPath options:(NSKeyValueObservingOptions)inOptions handler:(KVOFullBlock)inHandler
    {
    __block id theToken = NULL;
    KVOFullBlock theBlock = ^(NSString *keyPath, id object, NSDictionary *change) {
        inHandler(keyPath, object, change);
        [self removeKVOBlockForToken:theToken];
        };

    theToken = [self addKVOBlockForKeyPath:inKeyPath options:inOptions handler:theBlock];
    return(theToken);
    }

- (void)KVODump
	{
    CKVOBlockHelper *theHelper = [self helper:NO];
	[theHelper dump];
	}

#pragma mark -

- (CKVOBlockHelper *)helper:(BOOL)inCreate
	{
    CKVOBlockHelper *theHelper = objc_getAssociatedObject(self, &KVO);
    if (theHelper == NULL && inCreate == YES)
        {
        theHelper = [[CKVOBlockHelper alloc] initWithObject:self];

        objc_setAssociatedObject(self, &KVO, theHelper, OBJC_ASSOCIATION_RETAIN);
        }
    return(theHelper);
	}

@end

#pragma mark -

@interface CKVOBlockHelper ()
@property (readonly, nonatomic, weak) id observedObject;
@property (readonly, nonatomic, strong) NSMutableDictionary *handlersByKey;
@property (readwrite, nonatomic, assign) NSInteger nextIdentifier;
@end

#pragma mark -

@implementation CKVOBlockHelper

- (id)initWithObject:(id)inObject
	{
	if ((self = [super init]) != NULL)
		{
        _observedObject = inObject;
		}
	return(self);
	}

- (void)dealloc
    {
    [_handlersByKey enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
		void *theContext = (__bridge void *)[self canonicalKeyForKey:key];
        NSString *theKeypath = [self keypathForKey:key];
        [_observedObject removeObserver:self forKeyPath:theKeypath context:theContext];
        }];
    }

- (NSString *)debugDescription
    {
    return([NSString stringWithFormat:@"%@ (%@, %@, %@)", [self description], self.observedObject, self.handlersByKey, [self.observedObject observationInfo]]);
    }

- (void)dump
	{
	printf("*******************************************************\n");
	printf("%s\n", [[self description] UTF8String]);
	printf("\tObserved Object: %p\n", self.observedObject);
	printf("\tKeys:\n");
	[_handlersByKey enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		printf("\t\t%p\n", key);
		}];
	printf("\tObservationInfo: %s\n", [[(__bridge id)[self.observedObject observationInfo] description] UTF8String]);
	}

- (void)setHandler:(KVOFullBlock)inHandler forKey:(id)inKey
	{
	if (_handlersByKey == NULL)
		{
		_handlersByKey = [NSMutableDictionary dictionary];
		}
	_handlersByKey[inKey] = inHandler;
	}

- (id)makeKeyForKeyPath:(NSString *)inKeyPath
    {
	id inIdentifier = @(self.nextIdentifier++);

    return(@[inKeyPath, inIdentifier]);
    }

- (NSString *)keypathForKey:(id)inKey
    {
    return(inKey[0]);
    }

- (id)canonicalKeyForKey:(id)inKey
    {
	#if 0
    NSArray *theKeys = [_handlersByKey allKeys];
    NSUInteger theIndex = [theKeys indexOfObject:inKey];
    NSAssert(theIndex != NSNotFound, @"KVOBlock never registered");
    NSArray *theKey = theKeys[theIndex];
    return(theKey);
	#else
	return(inKey);
	#endif
    }

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
    {
    NSParameterAssert(context);

    NSArray *theKey = (__bridge NSArray *)context;

    KVOFullBlock theBlock = _handlersByKey[theKey];
    if (theBlock == NULL)
        {
        NSLog(@"Warning: Could not find block for key: %@", theKey);
        }
    else
        {
        theBlock(keyPath, object, change);
        }
    }

@end
