//
//  LocationsController.m
//  Ride Share
//
//  Created by Luis Valencia on 9/6/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import "LocationsController.h"
#import "SwissKnife.h"

@interface LocationsController ()
- (BOOL) isValidLocation: (Location *) potentialLocation;
@end

@implementation LocationsController

@synthesize isOnRoute;
@synthesize validLocations;
@synthesize startPoint, endPoint;
@synthesize locationManager;
@synthesize currentLocation;

- (LocationsController *) initWithStartPoint:(NSString *) start andEndPoint: (NSString *) end{
    self = [super init];
    if (self)
    {
        startPoint = [[Location alloc] initWithAddress:start isStart: YES];
        endPoint =[[Location alloc] initWithAddress:end isEnd:YES];
        validLocations = [[NSMutableArray alloc] init];
        //Location Manager Services
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [locationManager setDistanceFilter:100.0];
        [locationManager setPurpose:@"Current User Location used for P2P RideShare Hook-Ups"];
        isOnRoute = NO;
    }    
    return self;
}
- (NSMutableArray *) onRoute{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (Location* loc in validLocations)
    {
        if ([loc isOnRoute])
        {
            [result addObject:loc];
        }
    }
    return result;
}
- (NSMutableArray *) availableWayPoints{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (Location* loc in validLocations)
    {
        if ([loc isWayPoint])
        {
            [result addObject:loc];
        }
    }
    return result;
}
//Method: isOnRoute
//Purpose: Checks if a Provided Address is Already On Route
- (BOOL) isOnRoute: (Location *) loc
{
    NSString *address = [loc address];
    if ([address isEqualToString:[startPoint address]]){ return YES; }
    else if ([address isEqualToString:[endPoint address]]){ return YES; }
    for (Location *compare in [self onRoute]){
        if ([address isEqualToString:[compare address]]){ return YES; }
    }
    return NO;
}
//Method: isValidLocation
//Purpose: Performs a Check to See if the Given Location is a Valid One
- (BOOL) isValidLocation: (Location *) potentialLocation{
    //perform a check
    return YES;
}
//Method: addLocation
//Purpose: Check's to See if the Location Given is Valid and if it is it adds it to validLocations
//         and indicates that it did so, if not it indicates that it did not add it
- (BOOL) addLocation:(Location *)potentialLocation {
    if ([self isValidLocation:potentialLocation]){
        [validLocations addObject:potentialLocation];
        return YES;
    }
    return NO;
}

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {
	
    if (locationManager != nil) {
		return locationManager;
	}
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //[locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation]; //If Plugged In
    [locationManager setDistanceFilter:100.0];
    [locationManager setPurpose:@"Current User Location used for P2P RideShare Hook-Ups"];
	
	return locationManager;
}
- (void) insertCurrentLocation {
    NSLog(@"Method was Called");
	// If it's not possible to get a location, then return.
	CLLocation *location = [locationManager location];
	if (!location) {
        NSLog(@"Exited");
		return;
	}
    
	// Configure the new event with information from the location.
	CLLocationCoordinate2D coordinate = [location coordinate];
    Location *loc = [[Location alloc] initWithGeoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    [loc setHeader:[NSString stringWithFormat:@"UserName#%d", [[PFQuery queryWithClassName:@"Riders"] countObjects]]];
    
    if (!currentLocation)
    {
        currentLocation = [PFObject objectWithClassName:@"Riders"];
    }
    [currentLocation setObject:[loc header] forKey:@"header"];
    [currentLocation setObject: [loc geoPoint] forKey:@"geoPoint"];
    [loc setLocationType:LOCATION_REQUEST];
    [loc setLocationGridType:GRID_KNOWN_WAYPOINT_REQUEST];
    
    [currentLocation setObject: [NSNumber numberWithInt: [SwissKnife cantor:[loc locationType] with:[loc locationGridType]]] forKey:@"locationType"];
    
    if (!isOnRoute){
        [loc setIsWayPoint:YES];
    }
    else{
        [loc setIsOnRoute:YES];
    }
    
    short s = 0;
    if ([loc isStartPoint]){ s = 1; }
    else if ([loc isEndPoint]){ s = 2; }
    else if ([loc isWayPoint]){ s = 3; }
    else if ([loc isOnRoute]){ s = 4; }
    
    [currentLocation setObject:[NSNumber numberWithShort:s] forKey:@"pointType"];
    
    [currentLocation saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Saved Current Location");
            // Reload the PFQueryTableViewController
        }
    }];
}


@end
