//
//  CSListPage.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCredentialEntity.h"

@class YBHALResource;

@interface CSListPage : CSCredentialEntity <CSListPage>

- (instancetype)pageWithHal:(YBHALResource *)resource;

@end
