//
//  MapViewController.m
//  Ride Share
//
//  Created by Luis Valencia on 9/5/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import "MapViewController.h"
#import "SwissKnife.h"
#import "MyAnnotationController.h"
#import "MyRouteOverlay.h"
#import "SBJson.h"

@interface MapViewController ()
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
@end

@implementation MapViewController

@synthesize map;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ofKind: (int) type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        riderType = type;
        segmentedJSONStrings = [[NSMutableDictionary alloc] init];
        polyLines = [[NSMutableArray alloc] init];
        firstAnimation = YES;
    }
    return self;
}
- (void) setLocationController: (LocationsController *) locControl{
    self->routeLocations = locControl;
}
- (void) setRequestsHandler: (RequestHandler *) reqHandle{
    self->hireling = reqHandle;
}
//Method:viewWillAppear
//Purpose: Put Map Init Stuff Here so when the View Loads it appears quicker
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (firstAnimation)
    {
        map.mapType = MKMapTypeStandard;
        [map setDelegate:self];
        [hireling searchCoordinatesForLocation:[routeLocations startPoint] ofType:LOCATION_REQUEST setDelegate:self];
        [hireling searchCoordinatesForLocation:[routeLocations endPoint] ofType:LOCATION_REQUEST setDelegate:self];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewDidAppear:YES];
    // Do any additional setup after loading the view.
}
- (void) viewDidAppear:(BOOL)animated{
    [map removeOverlays:polyLines];
    [polyLines removeAllObjects];
    for (Location* loc in [routeLocations onRoute])
    {
        NSLog(@"Map: is On Route %@", [loc address]);
    }
    
    [hireling searchForDirectionsGivenStartPoint:[routeLocations startPoint] andEndPoint:[routeLocations endPoint] withWayPoints:[routeLocations onRoute] shouldSearchOptimally:YES shouldUtilizeSensor:NO andConnnectionType:DIRECTIONS_REQUEST setDelegate:self forLocation:nil];
    [self updateLocations];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//Method: Connection didReceiveData
//Purpose: What we do with the Data Depening on the Type of Request that was Made
//         It's called by the NSURLConnection delegate
- (void)connection:(MyURLConnection *)connection didReceiveData:(NSData *)data
{
    //The string received from google's servers
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //Deal with Segmented JSON Response
    NSDictionary *results = [SwissKnife handleSegmentedJsonResponse:connection forSegmentedResponse:jsonString];
    if (!results) return;
    
    if ([connection typeOfConnection] == LOCATION_REQUEST ||
        [connection typeOfConnection] == UNKNOWN_REQUEST ||
        [connection typeOfConnection] == SCRAPE_REQUEST)
    {
        //Now we need to obtain our coordinates
        NSArray *placemark  = [results objectForKey:@"Placemark"];
        NSArray *coordinates = [[placemark objectAtIndex:0] valueForKeyPath:@"Point.coordinates"];
        NSString *address = [[placemark objectAtIndex:0] objectForKey:@"address"];
        
        //I put my coordinates in my array.
        float longitude = [[coordinates objectAtIndex:0] doubleValue];
        float latitude = [[coordinates objectAtIndex:1] doubleValue];
        
        //Create the location
        CLLocationCoordinate2D coord;
        coord.latitude = latitude;
        coord.longitude = longitude;
        
        MyAnnotationController *anAnnotation = [[MyAnnotationController alloc] initWithCoordinate:coord];
        if ([[connection locAffiliation] isStartPoint]) //If it's the StartPoint
        {
            //Set up Area Which will be initial display
            MKCoordinateSpan span;
            span.latitudeDelta = 0.1;
            span.longitudeDelta = 0.1;
            MKCoordinateRegion region = {coord, span};
            [map regionThatFits:region];
            [map setRegion:region animated:YES];
            [anAnnotation setTitle:@"Start"];
            [anAnnotation setSubTitle:address];
            [anAnnotation setColorValue:GREEN];
            [anAnnotation setLoc:[connection locAffiliation]];
            [map addAnnotation:anAnnotation];
        }
        else if ([[connection locAffiliation] isEndPoint]) //If it's the endPoint
        {
            [anAnnotation setTitle:@"End"];
            [anAnnotation setSubTitle:address];
            [anAnnotation setColorValue:GREEN];
            [anAnnotation setLoc:[connection locAffiliation]];
            [map addAnnotation:anAnnotation];
        }
        else
        {
            [anAnnotation setTitle:@"Driver/Passanger"];
            [anAnnotation setSubTitle:address];
            //Decide Color
            if ([connection typeOfConnection] == LOCATION_REQUEST)
            {
                [anAnnotation setColorValue:PURPLE];
            }
            else if ([connection typeOfConnection] == UNKNOWN_REQUEST)
            {
                [anAnnotation setColorValue:ORANGE];
            }
            else {
                [anAnnotation setColorValue:GREY];
            }
            [anAnnotation shouldHaveDetailDisclosure:YES];
            [anAnnotation setLoc:[connection locAffiliation]];
            [map addAnnotation:anAnnotation];
        }
    }
    else if ([connection typeOfConnection] == DIRECTIONS_REQUEST ||
             [connection typeOfConnection] == KNOWN_WAYPOINT_REQUEST ||
             [connection typeOfConnection] == UNKNOWN_WAYPOINT_REQUEST ||
             [connection typeOfConnection] == SCRAPE_WAYPOINT_REQUEST)
    {
        NSArray *routes = [results objectForKey:@"routes"];
        NSArray *legs = [[routes objectAtIndex:0] objectForKey:@"legs"];
        
        for (int i = 0; i < [legs count]; i++)
        {
            NSArray* steps = [[legs objectAtIndex:i] objectForKey:@"steps"];
            for (NSDictionary *cStep in steps)
            {
                if (!polyLines) { polyLines = [[NSMutableArray alloc] init]; }
                [polyLines addObject:[self polylineWithEncodedString:[[cStep objectForKey:@"polyline"] objectForKey:@"points"] ofType: [connection typeOfConnection]]];
            }
        }
        if(!firstAnimation){ [map addOverlays:polyLines]; }
    }
}
//Method: polyLineWithEncodedString
//Purpose: code to parse Google Encoded polylines
- (MyRouteOverlay *)polylineWithEncodedString:(NSString *)encodedString  ofType: (int)connectionType {
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    //Polyline display settings
    MyRouteOverlay *polyline = [[MyRouteOverlay alloc]initWithPolylineWithCoordinates:coords count:coordIdx];
    [polyline setLineWidth:3.0];
    switch (connectionType) {
        case DIRECTIONS_REQUEST:
            [polyline setRouteType:MAIN_ROUTE];
            break;
        case KNOWN_WAYPOINT_REQUEST:
            [polyline setRouteType:SAFE_ROUTE];
            break;
        case UNKNOWN_WAYPOINT_REQUEST:
            [polyline setRouteType:UNKNOWN_ROUTE];
            break;
        default:
            [polyline setRouteType:SCRAPE_ROUTE];
            break;
    }
    free(coords);
    
    return polyline;
}

#pragma mark MKMapView methods

//Method: mapView
//Purpose: We Set Up the Preferences for Our Annotation gets called by MKMapViewDelegate
- (MKAnnotationView *) mapView:(MKMapView *)aMapView viewForAnnotation:(id) annotation
{
    if ([annotation isKindOfClass:[MyAnnotationController class]])
    {
       //  MyAnnotationController *temp;
       //  temp = annotation;
       //  temp.transform = CGAffineTransformInvert(aMapView.transform);
        
        MKPinAnnotationView *annView = (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:@"locations"];
        
        if (!annView){
            annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"locations"];
        }
        
        if ([annotation detailDisclosure])
        {
            if (!button){
                button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                button.frame = CGRectMake(0, 0, 23, 23);
            }
            annView.rightCalloutAccessoryView = button;
        }
        
        annView.image = [annotation colorValue];
        annView.canShowCallout=YES;
        annView.calloutOffset=CGPointMake(-8, 5);
        return annView;
    }
    //nil makes sure that the user gets that blue dot with the pulsing
    return nil;
}
//Method: mapView didAddAnnotationView
//Purpose: Now that we're using custom annotations, we need to annimate our own drop
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)theViews {
    for (MKAnnotationView * aV in theViews) {
        // Don't pin drop if annotation is user location
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        
        // Check if current annotation is inside visible map rect
        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(self->map.visibleMapRect, point)) {
            continue;
        }
        
        CGRect endFrame = aV.frame;
        
        // Move annotation out of view
        aV.frame = CGRectMake(aV.frame.origin.x,
                              aV.frame.origin.y - self.view.frame.size.height,
                              aV.frame.size.width,
                              aV.frame.size.height);
        
        // Animate drop
        [UIView animateWithDuration:0.65
                              delay:0.04*[theViews indexOfObject:aV]
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             aV.frame = endFrame;
                             
                             // Animate squash
                         }completion:^(BOOL finished){
                             if (finished) {
                                 [UIView animateWithDuration:0.05 animations:^{
                                     aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
                                     
                                 }completion:^(BOOL finished){
                                     if (finished) {
                                         [UIView animateWithDuration:0.1 animations:^{
                                             aV.transform = CGAffineTransformIdentity;
                                         }];
                                         
                                     }
                                     //Ensure the Route Loads When The Pin Hits the Ground initially
                                     if ([aV.annotation isKindOfClass:[MyAnnotationController class]])
                                     {
                                         MyAnnotationController *temp = (MyAnnotationController *)aV.annotation;
                                         if ([[temp title] isEqualToString:@"Start"] && firstAnimation)
                                         {
                                            [map addOverlays:polyLines];
                                            firstAnimation = NO;
                                         }
                                     }
                                 }];
                             }
                         }];
    }
}
//Method: mapView viewOverlay
//Purpose: It's going to draw our route gets called by MKMapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay {
    if ([overlay isKindOfClass:[MyRouteOverlay class]])
    {
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        polylineView.strokeColor = [overlay getStrokeColor];
        polylineView.lineWidth = [overlay getLineWidth];
        return polylineView;
    }
    return nil;
}
//Method: mapView didSelectAnnotationView
//Purpose: the logic that happens when we click on the annotation gets called by MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *) annotationView
{
    // [mapView setTransform:CGAffineTransformMakeRotation(.2)];
    // [mapView setNeedsDisplayInRect: CGRectMake(0,0,150,150)];
    if ([annotationView.annotation isKindOfClass:[MyAnnotationController class]])
    {
        MyAnnotationController *tempAnn = annotationView.annotation;
        Location *ann =  [tempAnn loc];
        if ([ann isOnRoute] || [ann isStartPoint] || [ann isEndPoint]){
            annotationView.rightCalloutAccessoryView = nil;
        }
        else{ annotationView.rightCalloutAccessoryView = button; }
        
        //If it's not a PIN that's in our Main Route
        if (![routeLocations isOnRoute:ann])
        {
            NSMutableArray *temp = [routeLocations onRoute];
            [temp addObject:ann];
            
            [mapView removeOverlays:polyLines];
            [polyLines removeAllObjects];
            
            //It will never be green per our outer-check above
            switch ([tempAnn type]) {
                case PURPLE:
                    [hireling searchForDirectionsGivenStartPoint:[routeLocations startPoint] andEndPoint:[routeLocations endPoint] withWayPoints:temp shouldSearchOptimally:YES shouldUtilizeSensor:NO andConnnectionType:KNOWN_WAYPOINT_REQUEST setDelegate:self forLocation:ann];
                    break;
                case ORANGE:
                    [hireling searchForDirectionsGivenStartPoint:[routeLocations startPoint] andEndPoint:[routeLocations endPoint] withWayPoints:temp shouldSearchOptimally:YES shouldUtilizeSensor:NO andConnnectionType:UNKNOWN_WAYPOINT_REQUEST setDelegate:self forLocation:ann];
                    break;
                default:
                    [hireling searchForDirectionsGivenStartPoint:[routeLocations startPoint] andEndPoint:[routeLocations endPoint] withWayPoints:temp shouldSearchOptimally:YES shouldUtilizeSensor:NO andConnnectionType:SCRAPE_WAYPOINT_REQUEST setDelegate:self forLocation:ann];
                    break;
            }
            [temp removeLastObject];
        }
    }
}
//Method: mapView didSelectAnnotationView
//Purpose: releases the collected polylines that we've been keeping track of, we clear the polylines since
//          we no longer need them since they have been cleared, and we re-draw the original route
- (void)mapView:(MKMapView *)mapViewPassed didDeselectAnnotationView:(MKAnnotationView *)view{
    if ([view.annotation isKindOfClass:[MyAnnotationController class]])
    {
        MyAnnotationController *ann = view.annotation;
        //If the pin we deselected wasn't actually in our main route
        if ([[ann loc] isWayPoint]){
            
            [mapViewPassed removeOverlays:polyLines];
            [polyLines removeAllObjects];
            
            [hireling searchForDirectionsGivenStartPoint:[routeLocations startPoint] andEndPoint:[routeLocations endPoint] withWayPoints:[routeLocations onRoute] shouldSearchOptimally:YES shouldUtilizeSensor:NO andConnnectionType:DIRECTIONS_REQUEST setDelegate: self forLocation:[ann loc]];
        }
    }
}
//Method: mapView annotationView calloutAccessoryControlTapped
//Purpose: adds the route to our main route permanently when user hits details button and gets response
- (void)mapView:(MKMapView *)mapViewPassed annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    //Send Request and if user accepts do the following
    //Turn the Pin Green add Person to Safe List
    if ([view.annotation isKindOfClass:[MyAnnotationController class]]){
        view.rightCalloutAccessoryView = nil;
        [mapViewPassed removeOverlays:polyLines];
        MyAnnotationController *ann = view.annotation;
        Location* loc = [ann loc];
        
        [loc setIsOnRoute:YES];
        [loc setIsWayPoint:NO];
        
        [mapViewPassed removeOverlays:polyLines];
        [polyLines removeAllObjects];
        
        [hireling searchForDirectionsGivenStartPoint:[routeLocations startPoint] andEndPoint:[routeLocations endPoint] withWayPoints:[routeLocations onRoute] shouldSearchOptimally:YES shouldUtilizeSensor:NO andConnnectionType:DIRECTIONS_REQUEST setDelegate:self forLocation:loc];
    }
}

#pragma mark - CLLocationManagerDelegate
/**
 Conditionally enable the Search/Add buttons:
 If the location manager is generating updates, then enable the buttons;
 If the location manager is failing, then disable the buttons.
 */
- (void)updateLocations {
    //We need to be sure we're synced with the database data
    NSMutableArray* array = [routeLocations validLocations];
    [array removeAllObjects]; //Needs to be two lines so the ARC picks it up
    
    for (id ann in [map annotations])
    {
        if ([ann isKindOfClass:[MyAnnotationController class]])
        {
            MyAnnotationController *myAnn = ann;
            if (![routeLocations isOnRoute:[myAnn loc]]) {[map removeAnnotation:ann];}
        }
    }
    
    //Size of Query Radius in Kilometers
    CGFloat kilometers = 100;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Riders"];
    [query setLimit:1000];
    [query whereKey:@"geoPoint"
       nearGeoPoint:[PFGeoPoint geoPointWithLatitude:[routeLocations locationManager].location.coordinate.latitude
                                           longitude:[routeLocations locationManager].location.coordinate.longitude]
   withinKilometers:kilometers];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                PFObject* curLoc = [routeLocations currentLocation];
                if (![[object objectId] isEqualToString:[curLoc objectId]]){
                    //Add object to Valid Locations
                    PFGeoPoint* point = [object objectForKey:@"geoPoint"];
                    NSString* header = [object objectForKey:@"header"];
                    NSNumber * num = [object objectForKey:@"locationType"];
                    pair p = [SwissKnife unCantor:[num integerValue]];
                    
                    Location *aLoc = [[Location alloc] initWithAddress:header];
                    [aLoc setLocationType:p.x];
                    [aLoc setLocationGridType:p.y];
                    [aLoc setHeader:header];
                    [aLoc setGeoPoint:point];
                    
                    [routeLocations addLocation:aLoc];
                    //NSLog(@"Added %@ (%f, %f) %d, %d", header, [point latitude], [point longitude], p.x, p.y);
                    //NSLog(@"Array Size Now %d", [[routeLocations validLocations] count]);
                    
                    //Create the location
                    CLLocationCoordinate2D coord;
                    coord.latitude = [point latitude];
                    coord.longitude = [point longitude];
                    
                    MyAnnotationController *anAnnotation = [[MyAnnotationController alloc] initWithCoordinate:coord];
                    [anAnnotation setTitle:[aLoc header]];
                    [anAnnotation setSubTitle:@"Address Here"];
                    //Decide Color
                    if ([aLoc locationType] == LOCATION_REQUEST)
                    {
                        [anAnnotation setColorValue:PURPLE];
                    }
                    else if ([aLoc locationType] == UNKNOWN_REQUEST)
                    {
                        [anAnnotation setColorValue:ORANGE];
                    }
                    else {
                        [anAnnotation setColorValue:GREY];
                    }
                    [anAnnotation shouldHaveDetailDisclosure:YES];
                    [anAnnotation setLoc:aLoc];
                    [map addAnnotation:anAnnotation];
                    
                }
            }
        }
    }];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //Update Location in Database
    NSLog(@"Updated Location From: %@ To: %@", oldLocation, newLocation);
    [routeLocations insertCurrentLocation];
    [self updateLocations];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed with Error %@", [error localizedDescription]);
}

@end
