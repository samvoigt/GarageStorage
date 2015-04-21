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

@property (nonatomic, strong) NSMutableSet *mappableTypes;
@property (nonatomic, strong) NSMutableSet *mappableRelationships;

@property (nonatomic, strong) NSMutableArray *gsCoreDataObjects;

@end

@implementation GSObjectMapper

- (instancetype)init {
    self = [super init];
    if (self) {
        self.objectMappings = [NSMutableDictionary new];
    }
    return self;
}

- (void)registerMapping:(GSObjectMapping *)mapping {
    
    [self.objectMappings addEntriesFromDictionary:@{mapping.classNameForMapping : mapping}];
    [self.mappableRelationships addObject:mapping.classNameForMapping];
}

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
    coreDataObject.gs_data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSONDictionary options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    coreDataObject.gs_type = mapping.classNameForMapping;
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
        else {
            [JSONDictionary setObject:obj forKey:propertyName];
        }
    }

    return JSONDictionary;
}

- (NSArray *)jsonArrayFromArray:(NSArray *)array {
    
    NSMutableArray *JSONArray = [NSMutableArray new];
    
    for (id object in array) {
        if ([object conformsToProtocol:@protocol(GSMappableObject)]) {
            [JSONArray addObject:[self JSONPromiseForGSMappableObject:object]];
        }
        else if ([object isKindOfClass:[NSArray class]]) {
            [JSONArray addObject:[self jsonArrayFromArray:object]];
        }
        else {
            [JSONArray addObject:object];
        }
    }
    
    return JSONArray;
}

- (NSDictionary *)JSONPromiseForGSMappableObject:(id<GSMappableObject>)object {
    // WARNING: Side effect - we emit a GSCoreDataObject here that fulfills this promise.
    GSFakeCoreDataObject *coreDataObject = [self gsCoreDataObjectFromObject:object];
    [self.gsCoreDataObjects addObject:coreDataObject];
    
    return @{kGSIdentifierKey : coreDataObject.gs_Identifier,
                               kGSTypeKey : coreDataObject.gs_type};
}

- (id<GSMappableObject>)objectFromGSCoreDataObject:(GSCoreDataObject *)gsCoreDataObject {
    return nil;
}


- (NSMutableSet *)mappableRelationships {
    if (!_mappableRelationships) {
        _mappableRelationships = [NSMutableSet new];
    }
    return _mappableRelationships;
}

@end
