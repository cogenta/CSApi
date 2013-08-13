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

@interface CSCategoryArrayListPage : CSListPage <CSCategoryListPage>

@property (readonly) NSArray *categories;

@end

@implementation CSCategoryArrayListPage

@synthesize categoryList;

- (id)initWithArray:(NSArray *)categories
          requester:(id<CSRequester>)requester
         credential:(id<CSCredential>)credential
{
    self = [super initWithRequester:requester credential:credential];
    if (self) {
        _categories = categories;
    }
    return self;
}

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

- (NSArray *)items
{
    return self.categories;
}

- (NSUInteger)count
{
    return [self.categories count];
}

- (NSString *)rel
{
    return @"/rels/immediatesubcategory";
}

@end

@interface CSCategory ()
@property (strong, nonatomic) YBHALResource *resource;
@end

@implementation CSCategory

@synthesize name;

- (id)initWithHAL:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential
{
    self = [super initWithRequester:requester credential:credential];
    if (self) {
        self.resource = resource;
        name = self.resource[@"name"];
    }
    return self;
}

- (NSURL *)URL
{
    return [self.resource linkForRelation:@"self"].URL;
}

- (void)getImmediateSubcategories:(void (^)(id<CSCategoryListPage>, NSError *))callback
{
    NSArray *items;
    NSArray *resources = [self.resource resourcesForRelation:@"/rels/immediatesubcategory"];
    if (resources) {
        items = [resources mapUsingBlock:^id(id obj) {
            return [[CSResourceListItem alloc] initWithResource:obj
                                                      requester:self.requester
                                                     credential:self.credential];
        }];
    } else {
        NSArray *links = [self.resource linksForRelation:@"/rels/immediatesubcategory"];
        items = [links mapUsingBlock:^id(id obj) {
            return [[CSLinkListItem alloc] initWithLink:obj
                                              requester:self.requester
                                             credential:self.credential];
        }];
    }

    callback([[CSCategoryArrayListPage alloc] initWithArray:items
                                                  requester:self.requester
                                                 credential:self.credential],
             nil);
}

@end
