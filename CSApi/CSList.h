//
//  CSList.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSListPage.h"

@interface CSList : CSCredentialEntity <CSList>

@property (readonly) id<CSListPage> firstPage;
@property (readonly) id<CSListPage> lastPage;
@property (readonly) NSMutableArray *items;
@property (readonly) BOOL isLoading;

- (id)initWithPage:(CSListPage *)page
         requester:(id<CSRequester>)requester
        credential:(id<CSCredential>)credential;

- (void)loadPage:(id<CSListPage>)page;

- (void)getItemAtIndex:(NSUInteger)index
              callback:(void (^)(id<CSListItem> item, NSError *))callback;

@end
