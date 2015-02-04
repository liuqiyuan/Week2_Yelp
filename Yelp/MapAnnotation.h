//
//  MapAnnotation.h
//  Yelp
//
//  Created by Qiyuan Liu on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"
#import "Business.h"

@interface MapAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithLocation:(CLLocationCoordinate2D)coord;
- (void)setTitle:(NSString *)titleStr;
- (void)setSubTitle:(NSString *)subTitleStr;
- (void)setBusiness:(Business *)business;

@property (nonatomic, strong) Business *business;

@end
