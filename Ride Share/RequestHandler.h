//
//  RequestHandler.h
//  Ride Share
//
//  Created by Luis Valencia on 9/10/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface RequestHandler : NSObject
{
    NSUInteger requestNumber;
    NSUInteger queriesToProcess;
    NSMutableArray *objectResponse;
    id target;
}

@property (nonatomic, retain) NSMutableArray *objectResponse;
@property (atomic, assign) NSUInteger queriesToProcess;
@property (nonatomic, retain) id target;

- (RequestHandler *) init;
- (void) searchCoordinatesForLocation:(Location *)inAddress setDelegate: (id) delegateObject;
- (void) searchCoordinatesForLocation:(Location *)loc ofType: (int)connectionType setDelegate:(id) delegateObject;
- (void) searchForDirectionsGivenStartPoint: (Location *) startPoint andEndPoint: (Location *) endPoint withWayPoints: (NSArray *) wayPoints shouldSearchOptimally: (BOOL) optimize shouldUtilizeSensor: (BOOL) sensor andConnnectionType: (int) type setDelegate:(id) delegateObject forLocation: (Location *) loc;
- (void) clearHandledRequests;

@end
