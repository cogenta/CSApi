//
//  CSBasicCredentials.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSCredentials.h"

@class CSApi;

@interface CSBasicCredentials : NSObject <CSCredentials>

@property (nonatomic, weak) CSApi *api;
- (id)initWithApi:(CSApi *)api;

+ (instancetype) credentialsWithApi:(CSApi *)api;

@end