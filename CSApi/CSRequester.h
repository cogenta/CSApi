//
//  CSRequester.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSCredentials;

@protocol CSRequester <NSObject>
- (void)getURL:(NSURL *)url
   credentials:(id<CSCredentials>)credentials
      callback:(void (^)(id result, NSError *error))callback;
- (void)postURL:(NSURL *)url
    credentials:(id<CSCredentials>)credentials
           body:(id)body
       callback:(void (^)(id result, NSError *error))callback;
@end
