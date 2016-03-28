//
//  AppDelegate.h
//  ApnsExampleObjC
//
//  Created by Pranav Prakash on 14/03/16.
//  Copyright © 2016 Aurora Borialis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>



@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) CLLocationManager *locationManager;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

