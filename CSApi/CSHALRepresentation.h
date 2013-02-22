//
//  CSHALRepresentation.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRepresentation.h"

@interface CSHALRepresentation : NSObject <CSRepresentation>

@property (nonatomic, strong) NSURL *baseURL;
+ (instancetype) representationWithBaseURL:(NSURL *)baseURL;

@end
