//
//  CSRepresentable.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSRepresentation;

@protocol CSRepresentable <NSObject>
- (id)representWithRepresentation:(id<CSRepresentation>)representation;
@end