//
//  CKVONotificationHelper.h
//  MOO
//
//  Created by Jonathan Wight on 6/20/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CKVOBlockNotificationCenter.h"

@interface CKVOBlockNotificationHelper : NSObject {
	__weak id target;
	NSString *keyPath;
	KVOBlock block;
	NSString *identifier;
}

@property (readwrite, assign) __weak id target;
@property (readwrite, copy) NSString *keyPath;
@property (readwrite, copy) KVOBlock block;
@property (readwrite, copy) NSString *identifier;

- (id)initWithTarget:(id)inTarget keyPath:(NSString *)inKeyPath block:(KVOBlock)inBlock identifier:(NSString *)inIdentifier;

@end
