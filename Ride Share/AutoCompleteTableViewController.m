//
//  AutoCompleteTableViewController.m
//  Ride Share
//
//  Created by Luis Valencia on 9/6/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import "AutoCompleteTableViewController.h"

@interface AutoCompleteTableViewController ()

typedef enum TagEnumeration
{
    WHEN = 0,
    TO,
    FROM
} textFieldTagEnumeration;

@end

@implementation AutoCompleteTableViewController

@synthesize autocompleteTableView;
@synthesize selectedTextField;

- (id)initWithStyle:(UITableViewStyle)style andView: (UITableView *) view
{
    self = [super initWithStyle:style];
    if (self) {
        self->autocompleteTableView = view;
        startPoints = [[MyPlacesVisisted alloc] initWithDocPath:@"startPoints" andFileName:@"start.plist"];
        endPoints = [[MyPlacesVisisted alloc] initWithDocPath:@"endPoints" andFileName:@"end.plist"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//Method: saveStartPoint
//Purpose: adds new location and saves it to our startPoint
- (void) saveStartPoint:(NSString *) startPointAddress{
    [startPoints addPlace:startPointAddress], [startPoints saveData];
}
//Method: saveEndPoint
//Purpose: adds new location and saves it to our endPoint
- (void) saveEndPoint: (NSString *) endPointAddress{
    [endPoints addPlace:endPointAddress], [endPoints saveData];
}
//Method: Set Up Past Values
//Purpose: Populates the Array for the Values to be used when Populating the Array
- (void) setUpPastValues
{
    if (pastValues) {
        [pastValues removeAllObjects];
    }
    if (selectedTextField.tag == WHEN)
    {
        pastValues = [[NSMutableArray alloc] initWithObjects:@"Now", @"5 min", @"10 min", @"15 min", nil];
    }
    else if (selectedTextField.tag == TO)
    {
        pastValues = [[NSMutableArray alloc] initWithArray:[startPoints data]];
    }
    else if (selectedTextField.tag == FROM)
    {
        pastValues = [[NSMutableArray alloc] initWithArray:[endPoints data]];
    }
}
//Method: searchAutocompleteEntriesWithSubString
//Purpose: Helper method to textField shoudlChangeCharactersInRange
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    if (!autocompleteValues)
    {
        autocompleteValues = [[NSMutableArray alloc] init];
    }
    [autocompleteValues removeAllObjects];
    if ([substring isEqualToString:@""])
    {
        for (NSString *current in pastValues) {
            [autocompleteValues addObject:current];
        }
    }
    else
    {
        for(NSString *curString in pastValues) {
            NSString *compA = [curString lowercaseString];
            NSString *compB = [substring lowercaseString];
            NSRange substringRange = [compA rangeOfString:compB];
            if (substringRange.location == 0) {
                [autocompleteValues addObject:curString];
            }
        }
    }
    [autocompleteTableView reloadData];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return autocompleteValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    cell.textLabel.text = [autocompleteValues objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedTextField.text = selectedCell.textLabel.text;
    [autocompleteTableView removeFromSuperview];
    [selectedTextField resignFirstResponder]; // Hide Keyboard
}

@end
