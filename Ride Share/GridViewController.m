//
//  GridViewController.m
//  Ride Share
//
//  Created by Luis Valencia on 9/5/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import "GridViewController.h"
#import "MyURLConnection.h"
#import "SBJSon.h"
#import "SwissKnife.h"

///////////////////////////////////////////////////////////////////////////////
@interface MyTapGestureRecognizer : UITapGestureRecognizer{
    MyTableViewCell *someCell;
}
- (void) setCell: (MyTableViewCell *) cell;
- (MyTableViewCell *) getCell;
@end

@implementation MyTapGestureRecognizer
- (void) setCell: (MyTableViewCell *) cell{ someCell = cell; }
- (MyTableViewCell *) getCell { return someCell; }
@end
///////////////////////////////////////////////////////////////////////////////

@interface GridViewController ()

//Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

//My Methods
- (IBAction) handlePlusMinusTap: (id) sender;

@end

@implementation GridViewController

@synthesize grid;
@synthesize eta;
@synthesize runningTotal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ofKind: (int) type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        segmentedJSONStrings = [[NSMutableDictionary alloc] init];
        firstPresentation = YES;
    }
    return self;
}
- (void) setLocationController: (LocationsController *) locControl{
    self->routeLocations = locControl;
}
- (void) setRequestsHandler: (RequestHandler *) reqHandle{
    self->hireling = reqHandle;
}
- (void)viewWillAppear:(BOOL)animated  {
    //GridView Set Up
    grid = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, 365) style:UITableViewStylePlain];
    [grid setDelegate:self];
    [grid setDataSource:self]; 
    grid.scrollEnabled = YES;
    grid.hidden = NO;
    
    [self.view addSubview:grid]; //We do need to add it as a subview
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (void) viewDidAppear:(BOOL)animated{
    //Okay You need to make sure this only happens once
    //You need to make sure that the waypoint is in the waypoint array so the total time gets totaled
    //Correctly
    if (firstPresentation)
    {
        [self recalculateRouteWithDelegate: self];
        firstPresentation = NO;
    }
    else
    {
        [ridersData removeAllObjects];
        [self recalculateRouteWithDelegate: self];
    }        
}
- (void) recalculateRouteWithDelegate: (id) delegate {
    [hireling searchForDirectionsGivenStartPoint:[routeLocations startPoint] andEndPoint:[routeLocations endPoint] withWayPoints:[routeLocations onRoute] shouldSearchOptimally:YES shouldUtilizeSensor:NO andConnnectionType:GRID_DIRECTIONS_REQUEST setDelegate: self forLocation:nil];
    
    for (Location* loc in [routeLocations validLocations])
    {
        if ([loc isWayPoint])
        {
            NSMutableArray *temp = [routeLocations onRoute];
            [temp addObject:loc];
            [hireling searchForDirectionsGivenStartPoint:[routeLocations startPoint] andEndPoint:[routeLocations endPoint] withWayPoints:temp shouldSearchOptimally:YES shouldUtilizeSensor:NO andConnnectionType:[loc locationGridType] setDelegate:delegate forLocation:loc];
            [temp removeLastObject];
        }
        else{
            NSMutableArray *temp = [routeLocations onRoute];
            [temp removeObject:loc];
            [hireling searchForDirectionsGivenStartPoint:[routeLocations startPoint] andEndPoint:[routeLocations endPoint] withWayPoints:temp shouldSearchOptimally:YES shouldUtilizeSensor:NO andConnnectionType:[loc locationGridType] setDelegate:delegate forLocation:loc];
        }
    }
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
- (void) setTotalTime: (NSUInteger) seconds
{
    runningTotal = (NSTimeInterval)seconds;
    [eta setText:[NSString stringWithFormat:@"Duration: %@", [SwissKnife timeInSecondsToHumanReadable:runningTotal]]];
}
//Method: handlePlusMinusTap
//Purpose: Handles the Action Taken When Trying to Add or Remove Someone from the Permanent Route
- (IBAction) handlePlusMinusTap: (id)sender
{
    MyTableViewCell *passedCell;
    //Attention to Detail : Make sure it highlights blue only when we click image
    if ([sender isKindOfClass:[MyTapGestureRecognizer class]]){
        passedCell = [sender getCell];
    }
    else if ([sender isKindOfClass:[MyTableViewCell class]])
    {
        passedCell = sender;
    }
    else { return; }
    //Logic
    passedCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    [passedCell setHighlighted:YES animated:YES];
    [passedCell setHighlighted:NO animated:YES];
    //Ensure Switch Click
    if ([passedCell isPartOfRoute]){ // Removing From Route
        [[passedCell location] setIsOnRoute:NO], [[passedCell location] setIsWayPoint:YES];
        [self setTotalTime:runningTotal-[passedCell eta]];
    }
    else { //Adding to Route
        [[passedCell location] setIsOnRoute:YES], [[passedCell location] setIsWayPoint:NO];
        passedCell.imageView.image = [passedCell colorCoding];
        [self setTotalTime:runningTotal+[passedCell eta]];
    }
    passedCell.imageView.image = [passedCell colorCoding];
    passedCell.textLabel.text = [passedCell timeAddedByTakingMe];

    if (!HUD) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.delegate = self;
        HUD.labelText = @"Jesting...";
        HUD.detailsLabelText = @"Fooling Around";
        HUD.square = YES;
    }
	[self.view addSubview:HUD];
	
    [hireling setQueriesToProcess:[ridersData count]];
    [hireling setTarget:self];
    [self recalculateRouteWithDelegate:hireling];
    
    [HUD showWhileExecuting:@selector(reorganizeCells) onTarget:self withObject:nil animated:YES];
}
- (void) reorganizeCells{
    while(![hireling queriesToProcess] <= 0);
    [ridersData removeAllObjects];
    for (MyTableViewCell *aCell in [hireling objectResponse])
    {
        [ridersData addObject:aCell];
    }
    [grid reloadData];
    [hireling clearHandledRequests];
}
//Method: Connection didReceiveData
//Purpose: What we do with the Data Depening on the Type of Request that was Made
//         It's called by the NSURLConnection delegate
- (void)connection:(MyURLConnection *)connection didReceiveData:(NSData *)data
{
    //The string received from google's servers
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //Deal with Segmented JSON Response
    NSDictionary *results = [SwissKnife handleSegmentedJsonResponse:connection forSegmentedResponse:jsonString];
    if (!results) return;
    
    if ([connection typeOfConnection] == GRID_DIRECTIONS_REQUEST ||
        [connection typeOfConnection] == GRID_KNOWN_WAYPOINT_REQUEST ||
        [connection typeOfConnection] == GRID_UNKNOWN_WAYPOINT_REQUEST ||
        [connection typeOfConnection] == GRID_SCRAPE_WAYPOINT_REQUEST)
    {
        NSArray *routes = [results objectForKey:@"routes"];
        NSArray *legs = [[routes objectAtIndex:0] objectForKey:@"legs"];
        NSUInteger total = 0;
        for (NSDictionary* current in legs)
        {
            NSString* duration = [[current objectForKey:@"duration"] objectForKey:@"value"];
            total += [duration integerValue];
        }
        
        if ([connection typeOfConnection] == GRID_DIRECTIONS_REQUEST) {
            [self setTotalTime:total];
        }
        else
        {
            MyTableViewCell* cellObject = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
            [cellObject setLocation:[connection locAffiliation]];
            switch ([connection typeOfConnection]) {
                case GRID_KNOWN_WAYPOINT_REQUEST:
                    [cellObject setType:BLUE_CELL];
                    [cellObject setMapRequestEquivalent:LOCATION_REQUEST];
                    break;
                case GRID_UNKNOWN_WAYPOINT_REQUEST:
                    [cellObject setType:ORANGE_CELL];
                    [cellObject setMapRequestEquivalent:UNKNOWN_REQUEST];
                    break;
                default:
                    [cellObject setType:GREY_CELL];
                    [cellObject setMapRequestEquivalent:SCRAPE_REQUEST];
                    break;
            }
            [cellObject setTimeAddedByTakingMe:total-runningTotal];
            [ridersData addObject:cellObject];
            [grid reloadData];
        }
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!ridersData){
        ridersData = [[NSMutableArray alloc] init];
        return 0;
    }
    else { return [ridersData count]; }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (MyTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger lastIndex = indexPath.row;
    if ([ridersData count] > lastIndex){
        //Cell Configuration
        cell = [[ridersData sortedArrayUsingSelector:@selector(compare:)] objectAtIndex: lastIndex];
        cell.imageView.image = [cell colorCoding];
        cell.textLabel.text = [cell timeAddedByTakingMe];
        cell.textLabel.textAlignment = UITextAlignmentRight;
        cell.imageView.userInteractionEnabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        MyTapGestureRecognizer *singleFingerTap = [[MyTapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(handlePlusMinusTap:)];
        [singleFingerTap setCell:cell];
        singleFingerTap.numberOfTapsRequired = 1;
        [cell.imageView addGestureRecognizer:singleFingerTap];
        [cell addSubview:cell.imageView];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        displayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(55, 0, 40, 40)];
        //displayImageView.image = [cell getDisplayImage];
        if (!(displayImageView.image = [cell getDisplayImage]))
        {
            switch (lastIndex % 8) {
                case 0:
                    displayImageView.image = [UIImage imageNamed:@"Jester1.png"];
                    break;
                case 1:
                    displayImageView.image = [UIImage imageNamed:@"Person1.png"];
                    break;
                case 2:
                    displayImageView.image = [UIImage imageNamed:@"Jester2.png"];
                    break;
                case 3:
                    displayImageView.image = [UIImage imageNamed:@"Person2.png"];
                    break;
                case 4:
                    displayImageView.image = [UIImage imageNamed:@"Jester3.png"];
                    break;
                case 5:
                    displayImageView.image = [UIImage imageNamed:@"Person3.png"];
                    break;
                case 6:
                    displayImageView.image = [UIImage imageNamed:@"Jester4.png"];
                    break;
                case 7:
                    displayImageView.image = [UIImage imageNamed:@"Person4.png"];
                    break;
                default:
                    displayImageView.image = [UIImage imageNamed:@"displaySampleImage.png"];
                    break;
            }
        }
        [cell addSubview:displayImageView];
        
        return cell;
    }
    else {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
        cell.textLabel.text = @"They're all the Same";
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        return cell;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Riders";
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
     message:[NSString stringWithFormat:@"You selected"]
     delegate:nil
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alert show];
     [alert release];*/
    
    //Ensure No Highlight on Click of Cell
    MyTableViewCell *someCell = (MyTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    someCell.selectionStyle = UITableViewCellSelectionStyleNone;
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped that Bitch");
}

#pragma mark MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
}

#pragma mark - CLLocationManagerDelegate
/**
 Conditionally enable the Search/Add buttons:
 If the location manager is generating updates, then enable the buttons;
 If the location manager is failing, then disable the buttons.
 */
- (void)updateLocations {
    //We need to be sure we're synced with the database data
    NSMutableArray* array = [routeLocations validLocations];
    [array removeAllObjects]; //Needs to be two lines so the ARC picks it up

    //Size of Query Radius in Kilometers
    CGFloat kilometers = 100;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Riders"];
    [query setLimit:1000];
    [query whereKey:@"geoPoint"
       nearGeoPoint:[PFGeoPoint geoPointWithLatitude:[routeLocations locationManager].location.coordinate.latitude
                                           longitude:[routeLocations locationManager].location.coordinate.longitude]
   withinKilometers:kilometers];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                PFObject* curLoc = [routeLocations currentLocation];
                if (![[object objectId] isEqualToString:[curLoc objectId]]){
                    //Add object to Valid Locations
                    PFGeoPoint* point = [object objectForKey:@"geoPoint"];
                    NSString* header = [object objectForKey:@"header"];
                    NSNumber * num = [object objectForKey:@"locationType"];
                    NSLog(@"Number Retrieved %d", [num integerValue]);
                    pair p = [SwissKnife unCantor:[num integerValue]];
                    
                    Location *aLoc = [[Location alloc] initWithAddress:header];
                    [aLoc setLocationType:p.x];
                    [aLoc setLocationGridType:p.y];
                    [aLoc setHeader:header];
                    [aLoc setGeoPoint:point];
                    
                    BOOL isInList = NO;
                    //Perform a Check to See if Object is already in the list
                    //We need to use a better unique comparison other than address
                    for (Location* loc in [routeLocations validLocations])
                    {
                        NSLog(@"%@ compareTo %@", [loc address], [aLoc address]);
                        if ([[loc address] isEqualToString:[aLoc address]]) {
                            isInList = YES;
                            break;
                        }
                    }
                    if (!isInList)
                    {
                        [routeLocations addLocation:aLoc];
                        //NSLog(@"Added %@ (%f, %f) %d, %d", header, [point latitude], [point longitude], p.x, p.y);
                        //NSLog(@"Array Size Now %d", [[routeLocations validLocations] count]);
                        [self recalculateRouteWithDelegate:self];
                    }
                }
            }
        }
    }];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //Update Location in Database
    NSLog(@"Updated Location From: %@ To: %@", oldLocation, newLocation);
    [routeLocations insertCurrentLocation];
    [self updateLocations];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed with Error %@", [error localizedDescription]);
}

@end
