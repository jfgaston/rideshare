//
//  MyRouteOverlay.m
//  Ride Share
//
//  Created by Luis Valencia on 8/20/12.
//
//

#import "MyRouteOverlay.h"

@implementation MyRouteOverlay

@synthesize polyline;

- (MyRouteOverlay *) initWithPolylineWithCoordinates:(CLLocationCoordinate2D *) coords count: (int)coordIdx
{
    self = [super init];
    if (self)
    {
        polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
    }
    return self;
}

#pragma mark MKOverlay
//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (CLLocationCoordinate2D) coordinate {
    return [polyline coordinate];
}

//@property (nonatomic, readonly) MKMapRect boundingMapRect;
- (MKMapRect) boundingMapRect {
    return [polyline boundingMapRect];
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [polyline intersectsMapRect:mapRect];
}
- (void) setRouteType: (int) routeType{
    switch (routeType) {
        case MAIN_ROUTE:
            strokeColor = [UIColor greenColor];
            break;
        case SAFE_ROUTE:
            strokeColor = [UIColor blueColor];
            break;
        case UNKNOWN_ROUTE:
            strokeColor = [UIColor orangeColor];
            break;
        default:
            strokeColor = [UIColor grayColor];
            break;
    }
}
- (void) setLineWidth: (CGFloat) width { lineWidth = width; }
- (MKMapPoint *) points{ return [polyline points]; }
- (NSUInteger) pointCount{ return [polyline pointCount]; }
- (UIColor *) getStrokeColor{ return strokeColor; }
- (CGFloat) getLineWidth{ return lineWidth; }
@end
