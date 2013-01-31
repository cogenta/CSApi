//
//  CSAPIStore.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSUser;
@protocol CSCredentials;

@protocol CSAPIStore <NSObject>

- (void)didCreateUser:(id<CSUser>)user;
- (NSURL *)userUrl;
- (id<CSCredentials>)userCredential;

@end
