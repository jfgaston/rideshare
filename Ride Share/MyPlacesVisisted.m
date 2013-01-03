//
//  MyPlacesVisisted.m
//  Ride Share
//
//  Created by Luis Valencia on 8/17/12.
//
//

#import "MyPlacesVisisted.h"
#define dataKey @"locations"
#define historyLength 4

@implementation MyPlacesVisisted

@synthesize placesLastVisited;

//Method: addPlace
//Purpose: Treats our MutableArray like a queue and adds an object to the beginning, if we've exceeded our
//         history length it deques the oldest object
- (void) addPlace:(NSString *)place
{
    NSString* insert = [place stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!placesLastVisited) { placesLastVisited = [[NSMutableArray alloc] initWithCapacity:historyLength]; }
    for (NSString *current in placesLastVisited)
    {
        NSString *cleanedString = [current lowercaseString];
        NSString *comparator = [insert lowercaseString];
        if ([cleanedString isEqualToString:comparator]) return;
    }
    if ([placesLastVisited count] == historyLength)
    {
        [placesLastVisited insertObject:insert atIndex:0];
        [placesLastVisited removeLastObject];
    }
    else
    {
        [placesLastVisited insertObject:insert atIndex:0];
    }
}
//Method: initWithDocPath andFileName
//Purpose: instantiates our class with the specified savePath and the Name of our file
- (id) initWithDocPath: (NSString *) extention andFileName: (NSString *) name
{
    if (self = [super init])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString*documentsDirectory = [paths objectAtIndex:0];
        savePath = [documentsDirectory stringByAppendingPathComponent:extention];
        saveName = [name copy];
    }
    return self;
}
//Method: createDataPath
//Purpose: Create's the path where the file will be stored and returns a boolean indicating
//         wether or not it was successful if the path exists then it's automatically successfull
- (BOOL)createDataPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:savePath isDirectory:NO])
    {
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) {
            NSLog(@"Error creating data path: %@", [error localizedDescription]);
        }
        return success;
    }
    return YES;
}
//Method: data
//Purpose: returns the NSMutableArray that is our data, if we have it loaded in memory we just return it
//         otherwise we read it from our file and load it into to memory and return that
- (NSMutableArray *)data
{
    if (placesLastVisited){ return placesLastVisited; }
    
    NSString *locationData = [savePath stringByAppendingFormat:@"/%@", saveName];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:locationData];
    if (codedData == nil){ return nil; }
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    placesLastVisited = [[NSMutableArray alloc] initWithArray:[unarchiver decodeObjectForKey:dataKey]];
    [unarchiver finishDecoding];
    return placesLastVisited;
}
//Method: saveData
//Purpose: if we have data to save it saves it otherwise it exists
- (void)saveData {
    if (placesLastVisited == nil) return;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:placesLastVisited forKey:dataKey];
    [archiver finishEncoding];
    NSString *dataPath = [savePath stringByAppendingFormat:@"/%@", saveName];
    [self createDataPath]; //If that Path doesn't exist we must explicitly create it
    [data writeToFile:dataPath atomically:YES];
}

//Method: deleteDoc
//Purpose: deletes the file at hand
- (void)deleteDoc {
    
    NSError *error;
    NSString *locationData = [savePath stringByAppendingFormat:@"/%@", saveName];
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:locationData error:&error];
    if (!success) {
        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }
    
}
# pragma mark NSCoding Methods

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        placesLastVisited = [decoder decodeObjectForKey:dataKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:placesLastVisited forKey:dataKey];
}

@end
