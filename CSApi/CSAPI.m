//
//  CSApi.m
//  CSApi
//
//  Created by Will Harris on 28/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPI.h"
#import "CSRequester.h"
#import "CSBasicCredential.h"
#import <HyperBek/HyperBek.h>
#import "CSApplication.h"
#import "CSAPIRequester.h"
#import "CSUserDefaultsAPIStore.h"
#import "CSUser.h"
#import "CSRetailer.h"
#import <objc/runtime.h>

@interface CSAPI () <NSCoding>

- (id<CSRequester>) requester;

@end

@implementation CSAPI

@synthesize bookmark;
@synthesize credential;

- (id)initWithBookmark:(NSString *)aBookmark
            credential:(id<CSCredential>)aCredential
{
    self = [super init];
    if (self) {
        bookmark = aBookmark;
        credential = aCredential;
    }
    return self;
}

- (id)initWithBookmark:(NSString *)aBookmark
              username:(NSString *)aUsername
              password:(NSString *)aPassword
{
    return [self initWithBookmark:aBookmark
                       credential:[CSBasicCredential
                                   credentialWithUsername:aUsername
                                   password:aPassword]];
}

+ (instancetype)apiWithBookmark:(NSString *)bookmark
                       username:(NSString *)username
                       password:(NSString *)password
{
    return [[CSAPI alloc] initWithBookmark:bookmark
                                  username:username
                                  password:password];
}

- (void)getApplication:(void (^)(id<CSApplication> app, NSError *error))callback
{
    id<CSRequester> requester = [self requester];
    [requester getURL:[NSURL URLWithString:bookmark]
           credential:credential
             callback:^(YBHALResource *result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         CSApplication *app = [[CSApplication alloc]
                               initWithResource:result
                               requester:requester
                               credential:credential];
         callback(app, nil);
     }];
}

- (id)requester
{
    return [[CSAPIRequester alloc] init];
}

- (id<CSAPIStore>)store
{
    return [[CSUserDefaultsAPIStore alloc] initWithBookmark:bookmark];
}

- (void)getUser:(NSURL *)URL
     credential:(id<CSCredential>)aCredential
       callback:(void (^)(id<CSUser>, NSError *))callback
{
    id requester = [self requester];
    [requester getURL:URL
           credential:aCredential
             callback:^(YBHALResource *result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         CSUser *user = [[CSUser alloc] initWithResource:result
                                               requester:requester
                                              credential:aCredential
                                                    etag:etag];
         callback(user, nil);
     }];
}

- (void)getRetailer:(NSURL *)URL callback:(void (^)(id<CSRetailer>, NSError *))callback
{
    id requester = [self requester];
    [requester getURL:URL
           credential:self.credential
             callback:^(YBHALResource *result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSRetailer alloc] initWithResource:result
                                             requester:self.requester
                                            credential:self.credential],
                  nil);
     }];
}

- (void)login:(void (^)(id<CSUser>, NSError *))callback
{
    NSURL *storedUserURL = [[self store] userUrl];
    id<CSCredential> storedCredential = [[self store] userCredential];
    
    if (storedUserURL) {
        [self getUser:storedUserURL
           credential:storedCredential
             callback:callback];
        return;
    }
    
    [self getApplication:^(id<CSApplication> app, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         [app createUserWithChange:^(id<CSMutableUser> user) {
             // Do nothing
         } callback:^(id<CSUser> user, NSError *error)
          {
              if (error) {
                  callback(nil, error);
                  return;
              }
              
              [[self store] didCreateUser:user];
              callback(user, nil);
          }];
     }];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s bookmark=%@>",
            class_getName([self class]), bookmark];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithBookmark:[aDecoder decodeObjectForKey:@"bookmark"]
                       credential:[aDecoder decodeObjectForKey:@"credential"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bookmark forKey:@"bookmark"];
    [aCoder encodeObject:self.credential forKey:@"credential"];
}

@end






