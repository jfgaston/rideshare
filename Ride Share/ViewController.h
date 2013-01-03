//
//  ViewController.h
//  Ride Share
//
//  Created by Luis Valencia on 9/5/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MapViewController.h"
#import "GridViewController.h"
#import "LocationsController.h"
#import "RequestHandler.h"

@interface ViewController : UIViewController<UIGestureRecognizerDelegate>
{
    id currentView;
    MapViewController *mapView;
    GridViewController *gridView;
    LocationsController *routeLocations;
    RequestHandler* requests;
}

@property (nonatomic, retain) id currentView;
@property (nonatomic, retain) LocationsController *routeLocations;
@end
