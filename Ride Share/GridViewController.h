//
//  GridViewController.h
//  Ride Share
//
//  Created by Luis Valencia on 9/5/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyTableViewCell.h"
#import "RequestHandler.h"
#import "LocationsController.h"
#import "MBProgressHUD.h"

@interface GridViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, CLLocationManagerDelegate>{
    UITableView *grid;
    RequestHandler *hireling;
    LocationsController *routeLocations;
    UILabel *eta;
    NSMutableDictionary *segmentedJSONStrings;
    MyTableViewCell *cell;
    NSUInteger runningTotal; //Total Trip Time
    NSMutableArray *ridersData; //Array of MyTableViewCell
    UIImageView *displayImageView;
    BOOL firstPresentation;
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) IBOutlet UITableView* grid;
@property (nonatomic, retain) IBOutlet UILabel* eta;
@property (atomic, assign) NSUInteger runningTotal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ofKind: (int) type;
- (void) setLocationController: (LocationsController *) locControl;
- (void) setRequestsHandler: (RequestHandler *) reqHandle;
- (void) setTotalTime: (NSUInteger) seconds;

@end
