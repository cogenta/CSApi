//
//  CSList.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSListPage.h"

@class CSListItem;

@interface CSList : CSCredentialEntity <CSList>

- (id)initWithPage:(CSListPage *)page
         requester:(id<CSRequester>)requester
        credential:(id<CSCredential>)credential;

- (void)getItemAtIndex:(NSUInteger)index
              callback:(void (^)(CSListItem *, NSError *))callback;

@end
