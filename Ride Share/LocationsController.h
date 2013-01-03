//
//  LocationsController.h
//  Ride Share
//
//  Created by Luis Valencia on 9/6/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import <Parse/Parse.h>

@interface LocationsController : NSObject {
    NSMutableArray *validLocations;
    Location *startPoint;
    Location *endPoint;
    CLLocationManager *locationManager;
    PFObject *currentLocation;
    BOOL isOnRoute;
}

@property (atomic, assign) BOOL isOnRoute;
@property (nonatomic, retain) NSMutableArray *validLocations;
@property (nonatomic, retain) Location *startPoint, *endPoint;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) PFObject *currentLocation;

- (BOOL) addLocation: (Location *) potentialLocation;
- (LocationsController *) initWithStartPoint:(NSString *) start andEndPoint: (NSString *) end;
- (BOOL) isOnRoute: (Location *) loc;
- (NSMutableArray *) onRoute;
- (NSMutableArray *) availableWayPoints;
- (CLLocationManager *)locationManager;
- (void) insertCurrentLocation;

@end
