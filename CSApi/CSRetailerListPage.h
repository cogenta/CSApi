//
//  CSRetailerListPage.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSListPage.h"

@interface CSRetailerListPage : CSListPage <CSRetailerListPage>

@property (readonly) id<CSRetailerList> retailerList;

@end
