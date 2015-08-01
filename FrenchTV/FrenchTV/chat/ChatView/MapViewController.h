//
//  MapViewController.h
//  FrenchTV
//
//  Created by mac on 15/3/7.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface MapViewController : UIViewController
@property (strong,nonatomic) void(^sendLocationBlock)(CLLocation *);

@end
