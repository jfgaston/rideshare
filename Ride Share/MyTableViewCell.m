//
//  MyTableViewCell.m
//  Ride Share
//
//  Created by Luis Valencia on 8/23/12.
//
//

#import "MyTableViewCell.h"
#import "SwissKnife.h"


@implementation MyTableViewCell

@synthesize displayImage;
@synthesize location;
@synthesize mapRequestEquivalent;
@synthesize timeAdded;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellColoration  = GREEN_CELL;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void) setDisplayImage:(UIImage *)someImage
{
    self->displayImage = someImage;
}
- (UIImage *) getDisplayImage
{
    return displayImage;
    //return [UIImage imageNamed:@"displaySampleImage.png"];
   // return displayImage;
}
- (void) setType: (int) type
{
    cellColoration = type;
}
- (UIImage *) colorCoding
{
    switch (cellColoration) {
        case GREEN_CELL:
            if ([location isOnRoute]) return [UIImage imageNamed:@"minusGreen.png"];
            else return [UIImage imageNamed:@"plusGreen.png"];
        case BLUE_CELL:
            if ([location isOnRoute]) return [UIImage imageNamed:@"minusBlue.png"];
            else return [UIImage imageNamed:@"plusBlue.png"];
        case ORANGE_CELL:
            if ([location isOnRoute]) return [UIImage imageNamed:@"minusOrange.png"];
            else return [UIImage imageNamed:@"plusOrange.png"];
        default:
            if ([location isOnRoute]) return [UIImage imageNamed:@"minusGrey.png"];
            else return [UIImage imageNamed:@"plusGrey.png"]; 
            break;
    }
}
- (BOOL) isPartOfRoute{ return [location isOnRoute]; }
- (void) setTimeAddedByTakingMe: (NSInteger) added
{
    timeAdded = (NSTimeInterval) added;
}
- (NSUInteger) eta { return (NSUInteger) timeAdded; }
- (NSString *) timeAddedByTakingMe
{
    return [SwissKnife timeInSecondsToHumanReadable:timeAdded allowNegativeTime:YES];
}
//Method: handlePlusMinusTap
//Purpose: Handles the Action Taken When Trying to Add or Remove Someone from the Permanent Route
- (IBAction) handlePlusMinusTap: (id)sender
{
    self.selectionStyle = UITableViewCellSelectionStyleBlue; // See If I can Make Custom HighLight
    [self setHighlighted:YES animated:YES];
    [self setHighlighted:NO animated:YES];
    //Ensure Switch Click
    if ([self isPartOfRoute]){
        [location setIsOnRoute:NO];
        self.imageView.image = [self colorCoding];
    }
    else {
        [location setIsOnRoute:YES];
        self.imageView.image = [self colorCoding];
    }
    [self setNeedsDisplay];
}
- (NSComparisonResult)compare:(MyTableViewCell *)otherObject {
    if ((self->timeAdded - otherObject->timeAdded) == 0) return NSOrderedSame;
    else if ((self->timeAdded - otherObject->timeAdded) < 0) return NSOrderedAscending;
    else return NSOrderedDescending;
}

@end
