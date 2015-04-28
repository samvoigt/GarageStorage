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
static NSString *const kGSUnidentifiedObject = @"kGSUnidentifiedObject";

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
    }
    return self;
}

+ (NSManagedObjectModel *)garageModel {
    
    return [GSCoreDataStack garageModel];
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

- (BOOL)updateIdentifierForObject:(id<GSMappableObject>)object {
    
    BOOL didUpdateIdentifier = NO;
    
    GSObjectMapping *mapping = [[object class] objectMapping];
    NSString *type = mapping.classNameForMapping;
    NSDictionary *jsonDictionaryForObject = [self.objectMapper jsonDictionaryFromObject:object];
    
    NSString *predicateString = [NSString stringWithFormat:@"%@ = \"%@\" && %@ = \"%@\"", kGSTypeKey, type, kGSIdentifierKey, kGSUnidentifiedObject];
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:predicateString];

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kGSEntityName];
    fetchRequest.predicate = fetchPredicate;
    
    NSArray *unidentifiedObjectsOfClass = [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    id nakedObject = object;
    for (GSCoreDataObject *coreDataObject in unidentifiedObjectsOfClass) {
        if ([coreDataObject.gs_version isEqualToNumber:@(mapping.version)]) {
            
            NSDictionary *storedJSON = [self.objectMapper jsonDictionaryFromString:coreDataObject.gs_data];
            if ([self jsonDictionary:storedJSON triviallyMatchesJSONDictionary:jsonDictionaryForObject]) {
               
                coreDataObject.gs_identifier = [nakedObject valueForKey:mapping.identifyingAttribute];
                coreDataObject.gs_data = [self.objectMapper jsonStringFromDictionary:jsonDictionaryForObject];
                didUpdateIdentifier = YES;
                break;
            }
        }
    }
    
    return didUpdateIdentifier;
}

// This only checks to make sure that all the keys in aJSONDictionary are in bJSONDictionary, and that the string and number values are the same. It ignores any more complicated objects (arrays, dicts, custom objects, whatever else).
- (BOOL)jsonDictionary:(NSDictionary *)aJSONDictionary triviallyMatchesJSONDictionary:(NSDictionary *)bJSONDictionary {
    
    for (NSString *key in aJSONDictionary.allKeys) {
        if (bJSONDictionary[key]) {
            id aObject = aJSONDictionary[key];
            id bObject = bJSONDictionary[key];
           
            if ([aObject isKindOfClass:[NSString class]]) {
                if ([bObject isKindOfClass:[NSString class]]) {
                    if (![aObject isEqualToString:bObject]) {
                        return NO;
                    }
                }
                else {
                    return NO;
                }
            }
            else if ([aObject isKindOfClass:[NSNumber class]]) {
                if ([bObject isKindOfClass:[NSNumber class]]) {
                    if (![aObject isEqualToNumber:bObject]) {
                        return NO;
                    }
                }
                else {
                    return NO;
                }
            }
        }
        else {
            return NO;
        }
    }
    
    return YES;
}

- (void)deleteObjectFromGarage:(id<GSMappableObject>)object {
   
    GSCoreDataObject *coreDataObject = [self fetchGSCoreDataObjectForObject:object];
    [self.coreDataStack.managedObjectContext deleteObject:coreDataObject];
}

- (void)deleteAllObjectsFromGarageOfClass:(Class)cls {
    
    NSArray *allObjectsOfClass = [self fetchObjectsWithType:NSStringFromClass(cls) identifier:nil];
    [self deleteObjects:allObjectsOfClass];
}

- (void)deleteAllObjectsFromGarage {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kGSEntityName];
    NSArray *allObjects = [self.coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    [self deleteObjects:allObjects];
}

- (void)deleteObjects:(NSArray *)objects {
    
    for (NSManagedObject *object in objects) {
        [self.coreDataStack.managedObjectContext deleteObject:object];
    }
}

- (void)saveGarage {
    [self.coreDataStack saveContext];
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
    NSString *identifier = [nakedObject valueForKey:mapping.identifyingAttribute];
    
    GSCoreDataObject *coreDataObject = [self fetchObjectWithType:type identifier:identifier];
    
    if (coreDataObject || !createIfNeeded) {
        return coreDataObject;
    }
    else {
        coreDataObject = [NSEntityDescription insertNewObjectForEntityForName:kGSEntityName inManagedObjectContext:self.coreDataStack.managedObjectContext];
        coreDataObject.gs_type = type;
        coreDataObject.gs_identifier = (identifier != nil && ![identifier isEqualToString:@""]) ? identifier : kGSUnidentifiedObject;
        coreDataObject.gs_creationDate = [NSDate date];
        coreDataObject.gs_version = @(mapping.version);
        
        return coreDataObject;
    }
}

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

@end
