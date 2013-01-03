//
//  RequestHandler.m
//  Ride Share
//
//  Created by Luis Valencia on 9/10/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import "RequestHandler.h"
#import "MyURLConnection.h"
#import "SwissKnife.h"
#import "MyTableViewCell.h"
#import "GridViewController.h"

@implementation RequestHandler

@synthesize objectResponse;
@synthesize queriesToProcess;
@synthesize target;

- (RequestHandler *) init{
    self = [super init];
    if (self)
    {
        target = self;
        requestNumber = 0;
        objectResponse = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
- (void) selDefault: (id) sender
{
    NSLog(@"Warning: Never Assigned Selector");
}
- (void)connection:(MyURLConnection *)connection didReceiveData:(NSData *)data{
    //The string received from google's servers
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //Deal with Segmented JSON Response
    NSDictionary *results = [SwissKnife handleSegmentedJsonResponse:connection forSegmentedResponse:jsonString];
    if (!results) return;
    
    if ([connection typeOfConnection] == GRID_DIRECTIONS_REQUEST ||
        [connection typeOfConnection] == GRID_KNOWN_WAYPOINT_REQUEST ||
        [connection typeOfConnection] == GRID_UNKNOWN_WAYPOINT_REQUEST ||
        [connection typeOfConnection] == GRID_SCRAPE_WAYPOINT_REQUEST)
    {
        GridViewController *handle = (GridViewController *) target;
        NSArray *routes = [results objectForKey:@"routes"];
        NSArray *legs = [[routes objectAtIndex:0] objectForKey:@"legs"];
        NSUInteger total = 0;
        for (NSDictionary* current in legs)
        {
            NSString* duration = [[current objectForKey:@"duration"] objectForKey:@"value"];
            total += [duration integerValue];
        }
        if ([connection typeOfConnection] == GRID_DIRECTIONS_REQUEST) {
            [handle setTotalTime:total];
        }
        else
        {
            MyTableViewCell* cellObject = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
            [cellObject setLocation:[connection locAffiliation]];
            switch ([connection typeOfConnection]) {
                case GRID_KNOWN_WAYPOINT_REQUEST:
                    [cellObject setType:BLUE_CELL];
                    [cellObject setMapRequestEquivalent:LOCATION_REQUEST];
                    break;
                case GRID_UNKNOWN_WAYPOINT_REQUEST:
                    [cellObject setType:ORANGE_CELL];
                    [cellObject setMapRequestEquivalent:UNKNOWN_REQUEST];
                    break;
                default:
                    [cellObject setType:GREY_CELL];
                    [cellObject setMapRequestEquivalent:SCRAPE_REQUEST];
                    break;
            }
            [cellObject setTimeAddedByTakingMe:total-[handle runningTotal]];
            [objectResponse addObject:cellObject];
        }
    }
    queriesToProcess--;
}
- (void) clearHandledRequests{
    target = self;
    queriesToProcess = 0;
    [objectResponse removeAllObjects];
}
//Method: search CoordinatesForAddress
//Purpoose: Given an NSString it makes a Search Query to Google Maps
//Overload
- (void) searchCoordinatesForLocation:(Location *)inAddress setDelegate: (id) delegateObject
{ [self searchCoordinatesForLocation:inAddress ofType: LOCATION_REQUEST setDelegate:delegateObject]; }
- (void) searchCoordinatesForLocation:(Location *)loc ofType: (int)connectionType setDelegate:(id) delegateObject
{
    //Build the string to Query Google Maps.
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@?output=json", [loc address]];
        
    //Replace Spaces with appropirate space character.
    //[urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    [urlString setString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    
    //Setup and start an async download.
    //Note that we should test for reachability!.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    MyURLConnection *connection = [[MyURLConnection alloc] initWithRequest:request delegate:delegateObject andWeight: requestNumber++ andConnectionType:connectionType andLocationAffiliation:loc];
    [connection setTaskNumber:requestNumber];
}
//Method: searchForDirectionsGivenStartPoint andEndPoint withWayPoints shouldSearchOptimally shouldUtilizeSensor
//Purpose: Builds and performs the URL Request for the JSON Data for our WayPoints
- (void) searchForDirectionsGivenStartPoint: (Location *) startPoint andEndPoint: (Location *) endPoint withWayPoints: (NSArray *) wayPoints shouldSearchOptimally: (BOOL) optimize shouldUtilizeSensor: (BOOL) sensor andConnnectionType: (int) type setDelegate:(id) delegateObject forLocation: (Location *) loc
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@", [startPoint address], [endPoint address]];
    
    NSString* shouldUse;
    if (wayPoints && [wayPoints count] > 0)
    {
        (optimize)?(shouldUse=@"true"):(shouldUse=@"false");
        [urlString appendFormat:@"&waypoints=optimize:%@",shouldUse];
        for (Location *wayPoint in wayPoints)
        {
            NSString *address;
            PFGeoPoint *point = [wayPoint geoPoint];
            if (point){
                address = [NSString stringWithFormat:@"|%f,%f", [point latitude], [point longitude]];
            }
            else {
                address = [wayPoint address];
            }
            [urlString appendFormat:@"|%@", address];
        }
    }
    (sensor)?(shouldUse=@"true"):(shouldUse=@"false");
    [urlString appendFormat:@"&sensor=%@", shouldUse];
    [urlString setString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    //DEBUG OUTPUT
    //NSLog(@"%@", urlString);
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    
    //Setup and start an async download.
    //Note that we should test for reachability!.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    MyURLConnection *connection = [[MyURLConnection alloc] initWithRequest:request delegate:delegateObject andWeight: requestNumber++ andConnectionType:type andLocationAffiliation:loc];
    [connection setTaskNumber:requestNumber];
}

@end
