//
//  TestRequester.h
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSApi.h"

@interface TestRequester : NSObject <CSRequester>

@property (nonatomic, readonly) NSString *lastUsername;
@property (nonatomic, readonly) NSString *lastPassword;

- (void)addGetResponse:(id)response forURL:(NSURL *)url;
- (void)addGetError:(id)error forURL:(NSURL *)url;

@end
