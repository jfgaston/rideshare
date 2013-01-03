//
//  AutoCompleteTableViewController.h
//  Ride Share
//
//  Created by Luis Valencia on 9/6/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPlacesVisisted.h"

@interface AutoCompleteTableViewController : UITableViewController
{
    UITableView* autocompleteTableView;
    NSMutableArray *autocompleteValues; //Array of NSStrings
    NSMutableArray *pastValues;
    UITextField *selectedTextField;
    MyPlacesVisisted *startPoints;
    MyPlacesVisisted *endPoints;
}

@property (nonatomic, retain) UITableView* autocompleteTableView;
@property (nonatomic, retain) UITextField *selectedTextField;

- (id)initWithStyle:(UITableViewStyle)style andView: (UITableView *) view;
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring;
- (void)setUpPastValues;
- (void) saveStartPoint:(NSString *) startPointAddress;
- (void) saveEndPoint: (NSString *) endPointAddress;

@end
