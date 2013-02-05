//
//  TestFixtures.h
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NSData *dataForFixture(NSString *fixture);
NSData *appData();
NSData *userPostResponseData();
NSData *userGetResponseData();
NSData *userPutRequestData();
NSData *userPostReponseDataWithReferenceAndMeta();