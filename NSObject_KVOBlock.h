//
//  NSObject_KVOBlock.h
//  MOO
//
//  Created by Jonathan Wight on 07/24/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KVOBlock)(NSString *keyPath, id object, NSDictionary *change);

@interface NSObject (NSObject_KVOBlock)

- (id)addKVOBlockForKeyPath:(NSString *)inKeyPath options:(NSUInteger)inOptions handler:(KVOBlock)inHandler;
- (id)addKVOBlockForKeyPath:(NSString *)inKeyPath options:(NSUInteger)inOptions identifier:(NSString *)inIdentifier handler:(KVOBlock)inHandler;

- (void)removeKVOBlockForToken:(id)inToken;
- (void)removeKVOBlockForKeyPath:(NSString *)inKeyPath identifier:(NSString *)inIdentifier;

- (NSArray *)allKVOObservers;

@end
