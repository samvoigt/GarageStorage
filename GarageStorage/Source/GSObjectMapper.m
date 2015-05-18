//
//  GSObjectMapper.m
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "GSObjectMapper.h"
#import "NSDate+GarageStorage.h"

static NSString *const kGSTransformableTypeKey = @"gs_transformableType";
static NSString *const kGSTransformableDataKey = @"gs_transformableData";
static NSString *const kGSTransformableDateKey = @"gs_transformableDate";

@implementation GSObjectMapper

#pragma mark - To Core Data Objects

- (void)mapGSMappableObjectToGSCoreDataObject:(id<GSMappableObject>)object {
    
    GSCoreDataObject *coreDataObject = [self.delegate newGSCoreDataObjectForObject:object];
    if (coreDataObject) {
        coreDataObject.gs_data = [self jsonStringFromObject:object];
        coreDataObject.gs_modifiedDate = [NSDate date];
    }
    else {
        NSLog(@"Could not park object in Garage: %@", object);
    }
}

- (NSString *)jsonStringFromObject:(id<GSMappableObject>)object {

    NSDictionary *jsonDictionary = [self jsonDictionaryFromObject:object];
    return [self jsonStringFromDictionary:jsonDictionary];
}

- (NSString *)jsonStringFromDictionary:(NSDictionary *)jsonDictionary {
    
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)jsonDictionaryFromObject:(id<GSMappableObject>)object {
    
    // If a protocol is specified on an object of type id, that object then will ONLY respond to methods specified by that protocol, and not, say, KVC methods.
    id nakedObject = object;
    
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary new];
    
    GSObjectMapping *mapping = [[object class] objectMapping];
    
    for (NSString *propertyName in [mapping.mappings allKeys]) {
        NSString *jsonKey = mapping.mappings[propertyName];
        id obj = [nakedObject valueForKey:propertyName];
        
        if ([obj isKindOfClass:[NSArray class]]) {
            [jsonDictionary setValue:[self jsonArrayFromArray:obj] forKey:jsonKey];
        }
        else if ([obj conformsToProtocol:@protocol(GSMappableObject)]) {
            NSDictionary *promise = [self jsonPromiseForGSMappableObject:obj];
            if (promise) {
                [jsonDictionary setObject:promise forKey:jsonKey];
            }
        }
        else if ([obj isKindOfClass:[NSDate class]]) {
            [jsonDictionary setValue:[self jsonForTransformableObject:obj] forKey:jsonKey];
        }
        else if (obj) {
            [jsonDictionary setObject:obj forKey:jsonKey];
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
        else if ([object isKindOfClass:[NSDate class]]) {
            [jsonArray addObject:[self jsonForTransformableObject:object]];
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

- (NSDictionary *)jsonForTransformableObject:(id)object {
    
    NSDictionary *transformableJSON;
    if ([object isKindOfClass:[NSDate class]]) {
        NSString *dateString = [object gs_stringFromDate];
        transformableJSON = @{kGSTypeKey : kGSTransformableTypeKey,
                              kGSTransformableTypeKey : kGSTransformableDateKey,
                              kGSTransformableDataKey : dateString};
    }
    return transformableJSON;
}

- (id)objectForTransformableData:(NSDictionary *)transformableData {
    
    if ([transformableData[kGSTransformableTypeKey] isEqualToString:kGSTransformableDateKey]) {
        return [NSDate gs_dateForString:transformableData[kGSTransformableDataKey]];
    }
    return nil;
}

#pragma mark - From Core Data Objects

- (id<GSMappableObject>)mapGSCoreDataObjectToGSMappableObject:(GSCoreDataObject *)gsCoreDataObject {
    
    NSString *className = gsCoreDataObject.gs_type;
    NSDictionary *jsonDictionary = [self jsonDictionaryFromString:gsCoreDataObject.gs_data];
    
    id gsObject = [NSClassFromString(className) new];
    
    GSObjectMapping *mapping = [NSClassFromString(className) objectMapping];
    
    for (NSString *keyPath in mapping.mappings) {
        NSString *jsonKey = mapping.mappings[keyPath];
        id jsonObject = jsonDictionary[jsonKey];
        if ([jsonObject isKindOfClass:[NSDictionary class]] && (NSDictionary *)jsonObject[kGSIdentifierKey]) {
            GSCoreDataObject *promisedObject = [self.delegate fetchGSCoreDataObjectForPromise:jsonObject];
            [gsObject setValue:[self mapGSCoreDataObjectToGSMappableObject:promisedObject] forKey:keyPath];
        }
        else if ([jsonObject isKindOfClass:[NSArray class]]) {
            [gsObject setValue:[self gsObjectsArrayFromArray:jsonObject] forKey:keyPath];
        }
        else if ([jsonObject isKindOfClass:[NSDictionary class]] && [jsonObject[kGSTypeKey] isEqualToString:kGSTransformableTypeKey]) {
            [gsObject setValue:[self objectForTransformableData:jsonObject] forKey:keyPath];
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
        else if ([object isKindOfClass:[NSDictionary class]] && [object[kGSTypeKey] isEqualToString:kGSTransformableTypeKey]) {
            [objectsArray addObject:[self objectForTransformableData:object]];
        }
        else {
            [objectsArray addObject:object];
        }
    }
    return objectsArray;
}

- (NSDictionary *)jsonDictionaryFromString:(NSString *)jsonString {
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
}

@end
