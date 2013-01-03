//
//  Location.m
//  Ride Share
//
//  Created by Luis Valencia on 9/6/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import "Location.h"

@implementation Location

@synthesize address, header;
@synthesize geoPoint;
@synthesize timeAdded;
@synthesize isOnRoute, isWayPoint, isStartPoint, isEndPoint;
@synthesize locationType, locationGridType;

- (Location *) initWithAddress: (NSString *) loc;
{
    return [self initWithAddress:loc isStart:NO isEnd:NO];
}
- (Location *) initWithAddress: (NSString *) loc isStart: (BOOL) start{
    return [self initWithAddress:loc isStart:start isEnd: NO];
}
- (Location *) initWithAddress: (NSString *) loc isEnd: (BOOL) end{
    return [self initWithAddress:loc isStart:NO isEnd:end];
}
- (Location *) initWithAddress: (NSString *) loc isStart: (BOOL) start isEnd: (BOOL) end{
    self = [super init];
    if (self)
    {
        address = [[NSString alloc] initWithString:loc];
        if (start || end) {
            timeAdded = 0;
            if(start) { isStartPoint = YES; isEndPoint = NO; }
            else { isStartPoint = NO; isEndPoint = YES; }
            isWayPoint = NO;
            isOnRoute = NO;
        }
        else{
            isStartPoint = NO;
            isEndPoint = NO;
            isWayPoint = YES;
            isOnRoute = NO;
        }
        //Maybe Do Some GeoLocation Stuff to Fill in The other Stuff
    }
    return self;
}
- (Location *) initWithGeoPointWithLatitude: (double) lat longitude: (double) lng
{
    self = [super init];
    if (self)
    {
        geoPoint = [PFGeoPoint geoPointWithLatitude:lat longitude:lng];
    }
    return self;
}

@end
