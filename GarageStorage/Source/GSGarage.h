//
//  GSGarage.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/22/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GarageStorage.h"

@class NSPersistentStoreCoordinator, NSManagedObjectModel;

@interface GSGarage : NSObject

/**
 *  Creates a Garage with a peristent store coordinator provided by the user.
 *
 *  @warning You must use the garageModel as the NSManagedObjectModel when initializing a custom persistentStoreCoordinator. When in doubt, let the Garage manage its own Core Data Stack.
 *  @param persistentStoreCoordinator An NSPersistentStoreCoordinator to use in the Garage's Core Data Stack
 *
 *  @return A GSGarage
 */
- (nonnull instancetype)initWithPersistentStoreCoordinator:(nullable NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/**
 *  The managed object model to initialize the persistentStoreCoordinator with.
 *
 *  @return An NSManagedObjectModel
 */
+ (nonnull NSManagedObjectModel *)garageModel;

/**
 *  Since GarageStorage is backed by Core Data, changes to the managed object context are not automatically saved to disk. Therefore, after each Save/SetSyncStatus/Delete, you need to call saveGarage in order to persist those changed. However, when autosaveEnabled is set to YES, the garage will be saved after any operation that causes a change to the MOC. When NO, save calls must be performed manually. This is set to YES by default.
 */
@property (nonatomic) BOOL autosaveEnabled;

/**
 *  Add an object to the Garage.
 *
 *  @param object An NSObject that conforms to GSMappableObject.
 */
- (void)parkObjectInGarage:(nonnull id<GSMappableObject>)object;

/**
 *  Adds an array of objects to the garage. If you park an object that does not have an identifier set, it will go into the Garage as unidentified.
 *
 *  @param objects An NSArray of objects, all of which must conform to GSMappableObject.
 */
- (void)parkObjectsInGarage:(nonnull NSArray *)objects;

/**
 *  Fetches an object of a given class with a given identifier from the Garage.
 *
 *  @param cls        The class of the object you wish to retrieve. This class must conform to GSMappableObject
 *  @param identifier The identifier of the object you wish to retrieve. This is the identifier specified by that object's mapping.
 *
 *  @return An NSObject conforming to GSMappableObject.
 */
- (nullable id)retrieveObjectOfClass:(nonnull Class)cls identifier:(nonnull NSString *)identifier;

/**
 *  Fetches all objects of a given class from the Garage.
 *
 *  @param cls The class of the objects you wish to retrieve
 *
 *  @return An NSMutableArray of objects, all of which conform to GSMappableObject. If no objects are found, an empty array is returned.
 */
- (nonnull NSMutableArray *)retrieveAllObjectsOfClass:(nonnull Class)cls;

/**
 *  Sets the sync status for a given GSMappableObject
 *
 *  @param syncStatus The GSSyncStatus of the object
 *  @param object     A GSMappableObject
 *
 *  @return YES if successful (the object was found), NO if not
 */
- (BOOL)setSyncStatus:(GSSyncStatus)syncStatus forObject:(nonnull id<GSMappableObject>)object;

/**
 *  Sets the sync status for an array of GSMappableObjects
 *
 *  @param syncStatus The GSSyncStatus of the objects
 *  @param objects     An NSArray of GSMappableObjects
 *
 *  @return YES if successful (syncStatus was set on all), NO if not. Note: Even if this returns NO, there still could be objects with their syncStatus was set successfully. A NO repsonse simply indicates a minimum of 1 failure.
 */
- (BOOL)setSyncStatus:(GSSyncStatus)syncStatus forObjects:(nonnull NSArray *)objects;

/**
 *  Returns the sync status for an object.
 *
 *  @param object A GSMappableObject
 *
 *  @return The Sync Status
 */
- (GSSyncStatus)syncStatusForObject:(nonnull id<GSMappableObject>)object;

/**
 *  Returns all the GSMappableObjects that have a given sync status
 *
 *  @param syncStatus The Sync Status
 *
 *  @return An NSMutableArray of GSMappableObjects. If no objects are found, an empty array is returned.
 */
- (nonnull NSMutableArray *)retrieveObjectsWithSyncStatus:(GSSyncStatus)syncStatus;

/**
 *  Returns all the GSMappableObjects of a given class that have a given sync status
 *
 *  @param syncStatus The Sync Status
 *  @param cls        The Class of the GSMappableObjects
 *
 *  @return An NSMutableArray of GSMappableObjects. If no objects are found, an empty array is returned.
 */
- (nonnull NSMutableArray *)retrieveObjectsWithSyncStatus:(GSSyncStatus)syncStatus ofClass:(nonnull Class)cls;

/**
 *  Deletes an object from the Garage. Note that deleting an object will only delete that specific object, and not any of its member variables. While parking an object into the garage is recursive, and member variables will be parked, deletion is not. Therefore, if you want an object's member variables removed from the Garage, you should remove them individually first.
 *
 *  @param object    An object conforming to GSMappableObject
 *
 */
- (void)deleteObjectFromGarage:(nonnull id<GSMappableObject>)object;

/**
 *  Deletes all objects of a given type from the Garage
 *
 *  @param cls    A Class conforming to GSMappableObject
 *
 */
- (void)deleteAllObjectsFromGarageOfClass:(nonnull Class)cls;

/**
 *  Deletes all objects from the Garage.
 */
- (void)deleteAllObjectsFromGarage;

/**
 *  Saves all changes to the Garage to the persistent store. This will not affect in-memory GSMappableObjects.
 */
- (void)saveGarage;

@end
