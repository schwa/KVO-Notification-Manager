//
//  CKVONotificationCenter.h
//  MOO
//
//  Created by Jonathan Wight on 6/20/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KVOBlock)(NSString *keyPath, id object, NSDictionary *change, id identifier);

@interface CKVOBlockNotificationCenter : NSObject {
	NSMapTable *helpersForObjects;
}

+ (CKVOBlockNotificationCenter *)instance;

- (void)addKVOBlock:(KVOBlock)inBlock forKeyPath:(NSString *)keyPath target:(id)inTarget options:(NSKeyValueObservingOptions)options identifier:(NSString *)inIdentifier;
- (void)removeKVOBlockForKeyPath:(NSString *)keyPath target:(id)inTarget identifier:(NSString *)inIdentifier;
- (void)removeAllKVOBlocksForKeyPath:(NSString *)keyPath target:(id)inTarget;

- (void)dump;

@end

#pragma -

@interface NSObject (NSObject_KVOBlockNotificationCenterExtensions)

- (void)addKVOBlock:(KVOBlock)inBlock forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options identifier:(NSString *)inIdentifier;
- (void)removeKVOBlockForKeyPath:(NSString *)keyPath identifier:(NSString *)inIdentifier;
- (void)removeAllKVOBlocksForKeyPath:(NSString *)keyPath;

@end
