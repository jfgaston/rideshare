//
//  RouteSelectionViewController.h
//  Ride Share
//
//  Created by Luis Valencia on 9/5/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDatePickerViewController.h"
#import "AutoCompleteTableViewController.h"

@interface RouteSelectionViewController : UIViewController <UITextFieldDelegate>
{
    UILabel *routeSelectionBanner;
    int riderType;
    UITextField *when, *from, *to;
    UIImageView *imageView;
    @private
    MyDatePickerViewController *datePickerView;
    AutoCompleteTableViewController *autoCompleteView;
}

@property (nonatomic, retain) IBOutlet UILabel *routeSelectionBanner;
@property (nonatomic, retain) IBOutlet UITextField *when, *from, *to;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ofKind: (int) type;
- (BOOL) saveData;
- (NSString *) startLocation;
- (NSString *) endLocation;

@end
