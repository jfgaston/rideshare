//
//  MyDatePickerViewController.h
//  Ride Share
//
//  Created by Luis Valencia on 9/6/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import "TDDatePickerController.h"

@interface MyDatePickerViewController : TDDatePickerController
{
    UITextField *when;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withLabel: (UITextField *)label;
- (void) setAsTimeDatePicker;

@end
