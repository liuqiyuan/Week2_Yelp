//
//  MapAnnotation.m
//  Yelp
//
//  Created by Qiyuan Liu on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "MapAnnotation.h"
#import "MapKit/MapKit.h"

@implementation MapAnnotation

@synthesize coordinate;
@synthesize title;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}

- (void)setTitle:(NSString *)titleStr {
    title = [NSString stringWithString:titleStr];
}

@end
