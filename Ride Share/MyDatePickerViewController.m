//
//  MyDatePickerViewController.m
//  Ride Share
//
//  Created by Luis Valencia on 9/6/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import "MyDatePickerViewController.h"
#import "SwissKnife.h"

@interface MyDatePickerViewController ()

typedef enum PickerTypeValues
{
    TIME=1,
    DATE,
    COUNTDOWN,
    DATEANDTIME
} pickerTypes;

// Delegate Methods
-(void)datePickerSetDate:(TDDatePickerController*)viewController;
-(void)datePickerClearDate:(TDDatePickerController*)viewController;
-(void)datePickerCancel:(TDDatePickerController*)viewController;
@end

@implementation MyDatePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withLabel: (UITextField *)label
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self->when = label;
    }
    return self;
}
- (void) setAsTimeDatePicker
{
    [self datePickerType:TIME];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark TDDatePickerDelegate Methods

//Method:datePickerSetDate
//Purpose: gets called by our TDDatePickerControllerDelegate
//         catches what happens on set Date
-(void)datePickerSetDate:(TDDatePickerController*)viewController
{
    [when setText:[SwissKnife timeInSecondsToHumanReadable:[viewController.datePicker.date timeIntervalSinceNow]]];
    //Dismiss "First Responder"
	[self dismissSemiModalViewController:self];
}
//Method: datePickerClearDate
//Purpose: gets called by our TDDatePickerControllerDelagate
//         catches what happens on Clear Date
-(void)datePickerClearDate:(TDDatePickerController*)viewController
{
    //Dismiss "First Responder"
	[self dismissSemiModalViewController:self];
    self.datePicker.date = [NSDate date];
}
//Method: datePickerCancel
//Purpsoe: gets calle dby our TDDatePickerControllerDelage
//         catches what happens on Cancel Date
-(void)datePickerCancel:(TDDatePickerController*)viewController;
{
    //Dismiss "First Responder"
	[self dismissSemiModalViewController:self];
}


@end
