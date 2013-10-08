//
//  CSCategory.m
//  CSApi
//
//  Created by Will Harris on 22/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCategory.h"
#import <HyperBek/HyperBek.h>
#import <NSArray+Functional/NSArray+Functional.h>
#import "CSProductListPage.h"
#import "CSLinkListItem.h"
#import "CSResourceListItem.h"
#import "CSListPage.h"
#import "CSCategoryList.h"
#import "CSRetailerListPage.h"

@interface CSImmediateSubcategoryListPage : CSListPage <CSCategoryListPage>

@end

@implementation CSImmediateSubcategoryListPage

@synthesize categoryList;

- (id<CSCategoryList>)categoryList
{
    if (  ! categoryList) {
        categoryList = [[CSCategoryList alloc]
                        initWithPage:self
                        requester:self.requester
                        credential:self.credential];
    }
    
    return categoryList;
}

- (id<CSListPage>)pageWithHal:(YBHALResource *)resource
                    requester:(id<CSRequester>)aRequester
                   credential:(id<CSCredential>)aCredential
{
    return [[CSImmediateSubcategoryListPage alloc]
            initWithResource:resource
            requester:self.requester
            credential:self.credential];
}

- (NSUInteger)getCountForResource:(YBHALResource *)resource
{
    NSArray *resources = [resource resourcesForRelation:[self rel]];
    if (resources) {
        return [resources count];
    }
    
    return [[resource linksForRelation:[self rel]] count];
}

- (NSString *)rel
{
    return @"/rels/immediatesubcategory";
}

@end


@implementation CSCategory

@synthesize name;

- (void)loadExtraProperties
{
    name = self.resource[@"name"];
}

- (void)getImmediateSubcategories:(void (^)(id<CSCategoryListPage>,
                                            NSError *))callback
{
    callback([[CSImmediateSubcategoryListPage alloc]
              initWithResource:self.resource
              requester:self.requester
              credential:self.credential],
             nil);
}

@end
