//
//  GSGarage.m
//  GarageStorage
//
//  Created by Sam Voigt on 4/22/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "GSGarage.h"
#import "GSCoreDataStack.h"
#import "GSObjectMapper.h"
#import "GSCoreDataObject.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *const kGSEntityName = @"GSCoreDataObject";

@interface GSGarage () <GSObjectMapperDataSource>

@property (strong, nonatomic) GSCoreDataStack *coreDataStack;
@property (strong, nonatomic) GSObjectMapper *objectMapper;

@end

@implementation GSGarage

#pragma mark - Initializers

- (instancetype)init {
    
    return [self initWithPersistentStoreCoordinator:nil];
}

- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    self = [super init];
    if (self) {
        self.coreDataStack = [[GSCoreDataStack alloc] initWithPersistentStoreCoordinator:persistentStoreCoordinator];
        self.objectMapper = [GSObjectMapper new];
        self.objectMapper.delegate = self;
        self.autosaveEnabled = YES;
    }
    return self;
}

+ (NSManagedObjectModel *)garageModel {
    
    return [GSCoreDataStack garageModel];
}

#pragma mark - Parking Objects

- (void)parkObjectInGarage:(id<GSMappableObject>)object {
   
    [self parkObjectInGarage:object saveWhenFinished:self.autosaveEnabled];
}

- (void)parkObjectsInGarage:(NSArray *)objects {
    
    for (id object in objects) {
        if ([object conformsToProtocol:@protocol(GSMappableObject)]) {
            [self parkObjectInGarage:object saveWhenFinished:NO];
        }
    }
    [self saveGarageIfAutosaveEnabled];
}

- (void)parkObjectInGarage:(id<GSMappableObject>)object saveWhenFinished:(BOOL)saveWhenFinished {
    
    [self.objectMapper mapGSMappableObjectToGSCoreDataObject:object];
    if (saveWhenFinished) {
        [self saveGarage];
    }
}

#pragma mark - Retrieving Objects

- (id)retrieveObjectOfClass:(Class)cls identifier:(NSString *)identifier {
   
    GSCoreDataObject *object = [self fetchObjectWithType:NSStringFromClass(cls) identifier:identifier];
    if (object) {
        return [self.objectMapper mapGSCoreDataObjectToGSMappableObject:object];
    }
    return nil;
}

- (NSMutableArray *)retrieveAllObjectsOfClass:(Class)cls {

    return [self gsMappableObjectsForGSCoreDataObjects:[self fetchObjectsWithType:NSStringFromClass(cls) identifier:nil]];
}

#pragma mark - Sync Status Setting

- (BOOL)setSyncStatus:(GSSyncStatus)syncStatus forObject:(id<GSMappableObject>)object {
    
    return [self setSyncStatus:syncStatus forObject:object saveWhenFinsished:self.autosaveEnabled];
}

- (BOOL)setSyncStatus:(GSSyncStatus)syncStatus forObjects:(NSArray *)objects {
    
    BOOL syncSuccessful = YES;
    
    for (id<GSMappableObject> object in objects) {
        if (![self setSyncStatus:syncStatus forObject:object saveWhenFinsished:NO]) {
            syncSuccessful = NO;
        }
    }
    
    [self saveGarageIfAutosaveEnabled];
    
    return syncSuccessful;
}

- (BOOL)setSyncStatus:(GSSyncStatus)syncStatus forObject:(id<GSMappableObject>)object saveWhenFinsished:(BOOL)saveWhenFinished {
    
    GSCoreDataObject *coreDataObject = [self gsCoreDataObjectForObject:object createIfNeeded:NO];
    if (!coreDataObject) {
        return NO;
    }
    
    coreDataObject.gs_syncStatus = @(syncStatus);
    if (saveWhenFinished) {
        [self saveGarage];
    }
    
    return YES;
}

#pragma mark - Sync Status Retrieving

- (GSSyncStatus)syncStatusForObject:(id<GSMappableObject>)object {
    
    GSSyncStatus syncStatus = GSSyncStatusUndetermined;
    
    GSCoreDataObject *coreDataObject = [self gsCoreDataObjectForObject:object createIfNeeded:NO];
    if (coreDataObject) {
        syncStatus = [coreDataObject.gs_syncStatus integerValue];
    }
    
    return syncStatus;
}

- (NSMutableArray *)retrieveObjectsWithSyncStatus:(GSSyncStatus)syncStatus {
    
    return [self gsMappableObjectsForGSCoreDataObjects:[self fetchObjectsWithSyncStatus:syncStatus ofType:nil]];
}

- (NSArray *)retrieveObjectsWithSyncStatus:(GSSyncStatus)syncStatus ofClass:(Class)cls {
    
    return [self gsMappableObjectsForGSCoreDataObjects:[self fetchObjectsWithSyncStatus:syncStatus ofType:NSStringFromClass(cls)]];
}

#pragma mark - Deleting Objects

- (void)deleteObjectFromGarage:(id<GSMappableObject>)object {
   
    GSCoreDataObject *coreDataObject = [self fetchGSCoreDataObjectForObject:object];
    if (coreDataObject) {
        [self.coreDataStack.managedObjectContext deleteObject:coreDataObject];
        [self saveGarageIfAutosaveEnabled];
    }
}

- (void)deleteAllObjectsFromGarageOfClass:(Class)cls {
    
    NSArray *allObjectsOfClass = [self fetchObjectsWithType:NSStringFromClass(cls) identifier:nil];
    
    if (allObjectsOfClass.count > 0) {
        [self deleteObjects:allObjectsOfClass];
        [self saveGarageIfAutosaveEnabled];
    }
}

- (void)deleteAllObjectsFromGarage {
   
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kGSEntityName];
    NSArray *allObjects = [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    if (allObjects.count > 0) {
        [self deleteObjects:allObjects];
        [self saveGarageIfAutosaveEnabled];
    }
}

- (void)deleteObjects:(NSArray *)objects {
    
    for (NSManagedObject *object in objects) {
        [self.coreDataStack.managedObjectContext deleteObject:object];
    }
    [self saveGarageIfAutosaveEnabled];
}

- (void)saveGarage {
    
    [self.coreDataStack saveContext];
}

- (void)saveGarageIfAutosaveEnabled {
    
    if (self.autosaveEnabled) {
        [self saveGarage];
    }
}

#pragma mark - GSManagedObjectDatasource

- (GSCoreDataObject *)newGSCoreDataObjectForObject:(id<GSMappableObject>)object {
    
    return [self gsCoreDataObjectForObject:object createIfNeeded:YES];
}

- (GSCoreDataObject *)fetchGSCoreDataObjectForObject:(id<GSMappableObject>)object {
    
    return [self gsCoreDataObjectForObject:object createIfNeeded:NO];
}

- (GSCoreDataObject *)fetchGSCoreDataObjectForPromise:(NSDictionary *)promise {
    
    return [self fetchObjectWithType:promise[kGSTypeKey] identifier:promise[kGSIdentifierKey]];
}

#pragma mark - Helper Methods

- (GSCoreDataObject *)gsCoreDataObjectForObject:(id<GSMappableObject>)object createIfNeeded:(BOOL)createIfNeeded {
    
    GSObjectMapping *mapping = [[object class] objectMapping];
    NSString *type = mapping.classNameForMapping;
    id nakedObject = object;
    
    NSString *identifier;
    // This case should only happen if you're trying to park a top level object that doesn't have an identifier. If sub-objects of your top level object are anonymous, they should be rendered as inline json, and not as separate core data objects.
    if (!mapping.identifyingAttribute) {
        identifier = [self MD5HashForString:[self.objectMapper jsonStringFromObject:object]];
    }
    else {
        identifier = [nakedObject valueForKey:mapping.identifyingAttribute];
        if (!identifier) {
            NSLog(@"Could not find identifying attribute for object: %@", object);
            return nil;
        }
    }
    
    GSCoreDataObject *coreDataObject = [self fetchObjectWithType:type identifier:identifier];
    
    if (coreDataObject || !createIfNeeded) {
        return coreDataObject;
    }
    else {
        coreDataObject = [NSEntityDescription insertNewObjectForEntityForName:kGSEntityName inManagedObjectContext:self.coreDataStack.managedObjectContext];
        coreDataObject.gs_type = type;
        coreDataObject.gs_identifier = identifier;
        coreDataObject.gs_creationDate = [NSDate date];
        coreDataObject.gs_version = @(mapping.version);
        
        return coreDataObject;
    }
}

- (NSMutableArray *)gsMappableObjectsForGSCoreDataObjects:(NSArray *)coreDataObjects {
    
    NSMutableArray *gsMappableObjects = [NSMutableArray new];
    for (GSCoreDataObject *coreDataObject in coreDataObjects) {
        id gsMappableObject = [self.objectMapper mapGSCoreDataObjectToGSMappableObject:coreDataObject];
        if (gsMappableObject) {
            [gsMappableObjects addObject:gsMappableObject];
        }
    }
    return gsMappableObjects;
}

- (GSCoreDataObject *)fetchObjectWithType:(NSString *)type identifier:(NSString *)identifier {
    NSArray *objects = [self fetchObjectsWithType:type identifier:identifier];
    if (objects.count > 0) {
        return objects[0];
    }
    return nil;
}

- (NSArray *)fetchObjectsWithType:(NSString *)type identifier:(NSString *)identifier {
    
    NSFetchRequest *fetchRequest = [self gsFetchRequest];
    fetchRequest.predicate = [self predicateForType:type identifier:identifier];
    
    NSArray *fetchedObjects = [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return fetchedObjects;
}

- (NSArray *)fetchObjectsWithSyncStatus:(GSSyncStatus)syncStatus ofType:(NSString *)type {
    
    NSFetchRequest *fetchRequest = [self gsFetchRequest];
    fetchRequest.predicate = [self predicateForSyncStatus:syncStatus type:type];
    
    return [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (NSPredicate *)predicateForType:(NSString *)type identifier:(NSString *)identifier {
    
    NSString *predicateString = [NSString stringWithFormat:@"%@ = \"%@\"", kGSTypeKey, type];
    if (identifier) {
        predicateString = [predicateString stringByAppendingString:[NSString stringWithFormat:@" && %@ = \"%@\"", kGSIdentifierKey, identifier]];
    }
    
    return [NSPredicate predicateWithFormat:predicateString];
}

- (NSPredicate *)predicateForSyncStatus:(GSSyncStatus)syncStatus type:(NSString *)type {
    
    NSString *predicateString = [NSString stringWithFormat:@"%@ = %li", kGSSyncStatusKey, (long)syncStatus];
    if (type) {
        predicateString = [predicateString stringByAppendingString:[NSString stringWithFormat:@" && %@ = \"%@\"", kGSTypeKey, type]];
    }
    
    return [NSPredicate predicateWithFormat:predicateString];
}

- (NSFetchRequest *)gsFetchRequest {
    
    return [NSFetchRequest fetchRequestWithEntityName:kGSEntityName];
}

- (NSString *)MD5HashForString:(NSString *)string {
    
    const char* input = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *hashedString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hashedString appendFormat:@"%02x", result[i]];
    }
    
    return hashedString;
}

@end
