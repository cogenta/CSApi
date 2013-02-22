//
//  CSMutableUser.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPI.h"
#import "CSRepresentable.h"

@interface CSMutableUser : NSObject <CSMutableUser, CSRepresentable>

- (id)init;
- (id)initWithUser:(id<CSUser>)user;

@end