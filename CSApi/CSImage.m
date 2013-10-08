//
//  CSImage.m
//  CSApi
//
//  Created by Will Harris on 05/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSImage.h"
#import <HyperBek/HyperBek.h>

@interface CSImage ()

@property (strong, nonatomic) YBHALResource *resource;

@end

@implementation CSImage

@synthesize width;
@synthesize height;
@synthesize enclosureURL;
@synthesize enclosureType;

- (void)loadExtraProperties
{
    width = self.resource[@"width"];
    height = self.resource[@"height"];
}

- (void)loadEnclosure
{
    YBHALLink *enclosure = [self.resource linkForRelation:@"enclosure"];
    enclosureURL = enclosure.URL;
    enclosureType = enclosure.type;
}

- (NSString *)enclosureType
{
    if ( ! enclosureType && ! enclosureURL) {
        [self loadEnclosure];
    }
    
    return enclosureType;
}

- (NSURL *)enclosureURL
{
    if ( ! enclosureType && ! enclosureURL) {
        [self loadEnclosure];
    }
    
    return enclosureURL;
}

@end
