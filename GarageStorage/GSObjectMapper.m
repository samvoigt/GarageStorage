//
//  GSObjectMapper.m
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "GSObjectMapper.h"
#import "GSFakeCoreDataObject.h"
#import "objc/runtime.h"

static NSString *const kGSIdentifierKey = @"kGSIdentifierKey";
static NSString *const kGSTypeKey = @"kGSTypeKey";

@interface GSObjectMapper ()

@property (nonatomic, strong) NSMutableDictionary *objectMappings;

@property (nonatomic, strong) NSMutableArray *gsCoreDataObjects;

@property (nonatomic, strong) NSMutableArray *fakeCoreDataStore;

@end

@implementation GSObjectMapper

- (instancetype)init {
    self = [super init];
    if (self) {
        self.objectMappings = [NSMutableDictionary new];
        self.fakeCoreDataStore = [NSMutableArray new];
    }
    return self;
}

#pragma mark - To Core Data Objects

- (NSArray *)gsCoreDataObjectsFromObject:(id<GSMappableObject>)object {
   
    // We're using gsCoreDataObjects as a running store, since our calls can be recursive and we need to keep track of the objects we've created for a given mapping.
    self.gsCoreDataObjects = [NSMutableArray new];
    
    GSFakeCoreDataObject *topLevelObject = [self gsCoreDataObjectFromObject:object];
    
    [self.gsCoreDataObjects insertObject:topLevelObject atIndex:0];
    
    return self.gsCoreDataObjects;
    
}

- (GSFakeCoreDataObject *)gsCoreDataObjectFromObject:(id<GSMappableObject>)object {
    
    id nakedObject = object;
    GSObjectMapping *mapping = [[object class] objectMapping];
    
    NSDictionary *JSONDictionary = [self jsonDictionaryFromObject:object];
    
    GSFakeCoreDataObject *coreDataObject = [GSFakeCoreDataObject new];
    coreDataObject.gs_Data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSONDictionary options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    coreDataObject.gs_Type = mapping.classNameForMapping;
    coreDataObject.gs_Identifier = [nakedObject valueForKey:mapping.identifyingAttribute];

    return coreDataObject;
}


- (NSDictionary *)jsonDictionaryFromObject:(id<GSMappableObject>)object {
    
    // If a protocol is specified on an object of type id, that object then will ONLY respond to methods specified by that protocol, and not, say, KVC methods.
    id nakedObject = object;
    
    NSMutableDictionary *JSONDictionary = [NSMutableDictionary new];
    
    GSObjectMapping *mapping = [[object class] objectMapping];
    
    for (NSString *propertyName in [mapping.directKeyMappings allKeys]) {
        id obj = [nakedObject valueForKey:propertyName];
        
        if ([obj isKindOfClass:[NSArray class]]) {
            [JSONDictionary setValue:[self jsonArrayFromArray:obj] forKey:propertyName];
        }
        else if ([obj conformsToProtocol:@protocol(GSMappableObject)]) {
            [JSONDictionary setObject:[self JSONPromiseForGSMappableObject:obj] forKey:propertyName];
        }
        else if (obj) {
            [JSONDictionary setObject:obj forKey:propertyName];
        }
    }

    return JSONDictionary;
}

- (NSArray *)jsonArrayFromArray:(NSArray *)array {
    
    NSMutableArray *jsonArray = [NSMutableArray new];
    
    for (id object in array) {
        if ([object conformsToProtocol:@protocol(GSMappableObject)]) {
            [jsonArray addObject:[self JSONPromiseForGSMappableObject:object]];
        }
        else if ([object isKindOfClass:[NSArray class]]) {
            [jsonArray addObject:[self jsonArrayFromArray:object]];
        }
        else {
            [jsonArray addObject:object];
        }
    }
    
    return jsonArray;
}

- (NSDictionary *)JSONPromiseForGSMappableObject:(id<GSMappableObject>)object {
    // WARNING: Side effect - we emit a GSCoreDataObject here that fulfills this promise.
    GSFakeCoreDataObject *coreDataObject = [self gsCoreDataObjectFromObject:object];
    [self.gsCoreDataObjects addObject:coreDataObject];
    
    return @{kGSIdentifierKey : coreDataObject.gs_Identifier,
             kGSTypeKey : coreDataObject.gs_Type};
}


#pragma mark - From Core Data Objects

- (id<GSMappableObject>)objectFromGSCoreDataObject:(GSFakeCoreDataObject *)gsCoreDataObject {
    
    NSString *className = gsCoreDataObject.gs_Type;
    NSData *jsonData = [gsCoreDataObject.gs_Data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    
    id gsObject = [NSClassFromString(className) new];
    
    GSObjectMapping *mapping = [NSClassFromString(className) objectMapping];
    
    for (NSString *keyPath in mapping.directKeyMappings) {
        id jsonObject = jsonDictionary[keyPath];
        if ([jsonObject isKindOfClass:[NSDictionary class]] && (NSDictionary *)jsonObject[kGSIdentifierKey]) {
            GSFakeCoreDataObject *promisedObject = [self gsCoreDataObjectFromPromise:jsonObject];
            [gsObject setValue:[self objectFromGSCoreDataObject:promisedObject] forKey:keyPath];
        }
        else if ([jsonObject isKindOfClass:[NSArray class]]) {
            [gsObject setValue:[self gsObjectsArrayFromArray:jsonObject] forKey:keyPath];
        }
        else if (jsonObject) {
            [gsObject setValue:jsonObject forKey:keyPath];
        }
    }
    
    return gsObject;
}

- (NSArray *)gsObjectsArrayFromArray:(NSArray *)array {
    
    NSMutableArray *objectsArray = [NSMutableArray new];
    
    for (id object in array) {
        if ([object isKindOfClass:[NSDictionary class]] && (NSDictionary *)object[kGSIdentifierKey]) {
            GSFakeCoreDataObject *promisedObject = [self gsCoreDataObjectFromPromise:object];
            [objectsArray addObject:[self objectFromGSCoreDataObject:promisedObject]];
        }
        else if ([object isKindOfClass:[NSArray class]]) {
            [objectsArray addObject:[self gsObjectsArrayFromArray:object]];
        }
        else {
            [objectsArray addObject:object];
        }
    }
    
    return objectsArray;
}

- (GSFakeCoreDataObject *)gsCoreDataObjectFromPromise:(NSDictionary *)promise {
    NSPredicate *promisePredicate = [NSPredicate predicateWithFormat:@"gs_Type = %@ && gs_Identifier = %@", promise[kGSTypeKey], promise[kGSIdentifierKey]];
    
    NSArray *matchingObject = [self.fakeCoreDataStore filteredArrayUsingPredicate:promisePredicate];
    
    if (matchingObject.count > 0) {
        return matchingObject[0];
    }
    return nil;
}

- (void)saveObjectsToCoreData:(NSArray *)objects {
    [self.fakeCoreDataStore addObjectsFromArray:objects];
}

@end
