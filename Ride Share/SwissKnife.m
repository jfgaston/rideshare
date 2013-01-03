//
//  SwissKnife.m
//  Ride Share
//
//  Created by Luis Valencia on 9/6/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import "SwissKnife.h"
#import "SBJson.h"
#import "Math.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation SwissKnife

static NSMutableDictionary* segmentedJSONStrings;

+ (NSDictionary *) handleSegmentedJsonResponse: (MyURLConnection *) connection forSegmentedResponse: (NSString *) jsonString
{
    if (!segmentedJSONStrings)
    {
        segmentedJSONStrings = [[NSMutableDictionary alloc] init];
    }
    
    //Deal with Segmented JSON Response
    NSDictionary *results;
    
    //If the Current Task isn't in our TaskList
    if (![segmentedJSONStrings objectForKey:[NSString stringWithFormat:@"%d",[connection uniqueIdentifier]]])
    {
        NSMutableString *segmentedJSON = [[NSMutableString alloc] initWithString:[[jsonString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "]];
        
        //If it's not well formed
        if (![segmentedJSON JSONValue])
        {
            [segmentedJSONStrings setObject:segmentedJSON forKey:[NSString stringWithFormat:@"%d",[connection uniqueIdentifier]]];
            return nil;
        }
        //If it is well formed
        else
        {
            results = [[NSDictionary alloc] initWithDictionary:[segmentedJSON JSONValue]];
        }
    }
    //If we have seen this taks before
    else
    {
        NSMutableString *segmentedJSON = [segmentedJSONStrings objectForKey:[NSString stringWithFormat:@"%d",[connection uniqueIdentifier]]];
        [segmentedJSON appendString:[[jsonString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "]];
        //If it's not Well Formed
        if (![segmentedJSON JSONValue])
        {
            [segmentedJSONStrings removeObjectForKey:[NSString stringWithFormat:@"%d",[connection uniqueIdentifier]]];
            [segmentedJSONStrings setObject:segmentedJSON forKey:[NSString stringWithFormat:@"%d",[connection uniqueIdentifier]]];
            return nil;
        }
        //If it is Well Formed
        else
        {
            results = [[NSDictionary alloc] initWithDictionary:[segmentedJSON JSONValue]];
            [segmentedJSONStrings removeObjectForKey:[NSString stringWithFormat:@"%d",[connection uniqueIdentifier]]];
        }
    }
    return results;
}
//Method: isThisStringAValidLocation
//Purpose: Method will Validate that the String Given Yields a Valid GeoLocation
+ (BOOL) isThisStringAValidLocation: (NSString *) loc
{
    return YES;
}
//Method: timeInSecondsToHumanReadable
//Purpose: given an NSDate
+ (NSString *) timeInSecondsToHumanReadable: (NSTimeInterval) diff{
    return [self timeInSecondsToHumanReadable:diff allowNegativeTime:NO];
}
+ (NSString *) timeInSecondsToHumanReadable: (NSTimeInterval) diff allowNegativeTime:(BOOL) neg{
    BOOL displayNegative = NO;
    //If they're going behind then clearly it's for the next day so then add 24 hrs in seconds
    if (diff < 0 && !neg){
        diff += 86400;
    }
    else if (diff < 0 && neg)
    {
        displayNegative = YES;
        diff *= -1;
    }
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:diff sinceDate:date1];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];

    //Our Components because of the limitations of the date picker will never be greater than a Day.
    NSMutableString *timeDiff = [[NSMutableString alloc] init];
    NSString* annotation = @"";
    if (displayNegative) { annotation = @"- "; }
    BOOL noHours = NO;
    switch ([conversionInfo hour]) {
        case 0: noHours = YES; break;
        case 1:
            [timeDiff appendFormat:@"%@1 hr ", annotation];
            break;
        default:
            [timeDiff appendFormat:@"%@%d hrs ", annotation, [conversionInfo hour]];
            break;
    }
    NSString *minutesAnnotation = @"";
    if (noHours && displayNegative) { minutesAnnotation=@"- "; }
    [timeDiff appendFormat:@"%@%d min", minutesAnnotation, [conversionInfo minute]];
    
    return timeDiff;
}
//Method: directMetersFromCoordinate toCoordinate
//Purpose: Haversine Formula for Distance Between two Points
+ (CGFloat)directMetersFromCoordinate:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to {
    
    static const double DEG_TO_RAD = 0.017453292519943295769236907684886;
    static const double EARTH_RADIUS_IN_METERS = 6372797.560856;
    
    double latitudeArc  = (from.latitude - to.latitude) * DEG_TO_RAD;
    double longitudeArc = (from.longitude - to.longitude) * DEG_TO_RAD;
    double latitudeH = sin(latitudeArc * 0.5);
    latitudeH *= latitudeH;
    double lontitudeH = sin(longitudeArc * 0.5);
    lontitudeH *= lontitudeH;
    double tmp = cos(from.latitude*DEG_TO_RAD) * cos(to.latitude*DEG_TO_RAD);
    return EARTH_RADIUS_IN_METERS * 2.0 * asin(sqrt(latitudeH + tmp*lontitudeH));
}
//Method: cantor
//Purpose: Cantor Pairing Function
+ (int) cantor:(int)x with:(int)y{
    return (int)((x+y)*(x+y+1))/2+y;
}
//Method: unCantor
//Purpose:  Uncatonring a number into a Pair
+ (pair) unCantor:(int) z{
    int wz=[self w: z];
    int y= z - [self t: wz];
    pair p;
    p.x = wz-y;
    p.y = y;
    return p;
}
//UnCantoring Helper Functions
+ (int) w: (int) z{
    return floor((sqrt(8*z+1))-1)/2;
}
+ (int) t: (int) w{
    return (w*w+w)/2;
}
//Optaining the Phone's IP address
+ (NSString *)getIPAddress
{
     struct ifaddrs *interfaces = NULL;
     struct ifaddrs *temp_addr = NULL;
     NSString *wifiAddress = nil;
     NSString *cellAddress = nil;
     
     // retrieve the current interfaces - returns 0 on success
     if(!getifaddrs(&interfaces)) {
     // Loop through linked list of interfaces
     temp_addr = interfaces;
     while(temp_addr != NULL) {
     sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
     if(sa_type == AF_INET || sa_type == AF_INET6) {
     NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
     NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
     NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself
     
     if([name isEqualToString:@"en0"]) {
     // Interface is the wifi connection on the iPhone
     wifiAddress = addr;
     } else
     if([name isEqualToString:@"pdp_ip0"]) {
     // Interface is the cell connection on the iPhone
     cellAddress = addr;
     }
     }
     temp_addr = temp_addr->ifa_next;
     }
     // Free memory
     freeifaddrs(interfaces);
     }
     NSString *addr = wifiAddress ? wifiAddress : cellAddress;
     return addr ? addr : @"0.0.0.0";
}
@end
