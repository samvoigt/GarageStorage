//
//  GSCoreDataStack.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/22/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GSCoreDataStack : NSObject

+ (NSManagedObjectModel *)garageModel;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (void)saveContext;

@end
