//
//  GSObjectMapping.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GSObjectMapping;

@protocol GSMappableObject <NSObject>

+ (GSObjectMapping *)objectMapping;

@end

@interface GSObjectMapping : NSObject

@property (nonatomic, readonly) NSString *classNameForMapping;
@property (nonatomic, readonly) NSString *identifyingAttribute;

@property (nonatomic, readonly) NSMutableDictionary *directKeyMappings;
@property (nonatomic, readonly) NSMutableDictionary *relationshipMappings;


- (instancetype)initWithClass:(Class)mappableClass;

- (void)setIdentifyingAttribute:(NSString *)identifyingAttribute;
- (void)addMappingsFromArray:(NSArray *)array;
- (void)addMappingsFromDictionary:(NSDictionary *)dictionary;
- (void)addRelationshipMappingFromKeypath:(NSString *)fromKeypath toKeypath:(NSString *)toKeypath withMapping:(GSObjectMapping *)mapping;

@end
