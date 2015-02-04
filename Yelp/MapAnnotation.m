//
//  MapAnnotation.m
//  Yelp
//
//  Created by Qiyuan Liu on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "MapAnnotation.h"
#import "MapKit/MapKit.h"
#import "Business.h"

@implementation MapAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

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

- (void)setSubTitle:(NSString *)subTitleStr {
    title = [NSString stringWithString:subTitleStr];
}

- (void)setBusiness:(Business *)business {
    self.business = business;
}

@end
