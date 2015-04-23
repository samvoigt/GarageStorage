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

static NSString *const kGSEntityName = @"GSCoreDataObject";
NSString *const kGSTypeKey = @"gs_type";
NSString *const kGSIdentifierKey = @"gs_identifier";

@interface GSGarage () <GSObjectMapperDataSource>

@property (strong, nonatomic) GSCoreDataStack *coreDataStack;
@property (strong, nonatomic) GSObjectMapper *objectMapper;

@end

@implementation GSGarage

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.coreDataStack = [GSCoreDataStack new];
        self.objectMapper = [GSObjectMapper new];
        self.objectMapper.delegate = self;
    }
    return self;
}

- (void)parkObjectInGarage:(id<GSMappableObject>)object {
    [self.objectMapper mapGSMappableObjectToGSCoreDataObject:object];
}

- (void)parkObjectsInGarage:(NSArray *)objects {
    
    for (id object in objects) {
        if ([object conformsToProtocol:@protocol(GSMappableObject)]) {
            [self parkObjectInGarage:object];
        }
    }
}

- (id<GSMappableObject>)retrieveObjectOfClass:(Class)cls identifier:(NSString *)identifier {
   
    GSCoreDataObject *object = [self fetchObjectWithType:NSStringFromClass(cls) identifier:identifier];
    if (object) {
        return [self.objectMapper mapGSCoreDataObjectToGSMappableObject:object];
    }
    return nil;
}

- (NSArray *)retrieveAllObjectsOfClass:(Class)cls {

    NSMutableArray *objects = [NSMutableArray new];
    for (GSCoreDataObject *coreDataObject in [self fetchObjectsWithType:NSStringFromClass(cls) identifier:nil]) {
        [objects addObject:[self.objectMapper mapGSCoreDataObjectToGSMappableObject:coreDataObject]];
    }
    
    return objects;
}

- (void)deleteObjectFromGarage:(id<GSMappableObject>)object {
   
    [self.coreDataStack.managedObjectContext deleteObject:object];
}

- (void)deleteAllObjectsFromGarage {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kGSEntityName];
    NSArray *allObjects = [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    for (NSManagedObject *object in allObjects) {
        [self.coreDataStack.managedObjectContext deleteObject:object];
    }
}

- (void)saveGarage {
    [self.coreDataStack saveContext];
}

#pragma mark - Helper Methods

- (GSCoreDataObject *)fetchObjectWithType:(NSString *)type identifier:(NSString *)identifier {
    NSArray *objects = [self fetchObjectsWithType:type identifier:identifier];
    if (objects.count > 0) {
        return objects[0];
    }
    return nil;
}

- (NSArray *)fetchObjectsWithType:(NSString *)type identifier:(NSString *)identifier {
    
    NSString *predicateString = [NSString stringWithFormat:@"%@ = \"%@\"", kGSTypeKey, type];
    if (identifier) {
        predicateString = [predicateString stringByAppendingString:[NSString stringWithFormat:@" && %@ = \"%@\"", kGSIdentifierKey, identifier]];
    }
    
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:predicateString];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kGSEntityName];
    fetchRequest.predicate = fetchPredicate;
    
    NSArray *fetchedObjects = [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return fetchedObjects;
}

#pragma mark - GSManagedObjectDatasource

- (GSCoreDataObject *)newGSCoreDataObjectForObject:(id<GSMappableObject>)object {
    
    return [self gsCoreDataObjectForObject:object createIfNeeded:YES];
}

- (GSCoreDataObject *)fetchGSCoreDataObjectForObject:(id<GSMappableObject>)object {
    
    return [self gsCoreDataObjectForObject:object createIfNeeded:NO];
}

- (GSCoreDataObject *)gsCoreDataObjectForObject:(id<GSMappableObject>)object createIfNeeded:(BOOL)createIfNeeded {
    
    id nakedObject = object;
    GSObjectMapping *mapping = [[object class] objectMapping];
    NSString *type = mapping.classNameForMapping;
    NSString *identifier = [nakedObject valueForKey:mapping.identifyingAttribute];
    
    GSCoreDataObject *coreDataObject = [self fetchObjectWithType:type identifier:identifier];
    
    if (coreDataObject || !createIfNeeded) {
        return coreDataObject;
    }
    
    coreDataObject = [NSEntityDescription insertNewObjectForEntityForName:kGSEntityName inManagedObjectContext:self.coreDataStack.managedObjectContext];
    coreDataObject.gs_type = type;
    coreDataObject.gs_identifier = identifier;
    coreDataObject.gs_creationDate = [NSDate date];
    
    return coreDataObject;
}

- (GSCoreDataObject *)fetchGSCoreDataObjectForPromise:(NSDictionary *)promise {
   
    return [self fetchObjectWithType:promise[kGSTypeKey] identifier:promise[kGSIdentifierKey]];
}

@end
