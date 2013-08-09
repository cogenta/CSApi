//
//  CSNarrow.m
//  CSApi
//
//  Created by Will Harris on 08/08/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSNarrow.h"
#import "CSSlice.h"
#import "CSRetailer.h"
#import "CSCategory.h"

@interface CSNarrow ()
@property (strong, nonatomic) YBHALResource *resource;
@end

@implementation CSNarrow

- (id)initWithHAL:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential
{
    self = [super initWithRequester:requester credential:credential];
    if (self) {
        self.resource = resource;
    }
    return self;
}

- (void)getSlice:(void (^)(id<CSSlice> result, NSError *error))callback
{
    [self getRelation:@"/rels/slice"
          forResource:self.resource
             callback:^(YBHALResource *result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         if ( ! result) {
             callback(nil, nil);
             return;
         }
         
         callback([[CSSlice alloc] initWithHAL:result
                                     requester:self.requester
                                    credential:self.credential],
                  nil);
     }];
}

- (void)getNarrowsByRetailer:(void (^)(id<CSRetailer> result,
                                       NSError *error))callback
{
    [self getRelation:@"/rels/narrowsbyretailer"
          forResource:self.resource
             callback:^(YBHALResource *result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         if ( ! result) {
             callback(nil, nil);
             return;
         }
         
         callback([[CSRetailer alloc] initWithResource:result
                                             requester:self.requester
                                            credential:self.credential],
                  nil);
     }];
}

- (void)getNarrowsByCategory:(void (^)(id<CSCategory> result,
                                       NSError *error))callback
{
    [self getRelation:@"/rels/narrowsbycategory"
          forResource:self.resource
             callback:^(YBHALResource *result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         if ( ! result) {
             callback(nil, nil);
             return;
         }
         
         callback([[CSCategory alloc] initWithHAL:result
                                        requester:self.requester
                                       credential:self.credential],
                  nil);
     }];
}

@end
