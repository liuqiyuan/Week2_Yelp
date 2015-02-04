//
//  Business.m
//  Yelp
//
//  Created by Qiyuan Liu on 1/31/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "Business.h"

@implementation Business

- (id)initWithDict: (NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryNames = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryNames addObject:obj[0]];
        }];
        
        self.categories = [categoryNames componentsJoinedByString:@", "];
        self.name = dictionary[@"name"];
        self.phone = dictionary[@"display_phone"];
        self.isClosed = dictionary[@"is_closed"];
        self.imageUrl = dictionary[@"image_url"];
        
        NSArray *addresses = [dictionary valueForKeyPath:@"location.address"];
        NSString *street = addresses.count > 0 ? [NSString stringWithFormat:@"%@, ", addresses[0]] : @"";
        NSArray *neighborhoods = [dictionary valueForKeyPath:@"location.neighborhoods"];
        NSString *neighborhood = neighborhoods.count > 0 ? neighborhoods[0] : @"";
        self.address = [NSString stringWithFormat:@"%@%@", street, neighborhood];
        NSDictionary *coordinate = [dictionary valueForKeyPath:@"location.coordinate"];
        NSString *latitudeStr = coordinate[@"latitude"];
        self.latitude = (CGFloat)[latitudeStr floatValue];
        self.longitude = (CGFloat)[coordinate[@"longitude"] floatValue];
        
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageUrl = dictionary[@"rating_img_url"];
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
    }
    
    return self;
}

+ (NSArray *) businessesWithDicts:(NSArray *)dictionaries {
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Business *business = [[Business alloc]initWithDict:dictionary];
        [result addObject:business];
    }
    return result;
}

@end
