//
//  MyAnnotationController.m
//  Ride Share
//
//  Created by Luis Valencia on 8/1/12.
//  Copyright 2012 California State Polytechnic University of Pomona. All rights reserved.
//

#import "MyAnnotationController.h"

@implementation MyAnnotationController

@synthesize coordinate;
@synthesize loc;

- (NSString *)subtitle{
   if (!mSubTitle){ return @"Subtitle";} 
   return mSubTitle;
}

- (NSString *)title{
   if (!mTitle){ return @"Title"; }
   return mTitle;
}
- (UIImage *) colorValue {
   switch (colorValue) {
      case GREEN:
           return [UIImage imageNamed:@"pinGreen.png"];
      case PURPLE:
           return [UIImage imageNamed:@"pinPurple.png"];
      case ORANGE:
           return [UIImage imageNamed:@"pinOrange.png"];
      default:
           return [UIImage imageNamed:@"pinGrey.png"];
         
   }
}
- (int) type { return colorValue; }
-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
   coordinate=c;
   colorValue = 0;
    detailDisclosure = NO;
   return self;
}
- (void) setTitle: (NSString *) nTitle
{
   mTitle = nTitle;
}
- (void) setSubTitle: (NSString *) nSubTitle
{
   mSubTitle = nSubTitle;
}
- (void) shouldHaveDetailDisclosure: (BOOL) detail
{
    detailDisclosure = detail;
}
//Method: setColor Value
//Purpose: set an identifier to set the color value 1 = green, 2 = purple, 3 = red
- (void) setColorValue: (int) value
{
   colorValue = value;
}
- (BOOL) detailDisclosure{ return detailDisclosure; }
@end
