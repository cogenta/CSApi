//
//  TestRequester.h
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSRequester.h"

@interface TestRequester : NSObject <CSRequester>

@property (nonatomic, readonly) NSString *lastUsername;
@property (nonatomic, readonly) NSString *lastPassword;

- (void)addGetResponse:(id)response forURL:(NSURL *)url;
- (void)addGetError:(NSError *)error forURL:(NSURL *)url;
- (void)addPostResponse:(id)response forURL:(NSURL *)url;
- (void)addPostCallback:(void (^)(id, void (^)(id, NSError *)))callback
                 forURL:(NSURL *)url;

@end
