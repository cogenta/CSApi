//
//  CSApi.h
//  CSApi
//
//  Created by Will Harris on 28/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSRequester <NSObject>
- (void)getURL:(NSURL *)url
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

@end