//
//  CSApi.h
//  CSApi
//
//  Created by Will Harris on 28/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSAuthenticator <NSObject>
- (void)applyBasicAuthWithUsername:(NSString *)username
                          password:(NSString *)password;
@end

@protocol CSCredentials <NSObject>
- (void)applyWith:(id<CSAuthenticator>)authenticator;
@end

@protocol CSRequester <NSObject>
- (void)getURL:(NSURL *)url
   credentials:(id<CSCredentials>)credentials
      callback:(void (^)(id result, NSError *error))callback;
@end

@protocol CSApplication;

@interface CSApi : NSObject

@property (readonly) NSString *bookmark;
@property (readonly) NSString *username;
@property (readonly) NSString *password;

- (id)initWithBookmark:(NSString *)aBookmark
              username:(NSString *)aUsername
              password:(NSString *)aPassword;
- (void)getApplication:(NSString *)path
              callback:(void (^)(id<CSApplication> app, NSError *error))callback;

@end



@protocol CSApplication <NSObject>

@property (readonly) NSString *name;

@end