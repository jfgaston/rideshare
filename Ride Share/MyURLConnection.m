//
//  MyURLConnection.m
//  Ride Share
//
//  Created by Luis Valencia on 8/15/12.
//
//

#import "MyURLConnection.h"

@implementation MyURLConnection

@synthesize taskNumber;
@synthesize typeOfConnection;
@synthesize locAffiliation;

- (id) initWithRequest:(NSURLRequest *)request delegate:(id)delegate andWeight: (int) q andConnectionType:(int)t andLocationAffiliation: (Location *) address;
{
    self = [super initWithRequest:request delegate:delegate];
    if (self != nil)
    {
        taskNumber = q;
        typeOfConnection = t;
        if (!address) { locAffiliation  = nil; }
        else { self->locAffiliation = address; }
    }
    return self;
}
- (int) uniqueIdentifier { return taskNumber; }

@end
