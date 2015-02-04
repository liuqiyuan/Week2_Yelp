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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLable;
@property (weak, nonatomic) IBOutlet UILabel *distanceLable;
@property (weak, nonatomic) IBOutlet UILabel *reviewsLable;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UILabel *closedLabel;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem.title = @"Back";
    self.mapView.delegate = self;
    
    self.imageView.layer.cornerRadius = 5;
    self.imageView.clipsToBounds = YES;
    
    // Set propertise
    [self setPropertiesWithBusiness:self.business];

    // Set map center
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.business.latitude, self.business.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (center, 600, 600);
    [self.mapView setRegion:[self.mapView regionThatFits: region] animated:YES];
    [self.mapView addAnnotation:self.mapAnnotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MapAnnotation *mapAnnotation = (MapAnnotation *)annotation;
    MKPinAnnotationView *aView = [[MKPinAnnotationView alloc]initWithAnnotation:mapAnnotation reuseIdentifier:@"id"];
    
    aView.canShowCallout = YES;
    aView.pinColor = MKPinAnnotationColorPurple;
    aView.animatesDrop = YES;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.text = self.business.name;
    aView.rightCalloutAccessoryView = rightButton;
    
    return aView;
}

- (void)setPropertiesWithBusiness:(Business *)business {
    [self.imageView setImageWithURL:[[NSURL alloc]initWithString:business.imageUrl]];
    self.nameLabel.text = business.name;
    self.addressLable.text = business.address;
    [self.phoneButton setTitle:business.phone forState:UIControlStateNormal];
    [self.ratingImageView setImageWithURL:[[NSURL alloc]initWithString:business.ratingImageUrl]];
    if (business.isClosed) {
        self.closedLabel.text = @"Open";
    } else {
        self.closedLabel.text = @"Closed";
    }
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
