//
//  CSApi.h
//  CSApi
//
//  Created by Will Harris on 28/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSRepresentable.h"

@protocol CSApplication;
@protocol CSUser;

@interface CSApi : NSObject

@property (readonly) NSString *bookmark;
@property (readonly) NSString *username;
@property (readonly) NSString *password;

- (id)initWithBookmark:(NSString *)aBookmark
              username:(NSString *)aUsername
              password:(NSString *)aPassword;
- (void)getApplication:(NSString *)path
              callback:(void (^)(id<CSApplication> app, NSError *error))callback;
- (id<CSUser>) newUser;

@end



@protocol CSApplication <NSObject>

@property (readonly) NSString *name;

- (void)createUser:(id<CSUser>)user
          callback:(void (^)(id<CSUser> user, NSError *error))callback;

@end

@protocol CSUser <CSRepresentable>

@property (readonly) NSURL *url;
@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) NSMutableDictionary *meta;

@end