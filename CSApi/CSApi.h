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
@protocol CSMutableUser;
@protocol CSCredential;

@interface CSApi : NSObject

@property (readonly) NSString *bookmark;
@property (readonly) NSString *username;
@property (readonly) NSString *password;

- (id)initWithBookmark:(NSString *)aBookmark
              username:(NSString *)aUsername
              password:(NSString *)aPassword;

- (void)getApplication:(NSString *)path
              callback:(void (^)(id<CSApplication> app, NSError *error))callback;

- (void)getUser:(NSURL *)url
     credential:(id<CSCredential>)credential
       callback:(void (^)(id<CSUser>, NSError *))callback;

- (void)login:(void (^)(id<CSUser> user, NSError *error))callback;

@end



@protocol CSApplication <NSObject>

@property (readonly) NSString *name;

- (void)createUser:(void (^)(id<CSUser> user, NSError *error))callback;
- (void)createUserWithChange:(void (^)(id<CSMutableUser> user))change
                    callback:(void (^)(id<CSUser> user, NSError *error))callback;

@end


@protocol CSUser <NSObject>

@property (readonly) NSURL *url;
@property (readonly) id etag;
@property (readonly) id<CSCredential> credential;
@property (readonly) NSString *reference;
@property (readonly) NSMutableDictionary *meta;

- (void)change:(void (^)(id<CSMutableUser> user))change
      callback:(void (^)(BOOL success, NSError *error))callback;

@end

@protocol CSMutableUser <CSRepresentable>

@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) NSMutableDictionary *meta;

@end