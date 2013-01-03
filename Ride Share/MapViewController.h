//
//  MapViewController.h
//  Ride Share
//
//  Created by Luis Valencia on 9/5/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationsController.h"
#import "MyURLConnection.h"
#import "RequestHandler.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    int riderType;
    MKMapView* map;
    NSMutableArray *polyLines; //Keeps Track of all the Route's we're drawing
    LocationsController *routeLocations;
    RequestHandler *hireling;
    NSMutableDictionary *segmentedJSONStrings;
    UIButton *button;
    BOOL firstAnimation;
    int lastPinCount;
}

@property (nonatomic, retain) IBOutlet MKMapView* map;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ofKind: (int) type;
- (void) setLocationController: (LocationsController *) locControl;
- (void) setRequestsHandler: (RequestHandler *) reqHandle;
@end
