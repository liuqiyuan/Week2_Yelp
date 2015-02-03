//
//  MapViewController.h
//  Yelp
//
//  Created by Qiyuan Liu on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) MapAnnotation *mapAnnotation;

@end
