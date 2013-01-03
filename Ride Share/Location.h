//
//  Location.h
//  Ride Share
//
//  Created by Luis Valencia on 9/6/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Location : NSObject 
{
    NSString* header;
    NSString* address;
    NSTimeInterval timeAdded;
    BOOL isWayPoint;
    BOOL isOnRoute;
    BOOL isStartPoint;
    BOOL isEndPoint; 
    int locationType;
    int locationGridType;
    PFGeoPoint *geoPoint;
}

@property (nonatomic, retain) NSString* address, *header;
@property (nonatomic, retain) PFGeoPoint *geoPoint;
@property (atomic, assign) NSTimeInterval timeAdded;
@property (atomic, assign) BOOL isWayPoint, isOnRoute, isStartPoint, isEndPoint;
@property (atomic, assign) int locationType, locationGridType;

- (Location *) initWithAddress: (NSString *) loc;
- (Location *) initWithAddress: (NSString *) loc isStart: (BOOL) start;
- (Location *) initWithAddress: (NSString *) loc isEnd: (BOOL) End;
- (Location *) initWithGeoPointWithLatitude: (double) lat longitude: (double) lng;

@end
