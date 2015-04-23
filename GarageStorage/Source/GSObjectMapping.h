//
//  GSObjectMapping.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSObjectMapping : NSObject

@property (nonatomic, readonly) NSString *classNameForMapping;
@property (nonatomic, strong) NSString *identifyingAttribute;
@property (nonatomic) NSInteger version;

@property (nonatomic, readonly) NSMutableDictionary *mappings;

/**
 *  Returns a mapping for a given class. This is the preferred way to get a "blank" mapping.
 *
 *  @param cls A mappable class
 *
 *  @return A GSObjectMapping
 */
+ (instancetype)mappingForClass:(Class)cls;

/**
 *  Initializes a mapping with a given class
 *
 *  @param cls A mappable class
 *
 *  @return A GSObjectMapping
 */
- (instancetype)initWithClass:(Class)cls;

/**
 *  Adds mappings from an array. The mappings are the names of the properties you wish to map on the object. When in doubt, map using this method.
 *
 *  @param array An array of NSStrings.
 */
- (void)addMappingsFromArray:(NSArray *)array;

/**
 *  Adds mappings from a dictionary. The keys in the dictionary are the names of the properties you wish to map on your object. The values are the JSON keys in the underlying GSCoreDataObject they map to.
 *
 *  @param dictionary A dictionary of mappings
 */
- (void)addMappingsFromDictionary:(NSDictionary *)dictionary;

@end
