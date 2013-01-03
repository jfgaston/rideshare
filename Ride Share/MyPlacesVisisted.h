//
//  MyPlacesVisisted.h
//  Ride Share
//
//  Created by Luis Valencia on 8/17/12.
//
//

#import <Foundation/Foundation.h>

@interface MyPlacesVisisted : NSObject <NSCoding>{
    NSMutableArray *placesLastVisited;
    NSString *savePath;
    NSString *saveName;
}

@property (nonatomic, retain) NSArray *placesLastVisited;

- (id) initWithDocPath: (NSString *) extention andFileName: (NSString *) name;
- (BOOL)createDataPath;
- (void) deleteDoc;
- (NSMutableArray *)data;
- (void)saveData;
- (void) addPlace: (NSString *) place;

@end
