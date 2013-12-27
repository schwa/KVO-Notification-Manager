//
//  NSObject+KVOBlock.m
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

#import "NSObject+KVOBlock.h"

#import <objc/runtime.h>

@class CKVOToken;

@interface CKVOBlockHelper : NSObject
@property (readonly, nonatomic, weak) id observedObject;
@property (readonly, nonatomic, strong) NSMutableDictionary *tokensByContext;
@property (readwrite, nonatomic, assign) NSInteger nextIdentifier;
- (id)initWithObject:(id)inObject;
- (CKVOToken *)insertNewTokenForKeyPath:(NSString *)inKeyPath block:(KVOFullBlock)inBlock;
- (void)removeHandlerForKey:(CKVOToken *)inToken;
- (void)dump;
@end

#pragma mark -

@interface CKVOToken : NSObject
@property (readonly, nonatomic, copy) NSString *keypath;
@property (readonly, nonatomic, assign) NSInteger index;
@property (readonly, nonatomic, copy) KVOFullBlock block;
@property (readonly, nonatomic, assign) void *context;
- (id)initWithKeyPath:(NSString *)inKey index:(NSInteger)inIndex block:(KVOFullBlock)inBlock;
@end

#pragma mark -

@implementation NSObject (NSObject_KVOBlock)

static void *KVO;

- (id)addKVOBlockForKeyPath:(NSString *)inKeyPath options:(NSKeyValueObservingOptions)inOptions handler:(KVOFullBlock)inHandler
    {
    NSParameterAssert(inHandler);
    NSParameterAssert(inKeyPath);
    NSParameterAssert([NSThread isMainThread]); // TODO -- remove and grow a pair.

    CKVOBlockHelper *theHelper = KVOBlockHelperForObject(self, YES);
	NSParameterAssert(theHelper != NULL);

    CKVOToken *theToken = [theHelper insertNewTokenForKeyPath:inKeyPath block:inHandler];
	NSParameterAssert(theToken != NULL);

    void *theContext = theToken.context;
	NSParameterAssert(theContext != NULL);

    [self addObserver:theHelper forKeyPath:inKeyPath options:inOptions context:theContext];

    return(theToken);
    }
    
- (void)removeKVOBlockForToken:(CKVOToken *)inToken
    {
    NSParameterAssert([NSThread isMainThread]); // TODO -- remove and grow a pair.
    CKVOBlockHelper *theHelper = KVOBlockHelperForObject(self, NO);
    NSParameterAssert(theHelper != NULL);
	
    void *theContext = inToken.context;
    NSParameterAssert(theContext);
    NSString *theKeyPath = inToken.keypath;
    NSParameterAssert(theKeyPath.length > 0);
    [self removeObserver:theHelper forKeyPath:theKeyPath context:theContext];

	[theHelper removeHandlerForKey:inToken];
    }

#pragma mark -

- (id)addOneShotKVOBlockForKeyPath:(NSString *)inKeyPath options:(NSKeyValueObservingOptions)inOptions handler:(KVOFullBlock)inHandler
    {
    __block CKVOToken *theToken = NULL;
    KVOFullBlock theBlock = ^(NSString *keyPath, id object, NSDictionary *change) {
        inHandler(keyPath, object, change);
        [self removeKVOBlockForToken:theToken];
        };

    theToken = [self addKVOBlockForKeyPath:inKeyPath options:inOptions handler:theBlock];
    return(theToken);
    }

#pragma mark -

static CKVOBlockHelper *KVOBlockHelperForObject(NSObject *object, BOOL inCreate)
    {
    CKVOBlockHelper *theHelper = objc_getAssociatedObject(object, &KVO);
    if (theHelper == NULL && inCreate == YES)
        {
        theHelper = [[CKVOBlockHelper alloc] initWithObject:object];

        objc_setAssociatedObject(object, &KVO, theHelper, OBJC_ASSOCIATION_RETAIN);
        }
    return(theHelper);
	}

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
    __strong NSObject *strong_observedObject = self.observedObject;

    for (CKVOToken *theToken in [_tokensByContext allValues])
        {
		void *theContext = theToken.context;
        NSParameterAssert(theContext != NULL);
        NSString *theKeypath = theToken.keypath;
        NSParameterAssert(theKeypath != NULL);
        [strong_observedObject removeObserver:self forKeyPath:theKeypath context:theContext];
        }
    }

- (NSString *)debugDescription
    {
    __strong NSObject *strong_observedObject = self.observedObject;
    NSString *theDescription = [NSString stringWithFormat:@"%@ (%@, %@, %@)", [self description], strong_observedObject, self.tokensByContext, [strong_observedObject observationInfo]];
    return (theDescription);
    }

- (void)dump
	{
    __strong NSObject *strong_observedObject = self.observedObject;
	printf("*******************************************************\n");
	printf("%s\n", [[self description] UTF8String]);
	printf("\tObserved Object: %p\n", (__bridge void *)strong_observedObject);
	printf("\tKeys:\n");
	[_tokensByContext enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, CKVOToken *token, BOOL *stop) {
		printf("\t\t%s\n", [[index description] UTF8String]);
		}];
	printf("\tObservationInfo: %s\n", [[(__bridge id)[strong_observedObject observationInfo] description] UTF8String]);
	}

- (void)removeHandlerForKey:(CKVOToken *)inToken
	{
    [_tokensByContext removeObjectForKey:@(inToken.index)];
	if (_tokensByContext.count == 0)
		{
         _tokensByContext = NULL;
		}
	}

- (CKVOToken *)insertNewTokenForKeyPath:(NSString *)inKeyPath block:(KVOFullBlock)inBlock
    {
    CKVOToken *theToken = [[CKVOToken alloc] initWithKeyPath:inKeyPath index:++self.nextIdentifier block:inBlock];
    if (_tokensByContext == NULL)
        {
        _tokensByContext = [NSMutableDictionary dictionary];
        }
    _tokensByContext[@(theToken.index)] = theToken;
    return(theToken);
    }

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
    {
    NSParameterAssert(context);

    NSNumber *theKey = @((NSInteger)context);

    CKVOToken *theToken= _tokensByContext[theKey];
    if (theToken == NULL)
        {
        NSLog(@"Warning: Could not find block for key: %@", theKey);
        }
    else
        {
        theToken.block(keyPath, object, change);
        }
    }

@end

@implementation CKVOToken

- (id)initWithKeyPath:(NSString *)inKey index:(NSInteger)inIndex block:(KVOFullBlock)inBlock
    {
    if ((self = [super init]) != NULL)
        {
        _keypath = inKey;
        _index = inIndex;
        _block = inBlock;
        }
    return self;
    }

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (%@ #%ld)", [super description], self.keypath, (unsigned long)self.index]);
    }

- (void *)context
    {
    return((void *)self.index);
    }

@end
