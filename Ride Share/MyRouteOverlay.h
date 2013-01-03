//
//  MyRouteOverlay.h
//  Ride Share
//
//  Created by Luis Valencia on 8/20/12.
//
//

#import <MapKit/MapKit.h>

typedef enum RouteType{
    MAIN_ROUTE,
    SAFE_ROUTE,
    UNKNOWN_ROUTE,
    SCRAPE_ROUTE
} RouteType;

@interface MyRouteOverlay : NSObject <MKOverlay>
{
    MKPolyline* polyline;
    UIColor* strokeColor;
    CGFloat lineWidth;
}

@property (nonatomic, retain) MKPolyline* polyline;

- (MyRouteOverlay *) initWithPolylineWithCoordinates:(CLLocationCoordinate2D *) coords count: (int)coordIdx;
- (void) setRouteType: (int) routeType;
- (void) setLineWidth: (CGFloat) width;
- (UIColor *) getStrokeColor;
- (CGFloat) getLineWidth;
- (MKMapPoint *) points;
- (NSUInteger) pointCount;

@end
