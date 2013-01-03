//
//  MyAnnotationController.h
//  Ride Share
//
//  Created by Luis Valencia on 8/1/12.
//  Copyright 2012 California State Polytechnic University of Pomona. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Location.h"

typedef enum ColorValues
{
   GREEN = 1,
   PURPLE,
   ORANGE,
   GREY
} PinColors; 

@interface MyAnnotationController : NSObject<MKAnnotation> {
   CLLocationCoordinate2D coordinate;
   NSString *mTitle;
   NSString *mSubTitle;
   Location *loc;
   int colorValue;
   BOOL detailDisclosure;
}

@property (nonatomic, retain) Location *loc;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c;
- (void) setTitle: (NSString *) nTitle;
- (void) setSubTitle: (NSString *) nSubTitle;
- (void) setColorValue: (int) value;
- (void) shouldHaveDetailDisclosure: (BOOL) detail;
- (UIImage *) colorValue;
- (int) type;
- (BOOL) detailDisclosure;
@end
