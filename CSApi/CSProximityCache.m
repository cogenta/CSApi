//
//  CSProximityCache.m
//  CSApi
//
//  Created by Will Harris on 27/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProximityCache.h"

@interface CSProximityCache ()

@property (nonatomic, strong) NSMutableDictionary *things;
@property (nonatomic, assign) NSUInteger capacity;

- (NSUInteger)furthestPlaceFromPlace:(NSInteger)place;
- (void)removeFurthestThingFromPlace:(NSInteger)place;

@end

@implementation CSProximityCache

- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self) {
        _things = [[NSMutableDictionary alloc] init];
        _capacity = capacity;
    }
    return self;
}

+ (instancetype)cacheWithCapacity:(NSUInteger)capacity
{
    return [[self alloc] initWithCapacity:capacity];
}

- (void)setObject:(id)obj forPlace:(NSInteger)place
{
    _things[@(place)] = obj;
    
    while ([_things count] > _capacity) {
        [self removeFurthestThingFromPlace:place];
    }
}

- (id)objectForPlace:(NSInteger)place
{
    return _things[@(place)];
}

- (void)removeObjectForPlace:(NSInteger)place
{
    [_things removeObjectForKey:@(place)];
}

- (void)removeFurthestThingFromPlace:(NSInteger)place
{
    [self removeObjectForPlace:[self furthestPlaceFromPlace:place]];
}

- (NSUInteger)furthestPlaceFromPlace:(NSInteger)place
{
    NSArray *sortedPlaces = [[_things allKeys]
                             sortedArrayUsingSelector:@selector(compare:)];
    
    NSInteger smallestPlace = [sortedPlaces[0] integerValue];
    NSInteger greatestPlace = [[sortedPlaces lastObject] integerValue];
    
    if (ABS(smallestPlace - place) > ABS(greatestPlace - place)) {
        return smallestPlace;
    } else {
        return greatestPlace;
    }
}

@end
