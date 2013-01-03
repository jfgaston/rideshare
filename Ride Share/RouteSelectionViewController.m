//
//  RouteSelectionViewController.m
//  Ride Share
//
//  Created by Luis Valencia on 9/5/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import "RouteSelectionViewController.h"
#import "TDSemiModal.h"
#import "SwissKnife.h"

#define xPos 20
#define yPos 240
#define imageWidth 280
#define imageHeight 156

@interface RouteSelectionViewController ()

- (IBAction)timeButtonClicked:(id)sender;
//Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@implementation RouteSelectionViewController

@synthesize routeSelectionBanner;
@synthesize when, from, to;
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ofKind: (int) type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        routeSelectionBanner = [[UILabel alloc] init];
        riderType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    switch (riderType) {
        case DRIVER:
            [routeSelectionBanner setText:@"Driver Route Selection"];
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, yPos, imageWidth, imageHeight)];
            imageView.image = [UIImage imageNamed:@"CAR.png"];
            break;
        case PASSENGER:
            [routeSelectionBanner setText:@"Passenger Route Selection"];
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, yPos, imageWidth, imageHeight)];
            imageView.image  = [UIImage imageNamed:@"PEOPLE.png"];
            break;
        default:
            [routeSelectionBanner setText:@"Misc Route Selection"];
            break;
    }
    [self.view addSubview:imageView];
    [routeSelectionBanner setTextAlignment:UITextAlignmentCenter];
    
    [when setDelegate:self];
    [from setDelegate:self];
    [to setDelegate:self];
    
    [when setText:@"Now"];
    [from setText:@"My Location"];
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
//Method: startLocation
//Purpose: Returns the String Value of the Departing Location
- (NSString *) startLocation{ return [from text]; }
//Method: endLocation
//Purpose: Returns the String Value of the Destination Location
- (NSString *) endLocation{ return [to text]; }
//Method: timeButtonClicked
//Purpose: Handles the Logic Behind Bringing up the SemiModalView
- (IBAction)timeButtonClicked:(id)sender
{
    [self.view endEditing:YES];

    if (!datePickerView){
        datePickerView = [[MyDatePickerViewController alloc] initWithNibName:@"TDDatePickerController" bundle:nil withLabel:when];
        [datePickerView setAsTimeDatePicker];
        datePickerView.delegate = datePickerView;
    }
    [self presentSemiModalViewController:datePickerView];
}
//Method: saveData
//Purpose: If the Input Provided Will Yield Valid Locations then Add the Data
- (BOOL) saveData{
    if ([SwissKnife isThisStringAValidLocation:[from text]]){
        [autoCompleteView saveStartPoint:[from text]];
    }
    if ([SwissKnife isThisStringAValidLocation:[to text]]){
        [autoCompleteView saveEndPoint:[to text]];
    }
    return [SwissKnife isThisStringAValidLocation:[from text]] && [SwissKnife isThisStringAValidLocation:[to text]];
}
#pragma mark UIViewDelegate Methods
//Method: touchesBegan withEvent
//Purpose: Dismisses the Keyboard on Tapping outside the Keyboard | Called by the UIViewDelegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark UITextFieldDelegate Methods
//Method: textFieldDidBeginEditing textField
//Purpose: Handles that should be taken when we click it, for now jsut hihglight Text
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField selectAll:nil];
}
//Method: textFieldDidEndEditing textField
//Purpose: Makes sure that when we are done editing the table view hides
- (void) textFieldDidEndEditing:(UITextField *)textField{
    if (autoCompleteView.autocompleteTableView)
    {
        [autoCompleteView.autocompleteTableView removeFromSuperview];
    }
}
//Method: textField shouldChangeCharactersInRange
//Purpose: gets called by the UITextFieldDelegate for TableViewDisplay and autocompletion
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //Get Coordinates of Frame
    CGRect textFieldFrame = [textField frame];
    
    int y1 = textFieldFrame.origin.y+textFieldFrame.size.height;
    int x1 = textFieldFrame.origin.x;
    
    if (!autoCompleteView){
        autoCompleteView = [[AutoCompleteTableViewController alloc] initWithStyle:UITableViewStylePlain andView:[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain]];
        UITableView* autocompleteTableView = [autoCompleteView autocompleteTableView];
        [autocompleteTableView setDelegate:autoCompleteView];
        [autocompleteTableView setDataSource:autoCompleteView];
        autocompleteTableView.scrollEnabled = YES;
        autocompleteTableView.hidden = NO;
    }
    [autoCompleteView autocompleteTableView].frame = CGRectMake(x1, y1, textFieldFrame.size.width, 120);
    [autoCompleteView setSelectedTextField:textField];
    [autoCompleteView setUpPastValues];
    [self.view addSubview:[autoCompleteView autocompleteTableView]];
    
    NSString *substring = [[NSString alloc] initWithString:[NSString stringWithString: textField.text]];
    NSString *temp = [[NSString alloc] initWithString:[substring stringByReplacingCharactersInRange:range withString:string]];
    [autoCompleteView searchAutocompleteEntriesWithSubstring:temp];
    
    return YES;
}

@end
