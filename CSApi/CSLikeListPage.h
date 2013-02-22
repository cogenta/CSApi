//
//  CSLikeListPage.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSListPage.h"

@interface CSLikeListPage : CSListPage <CSLikeListPage>

@property (readonly) id<CSLikeList> likeList;

@end
