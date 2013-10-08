//
//  CSLike.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSLike.h"
#import <HyperBek/HyperBek.h>
#import <objc/runtime.h>

@implementation CSLike

- (NSURL *)likedURL
{
    return [self.resource linkForRelation:@"/rels/liked"].URL;
}

- (void)remove:(void (^)(BOOL, NSError *))callback
{
    [self.requester deleteURL:self.URL
                   credential:self.credential
                     callback:^(id result, id etag, NSError *error)
     {
         if (error) {
             callback(NO, error);
             return;
         }
         
         callback(YES, nil);
     }];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@ likedURL=%@>",
            class_getName([self class]), self.URL, self.likedURL];
}

@end


