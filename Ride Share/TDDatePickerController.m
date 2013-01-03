//
//  TDDatePickerController.m
//
//  Created by Nathan Reed on 30/09/10.
//  Copyright 2010 Nathan Reed. All rights reserved.
//

#import "TDDatePickerController.h"


@implementation TDDatePickerController

typedef enum PickerTypeValues
{
    TIME=1,
    DATE,
    COUNTDOWN,
    DATEANDTIME
} pickerTypes;

@synthesize datePicker, delegate;

-(void)viewDidLoad {
    [super viewDidLoad];
   switch (viewType) {
      case TIME:
         datePicker.datePickerMode = UIDatePickerModeTime;
         break;
      case DATEANDTIME:
         datePicker.datePickerMode = UIDatePickerModeDateAndTime;
         break;
      case COUNTDOWN:
         datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
      default:
         datePicker.datePickerMode = UIDatePickerModeDate;
         break;
   };
	datePicker.date = [NSDate date];

	// we need to set the subview dimensions or it will not always render correctly
	// http://stackoverflow.com/questions/1088163
	for (UIView* subview in datePicker.subviews) {
		subview.frame = datePicker.bounds;
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark Actions

-(IBAction)saveDateEdit:(id)sender {
	if([self.delegate respondsToSelector:@selector(datePickerSetDate:)]) {
		[self.delegate datePickerSetDate:self];
	}
}

-(IBAction)clearDateEdit:(id)sender {
	if([self.delegate respondsToSelector:@selector(datePickerClearDate:)]) {
		[self.delegate datePickerClearDate:self];
	}
}

-(IBAction)cancelDateEdit:(id)sender {
	if([self.delegate respondsToSelector:@selector(datePickerCancel:)]) {
		[self.delegate datePickerCancel:self];
	} else {
		// just dismiss the view automatically?
	}
}
//Method:touchesBegan withEvent
//Purpose: Resign the View when we Touch outside of it 
//         able to do this because TDDatePickerController derives from TDSemiModalViewController
//         TDSemiModalViewController is a UIViewController
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
   if([self.delegate respondsToSelector:@selector(datePickerCancel:)]){
      [self.delegate datePickerCancel:self];
   }
}
//Method: datePicker Type
//Purpose: Depending on input can be time, date, time and date
- (void)datePickerType: (int) type
{
   viewType = type;
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];

	self.datePicker = nil;
	self.delegate = nil;

}



@end


