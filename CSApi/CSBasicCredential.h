//
//  CSBasicCredential.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCredential.h"

@class CSAPI;

@interface CSBasicCredential : NSObject <CSCredential>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword;
- (id)initWithDictionary:(NSDictionary *)credential;

+ (instancetype)credentialWithUsername:(NSString *)username
                              password:(NSString *)password;
+ (instancetype)credentialWithDictionary:(NSDictionary *)credential;

@end