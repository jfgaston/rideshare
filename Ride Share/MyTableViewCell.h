//
//  MyTableViewCell.h
//  Ride Share
//
//  Created by Luis Valencia on 8/23/12.
//
//

#import <UIKit/UIKit.h>
#import "Location.h"

typedef enum CellColorCoding
{
    GREEN_CELL = 1,
    BLUE_CELL,
    ORANGE_CELL,
    GREY_CELL
} CellColorCoding ;

@interface MyTableViewCell : UITableViewCell{
    int cellColoration;
    int mapRequestEquivalent;
    UIImage *displayImage;
    NSTimeInterval timeAdded;
    Location *location;
}

@property (nonatomic, retain) UIImage *displayImage;
@property (nonatomic, retain) Location *location;
@property (atomic, assign) int mapRequestEquivalent;
@property (atomic, assign) NSTimeInterval timeAdded;

- (void) setType: (int) type;
- (void) setDisplayImage:(UIImage *)someImage;
- (UIImage *) getDisplayImage;
- (UIImage *) colorCoding;
- (BOOL) isPartOfRoute;
- (void) setTimeAddedByTakingMe: (NSInteger) added;
- (NSString *) timeAddedByTakingMe;
- (NSUInteger) eta;
@end
