//
//  MapViewController.m
//  Yelp
//
//  Created by Qiyuan Liu on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"
#import "UIImageView+AFNetworking.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem.title = @"Back";
    self.mapView.delegate = self;
    
    [self.mapView addAnnotation:self.mapAnnotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MapAnnotation *mapAnnotation = (MapAnnotation *)annotation;
    MKPinAnnotationView *aView = [[MKPinAnnotationView alloc]initWithAnnotation:mapAnnotation reuseIdentifier:@"id"];
    
    aView.canShowCallout = YES;
    aView.pinColor = MKPinAnnotationColorPurple;
    aView.animatesDrop = YES;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.text = mapAnnotation.reviewsNum;
    aView.rightCalloutAccessoryView = rightButton;
    
    UIImageView *imageView;
    [imageView setImageWithURL:[NSURL URLWithString:mapAnnotation.imageUrl]];
    aView.leftCalloutAccessoryView = imageView;
    
    return aView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
