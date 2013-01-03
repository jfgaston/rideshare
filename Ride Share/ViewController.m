//
//  ViewController.m
//  Ride Share
//
//  Created by Luis Valencia on 9/5/12.
//  Copyright (c) 2012 Luis Valencia. All rights reserved.
//

#import "ViewController.h"
#import "RouteSelectionViewController.h"
#import "SwissKnife.h"

@interface ViewController ()
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognize;
- (void)handleTap: (UITapGestureRecognizer *) recognize;
- (void)switchBack: (UITapGestureRecognizer *) recognize;
@end

@implementation ViewController
@synthesize currentView;
@synthesize routeLocations;
//Method:handleSwipeFrom
//Purpose: handles the Swipe Logic for View Transition
//         needed as part of UIGestureRecognizerDelegate
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognize
{
    //Transition Animation
    [UIView transitionWithView:self.view
                duration:UINavigationControllerHideShowBarDuration
                options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^
         {
             //Transition Logic Goes Here
             if ([currentView isKindOfClass:[UIViewController class]] && ![currentView isKindOfClass:[RouteSelectionViewController class]])
             {
                 //Remove Current View
                 UIViewController *theView = currentView;
                 [theView.view removeFromSuperview];
                
                 @autoreleasepool {
                     //Next View
                     if (recognize.direction == UISwipeGestureRecognizerDirectionRight){
                        //Driver
                        RouteSelectionViewController *driverRoute = [[RouteSelectionViewController alloc] initWithNibName:@"RouteSelectionView" bundle:nil ofKind:DRIVER];
                        UISwipeGestureRecognizer *swipeType = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
                        [swipeType setNumberOfTouchesRequired:1];
                        swipeType.direction = UISwipeGestureRecognizerDirectionRight;
                        [driverRoute.view addGestureRecognizer:swipeType];
                        [self.view addSubview:driverRoute.view], currentView = driverRoute;
                    }
                    else if (recognize.direction == UISwipeGestureRecognizerDirectionLeft){
                        //Passanger
                        RouteSelectionViewController *passangerRoute = [[RouteSelectionViewController alloc] initWithNibName:@"RouteSelectionView" bundle:nil ofKind:PASSENGER];
                        UISwipeGestureRecognizer *swipeType = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
                        [swipeType setNumberOfTouchesRequired:1];
                        swipeType.direction = UISwipeGestureRecognizerDirectionLeft;
                        [passangerRoute.view addGestureRecognizer:swipeType];
                        [self.view addSubview:passangerRoute.view], currentView = passangerRoute;
                    }
                }
             }
             else if ([currentView isKindOfClass:[RouteSelectionViewController class]])
             {
                 //Save Data From RouteView Controller
                 RouteSelectionViewController *theView = currentView;
                 if (![theView saveData]){
                     //The Location Data We Inputed is Bad, Handle
                     return;
                 }
                 //Otherwise the Input is Good so Set Up your Initial Points on Route
                 routeLocations = [[LocationsController alloc] initWithStartPoint:[theView startLocation] andEndPoint:[theView endLocation]];
                 
                 requests = [[RequestHandler alloc] init];
                 
                 //Next View
                 if (recognize.direction == UISwipeGestureRecognizerDirectionRight){
                     //Driver Map View
                     mapView = [[MapViewController alloc] initWithNibName:@"MapView" bundle:nil ofKind:DRIVER];
                     
                     //Controls
                     [mapView setLocationController:routeLocations];
                     [mapView setRequestsHandler:requests];
                     [[routeLocations locationManager] setDelegate:mapView];
                     
                     //Start Location Services
                     [[routeLocations locationManager] startUpdatingLocation];
                     
                     UIView* tapRect = [[UIView alloc] initWithFrame:CGRectMake(225, 20, 75, 21)];
                     UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                     [tapRect addGestureRecognizer:tapGesture];
                     [mapView.view addSubview:tapRect];
                     [self.view addSubview:mapView.view], currentView = mapView;
                 }
                 else if (recognize.direction == UISwipeGestureRecognizerDirectionLeft){
                     //Passanger Grid View
                     gridView = [[GridViewController alloc] initWithNibName:@"GridView" bundle:nil ofKind:PASSENGER];
                     
                     //Controls
                     [gridView setLocationController:routeLocations];
                     [gridView setRequestsHandler:requests];
                     [[routeLocations locationManager] setDelegate:gridView];
                     
                     //Start Location Services
                     [[routeLocations locationManager] startUpdatingLocation];
                     
                     UIView* tapRect = [[UIView alloc] initWithFrame:CGRectMake(225, 20, 75, 21)];
                     UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                     [tapRect addGestureRecognizer:tapGesture];
                     [gridView.view addSubview:tapRect];
                     [self.view addSubview:gridView.view], currentView = gridView;
                     
                 }
             }
         }
                completion:nil];
}
//Method: handleTap
//Purpose: handles the Tap Logic for View for Transition Switches Between Map and Grid
//         needed as part of UIGestureRecognizerDelegate
- (void) handleTap: (UITapGestureRecognizer *) recognize
{
    [UIView transitionWithView:self.view
                      duration:UINavigationControllerHideShowBarDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^
        {
            if ([currentView isKindOfClass:[MapViewController class]])
            {
                //Driver Grid View
                if(!gridView){
                    gridView = [[GridViewController alloc] initWithNibName:@"GridView" bundle:nil ofKind:DRIVER];
                    
                    //Controls
                    [gridView setLocationController:routeLocations];
                    [gridView setRequestsHandler:requests];
                    
                    UIView* tapRect = [[UIView alloc] initWithFrame:CGRectMake(225, 20, 75, 21)];
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchBack:)];
                    [tapRect addGestureRecognizer:tapGesture];
                    [gridView.view addSubview:tapRect];
                    [self.view addSubview:gridView.view], currentView = gridView;
                }
                else{
                    [self.view addSubview:gridView.view], currentView = gridView;
                }
            }
            else if ([currentView isKindOfClass:[GridViewController class]])
            {
                //Passenger Map View
                if (!mapView){
                    mapView = [[MapViewController alloc] initWithNibName:@"MapView" bundle:nil ofKind:PASSENGER];
                    
                    //Controls
                    [mapView setLocationController:routeLocations];
                    [mapView setRequestsHandler:requests];
                    
                    UIView* tapRect = [[UIView alloc] initWithFrame:CGRectMake(225, 20, 75, 21)];
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchBack:)];
                    [tapRect addGestureRecognizer:tapGesture];
                    [mapView.view addSubview:tapRect];
                    [self.view addSubview:mapView.view], currentView = mapView;
                }
                else{
                    [self.view addSubview:mapView.view], currentView = mapView;
                }
            }
        }
                    completion:nil];
}
//Method: switchBack
//Purpose: Handle's the Tap Logic for the View Transition back from Grid or Map View
//         needed as part of UIGestureRecognizerDelegate
- (void)switchBack: (UITapGestureRecognizer *) recognize
{
    //Transition Animation
    [UIView transitionWithView:self.view
                      duration:UINavigationControllerHideShowBarDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^
     {
        if ([currentView isKindOfClass:[MapViewController class]])
        {
            MapViewController *theView = currentView;
            UIView* temp;
            temp = [theView.view superview];
            [theView.view removeFromSuperview];
            currentView = gridView;
        }
        else if ([currentView isKindOfClass:[GridViewController class]])
        {
            GridViewController *theView = currentView;
            UIView* temp;
            temp = [theView.view superview];
            [theView.view removeFromSuperview];
            currentView = mapView;
        }
        [[routeLocations locationManager] setDelegate:currentView];
        [currentView viewDidAppear:YES];
     }
                    completion:nil];
}
- (void)viewDidLoad
{
    NSLog(@"%@",[SwissKnife getIPAddress]);
    [super viewDidLoad];
    @autoreleasepool {
        // Do any additional setup after loading the view, typically from a nib.
        UIViewController *dpView = [[UIViewController alloc] initWithNibName:@"DriverOrPassangerView" bundle:nil];
        //Swipe Gesture Recognizors
        UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [leftSwipeGesture setNumberOfTouchesRequired:1];
        leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [dpView.view addGestureRecognizer:leftSwipeGesture];
        
        UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [rightSwipeGesture setNumberOfTouchesRequired:1];
        rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        [dpView.view addGestureRecognizer:rightSwipeGesture];
        
        [self.view addSubview:dpView.view], currentView = dpView;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
