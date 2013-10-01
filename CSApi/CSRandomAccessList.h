//
//  CSRandomAccessList.h
//  CSApi
//
//  Created by Will Harris on 01/10/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSListPage;
@class CSActivityPool;
@class CSProximityCache;

NSString * const kCSRandomAccessListErrorDomain;
NSString * const kCSRandomAccessListKey_Index;
NSInteger const kCSRandomAccessListErrorCode_Abort;

@interface CSRandomAccessList : NSObject

- (instancetype)initWithFirstPage:(id<CSListPage>)firstPage
                             pool:(CSActivityPool *)pool
                            cache:(CSProximityCache *)cache
                   prefetchBehind:(NSUInteger)prefetchBehind
                    prefetchAhead:(NSUInteger)prefetchAhead;

- (void)getPageAtIndex:(NSUInteger)index
              callback:(void (^)(id<CSListPage> page, NSError *error))callback;

@end