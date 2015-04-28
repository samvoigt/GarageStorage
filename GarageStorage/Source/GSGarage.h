//
//  GSGarage.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/22/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GarageStorage.h"

typedef NS_ENUM(NSInteger, GSSyncStatus) {
    GSSyncStatusUndetermined,
    GSSyncStatusNotSynced,
    GSSyncStatusSyncing,
    GSSyncStatusSynced
};

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
- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/**
 *  The managed object model to initialize the persistentStoreCoordinator with.
 *
 *  @return An NSManagedObjectModel
 */
+ (NSManagedObjectModel *)garageModel;

/**
 *  Add an object to the Garage. This will not save the object in a persistent store.
 *
 *  @param object An NSObject that conforms to GSMappableObject.
 */
- (void)parkObjectInGarage:(id<GSMappableObject>)object;

/**
 *  Adds an array of objects to the garage. This will not save the objects in a persistent store. If you park an object that does not have an identifier set, it will go into the Garage as unidentified, and you will need to later call updateIdentifierForObject.
 *
 *  @param objects An NSArray of objects, all of which must conform to GSMappableObject.
 */
- (void)parkObjectsInGarage:(NSArray *)objects;

/**
 *  Fetches an object of a given class with a given identifier from the Garage.
 *
 *  @param cls        The class of the object you wish to retrieve
 *  @param identifier The identifier of the object you wish to retrieve. This is the identifier specified by that object's mapping.
 *
 *  @return An NSObject conforming to GSMappableObject.
 */
- (id<GSMappableObject>)retrieveObjectOfClass:(Class)cls identifier:(NSString *)identifier;

/**
 *  Fetches all objects of a given class from the Garage.
 *
 *  @param cls The class of the objects you wish to retrieve
 *
 *  @return An NSArray of objects, all of which conform to GSMappableObject
 */
- (NSArray *)retrieveAllObjectsOfClass:(Class)cls;

/**
 *  Updates the identifier of a given GSMappableObject. If you do not set the identifier on an object when parking it, e.g. you're waiting on an ID to be returned by a server, it goes into the Garage as unidentified. Call this method once the GSMappableObject has its identifier set, and the corresponding backing object will get its identifier set.
 *
 *  @param object A GSMappableObject with the updated identifier.
 *
 *  @return YES if the update succeeds, NO if the Garage was unable to find a matching object and update its identifier.
 */
- (BOOL)updateIdentifierForObject:(id<GSMappableObject>)object;

/**
 *  Sets the sync status for a given GSMappableObject
 *
 *  @param syncStatus The GSSyncStatus of the object
 *  @param object     A GSMappableObject
 *
 *  @return YES if successful (the object was found), NO if not
 */
- (BOOL)setSnycStatus:(GSSyncStatus)syncStatus forObject:(id<GSMappableObject>)object;

/**
 *  Sets the sync status for an array of GSMappableObjects
 *
 *  @param syncStatus The GSSyncStatus of the objects
 *  @param objects     An NSArray of GSMappableObjects
 *
 *  @return YES if successful (syncStatus was set on all), NO if not. Note: Even if this returns NO, there still could be objects with their syncStatus was set successfully. A NO repsonse simply indicates a minimum on 1 failure.
 */
- (BOOL)setSnycStatus:(GSSyncStatus)syncStatus forObjects:(NSArray *)objects;

- (GSSyncStatus)syncStatusForObject:(id<GSMappableObject>)object;

- (NSArray *)retrieveObjectsWithSyncStatus:(GSSyncStatus)syncStatus;
- (NSArray *)retrieveObjectsWithSyncStatus:(GSSyncStatus)syncStatus ofClass:(Class)cls;

/**
 *  Deletes an object from the Garage. Note that deleting an object will only delete that specific object, and not any of its member variables. While parking an object into the garage is recursive, and member variables will be parked, deletion is not. Therefore, if you want an object's member variables removed from the Garage, you should remove them individually first. This operation will not affect the persistent store.
 *
 *  @param object    An object conforming to GSMappableObject
 *
 */
- (void)deleteObjectFromGarage:(id<GSMappableObject>)object;

/**
 *  Deletes all objects of a given type from the Garage
 *
 *  @param cls    A Class conforming to GSMappableObject
 *
 */
- (void)deleteAllObjectsFromGarageOfClass:(Class)cls;

/**
 *  Deletes all objects from the Garage. This operation will not affect the persistent store.
 */
- (void)deleteAllObjectsFromGarage;

/**
 *  Saves all changes to the Garage to the persistent store. This will not affect in-memory GSMappableObjects.
 */
- (void)saveGarage;

@end
