//
//  CSBasicCredential.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSCredential.h"

@class CSApi;

@interface CSBasicCredential : NSObject <CSCredential>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

- (id)initWithApi:(CSApi *)api;
- (id)initWithDictionary:(NSDictionary *)credential;

+ (instancetype) credentialWithApi:(CSApi *)api;
+ (instancetype) credentialWithDictionary:(NSDictionary *)credential;

@end