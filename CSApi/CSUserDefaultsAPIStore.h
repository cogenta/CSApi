//
//  CSUserDefaultsAPIStore.h
//  CSApi
//
//  Created by Will Harris on 06/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSAPIStore.h"

@interface CSUserDefaultsAPIStore : NSObject <CSAPIStore>

- (id)initWithBookmark:(NSString *)bookmark;

@end
