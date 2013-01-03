//
//  TDSemiModalViewController.m
//  TDSemiModal
//
//  Created by Nathan  Reed on 18/10/10.
//  Copyright 2010 Nathan Reed. All rights reserved.
//

#import "TDSemiModalViewController.h"

@implementation TDSemiModalViewController
@synthesize coverView;

-(void)viewDidLoad {
    [super viewDidLoad];
	coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	//self.coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [coverView setBackgroundColor:UIColor.blackColor];

	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

}
#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    //[super viewDidUnload];
    //[coverView release];
	coverView = nil;
}


@end
