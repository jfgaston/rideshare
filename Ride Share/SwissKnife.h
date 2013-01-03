//
//  SwissKnife.h
//  Ride Share
//
//  Created by Luis Valencia on 9/6/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//
//  Purpose: This Class is a "Swiss Army Knife" a Tool to just perform or facilitate tasks

#import <Foundation/Foundation.h>
#import "Location.h"
#import "MyURLConnection.h"
#import <CoreLocation/CoreLocation.h>

typedef enum riderTypes
{
    DRIVER = 0,
    PASSENGER
} riderTypes;

typedef struct{
    int x;
    int y;
} pair;

@interface SwissKnife : NSObject
+ (NSString *) timeInSecondsToHumanReadable: (NSTimeInterval) diff;
+ (NSString *) timeInSecondsToHumanReadable: (NSTimeInterval) diff allowNegativeTime:(BOOL) neg;
+ (BOOL) isThisStringAValidLocation: (NSString *) loc;
+ (NSDictionary *) handleSegmentedJsonResponse: (MyURLConnection *) connection forSegmentedResponse: (NSString *) jsonString;
+ (CGFloat)directMetersFromCoordinate:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to;
+ (int) cantor: (int) x1 with: (int) x2;
+ (pair) unCantor:(int) z;
+ (NSString *)getIPAddress;
@end
