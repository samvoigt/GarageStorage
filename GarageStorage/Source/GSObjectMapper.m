//
//  GSObjectMapper.m
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "GSObjectMapper.h"
#import "objc/runtime.h"

@implementation GSObjectMapper

#pragma mark - To Core Data Objects

//- (GSCoreDataObject *)gsCoreDataObjectFromObject:(id<GSMappableObject>)object {
//    
//    NSDictionary *JSONDictionary = [self jsonDictionaryFromObject:object];
//    
//    GSCoreDataObject *coreDataObject = [self.delegate gsCoreDataObjectForObject:object];
//    coreDataObject.gs_data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSONDictionary options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
//    coreDataObject.gs_modifiedDate = [NSDate date];
//
//    return coreDataObject;
//}

- (void)mapGSMappableObjectToGSCoreDataObject:(id<GSMappableObject>)object {
    
    NSDictionary *jsonDictionary = [self jsonDictionaryFromObject:object];
    
    GSCoreDataObject *coreDataObject = [self.delegate newGSCoreDataObjectForObject:object];
    coreDataObject.gs_data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    coreDataObject.gs_modifiedDate = [NSDate date];
}

- (NSDictionary *)jsonDictionaryFromObject:(id<GSMappableObject>)object {
    
    // If a protocol is specified on an object of type id, that object then will ONLY respond to methods specified by that protocol, and not, say, KVC methods.
    id nakedObject = object;
    
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary new];
    
    GSObjectMapping *mapping = [[object class] objectMapping];
    
    for (NSString *propertyName in [mapping.directKeyMappings allKeys]) {
        id obj = [nakedObject valueForKey:propertyName];
        
        if ([obj isKindOfClass:[NSArray class]]) {
            [jsonDictionary setValue:[self jsonArrayFromArray:obj] forKey:propertyName];
        }
        else if ([obj conformsToProtocol:@protocol(GSMappableObject)]) {
            NSDictionary *promise = [self jsonPromiseForGSMappableObject:obj];
            if (promise) {
                [jsonDictionary setObject:promise forKey:propertyName];
            }
        }
        else if (obj) {
            [jsonDictionary setObject:obj forKey:propertyName];
        }
    }

    return jsonDictionary;
}

- (NSArray *)jsonArrayFromArray:(NSArray *)array {
    
    NSMutableArray *jsonArray = [NSMutableArray new];
    
    for (id object in array) {
        if ([object conformsToProtocol:@protocol(GSMappableObject)]) {
            NSDictionary *promise = [self jsonPromiseForGSMappableObject:object];
            if (promise) {
                [jsonArray addObject:promise];
            }
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

- (NSDictionary *)jsonPromiseForGSMappableObject:(id<GSMappableObject>)object {

    [self mapGSMappableObjectToGSCoreDataObject:object];

    GSCoreDataObject *promisedObject = [self.delegate fetchGSCoreDataObjectForObject:object];
    
    if (promisedObject) {
        return @{kGSIdentifierKey : promisedObject.gs_identifier,
             kGSTypeKey : promisedObject.gs_type};
    }
    else {
        return nil;
    }
}


#pragma mark - From Core Data Objects

- (id<GSMappableObject>)mapGSCoreDataObjectToGSMappableObject:(GSCoreDataObject *)gsCoreDataObject {
    
    NSString *className = gsCoreDataObject.gs_type;
    NSData *jsonData = [gsCoreDataObject.gs_data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    
    id gsObject = [NSClassFromString(className) new];
    
    GSObjectMapping *mapping = [NSClassFromString(className) objectMapping];
    
    for (NSString *keyPath in mapping.directKeyMappings) {
        id jsonObject = jsonDictionary[keyPath];
        if ([jsonObject isKindOfClass:[NSDictionary class]] && (NSDictionary *)jsonObject[kGSIdentifierKey]) {
            GSCoreDataObject *promisedObject = [self.delegate fetchGSCoreDataObjectForPromise:jsonObject];
            [gsObject setValue:[self mapGSCoreDataObjectToGSMappableObject:promisedObject] forKey:keyPath];
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
            GSCoreDataObject *promisedObject = [self.delegate fetchGSCoreDataObjectForPromise:object];
            [objectsArray addObject:[self mapGSCoreDataObjectToGSMappableObject:promisedObject]];
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

@end