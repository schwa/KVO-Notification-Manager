//
//  CKVOBlockNotificationCenter.h
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

#import <Foundation/Foundation.h>

typedef void (^KVOBlock)(NSString *keyPath, id object, NSDictionary *change, id identifier);

/// You do not have to use CKVOBlockNotificationCenter. Use the NSObject category instead.
@interface CKVOBlockNotificationCenter : NSObject {
	NSMapTable *helpersForObjects;
}

+ (CKVOBlockNotificationCenter *)instance;

- (void)addKVOBlock:(KVOBlock)inBlock forKeyPath:(NSString *)keyPath target:(id)inTarget options:(NSKeyValueObservingOptions)options identifier:(NSString *)inIdentifier;
- (void)removeKVOBlockForKeyPath:(NSString *)keyPath target:(id)inTarget identifier:(NSString *)inIdentifier;
- (void)removeAllKVOBlocksForKeyPath:(NSString *)keyPath target:(id)inTarget;

- (void)dump;

@end

#pragma mark -

/// KVOBlock extensions to NSObject allow any object to easily register (add) and unregister (remove) block based notifications.
@interface NSObject (NSObject_KVOBlockNotificationCenterExtensions)

- (void)addKVOBlock:(KVOBlock)inBlock forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options identifier:(NSString *)inIdentifier;
- (void)removeKVOBlockForKeyPath:(NSString *)keyPath identifier:(NSString *)inIdentifier;
- (void)removeAllKVOBlocksForKeyPath:(NSString *)keyPath;

@end
