//
//  TestApi.h
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPI.h"

@class TestRequester;
@class TestAPIStore;

@interface TestApi : CSAPI

@property (weak, readwrite) TestRequester *requester;
@property (weak, readwrite) TestAPIStore *store;

@end