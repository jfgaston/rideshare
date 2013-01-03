//
//  MyURLConnection.h
//  Ride Share
//
//  Created by Luis Valencia on 8/15/12.
//
//

#import <Foundation/Foundation.h>
#import "Location.h"

typedef enum ConnectionTypes
{
    LOCATION_REQUEST = 0,
    UNKNOWN_REQUEST,
    SCRAPE_REQUEST,
    DIRECTIONS_REQUEST,
    KNOWN_WAYPOINT_REQUEST,
    UNKNOWN_WAYPOINT_REQUEST,
    SCRAPE_WAYPOINT_REQUEST,
    GRID_DIRECTIONS_REQUEST,
    GRID_KNOWN_WAYPOINT_REQUEST,
    GRID_UNKNOWN_WAYPOINT_REQUEST,
    GRID_SCRAPE_WAYPOINT_REQUEST
    
} ConnectionTypes;

@interface MyURLConnection : NSURLConnection {
    int taskNumber;
    int typeOfConnection;
    Location* locAffiliation;
}

@property (atomic, assign) int taskNumber;
@property (atomic, assign) int typeOfConnection;
@property (atomic, retain) Location* locAffiliation;
@property (atomic, assign) BOOL isPartOfRoute;

- (id) initWithRequest:(NSURLRequest *)request delegate:(id)delegate andWeight: (int) q andConnectionType: (int) t andLocationAffiliation: (Location *) address;
-(int) uniqueIdentifier;
@end
