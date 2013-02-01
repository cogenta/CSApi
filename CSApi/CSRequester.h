//
//  CSRequester.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSCredential;

@protocol CSRequester <NSObject>
- (void)getURL:(NSURL *)url
    credential:(id<CSCredential>)credential
      callback:(void (^)(id result, NSError *error))callback;
- (void)postURL:(NSURL *)url
     credential:(id<CSCredential>)credential
           body:(id)body
       callback:(void (^)(id result, NSError *error))callback;
@end
