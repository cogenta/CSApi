//
//  TestAPIStore.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSAPIStore.h"

@protocol CSCredentials;

@interface TestAPIStore : NSObject <CSAPIStore>

@property (nonatomic, strong) NSURL *userUrl;
@property (nonatomic, strong) id<CSCredentials> userCredential;

- (void)resetToFirstLogin;


@end
