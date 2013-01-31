//
//  CSAuthenticator.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSAuthenticator <NSObject>
- (void)applyBasicAuthWithUsername:(NSString *)username
                          password:(NSString *)password;
@end


