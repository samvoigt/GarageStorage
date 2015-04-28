//
//  GSObjectMapper.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSMappableObject.h"
#import "GSObjectMapping.h"
#import "GSCoreDataObject.h"

extern NSString *const kGSTypeKey;
extern NSString *const kGSIdentifierKey;

@class GSObjectMapper;

@protocol GSObjectMapperDataSource <NSObject>

- (GSCoreDataObject *)newGSCoreDataObjectForObject:(id<GSMappableObject>)object;
- (GSCoreDataObject *)fetchGSCoreDataObjectForObject:(id<GSMappableObject>)object;
- (GSCoreDataObject *)fetchGSCoreDataObjectForPromise:(NSDictionary *)promise;

@end

@interface GSObjectMapper : NSObject

- (id<GSMappableObject>)mapGSCoreDataObjectToGSMappableObject:(GSCoreDataObject *)gsCoreDataObject;
- (void)mapGSMappableObjectToGSCoreDataObject:(id<GSMappableObject>)object;

- (NSDictionary *)jsonDictionaryFromObject:(id<GSMappableObject>)object;
- (NSDictionary *)jsonDictionaryFromString:(NSString *)jsonString;
- (NSString *)jsonStringFromDictionary:(NSDictionary *)jsonDictionary;


@property (weak, nonatomic) id<GSObjectMapperDataSource> delegate;

@end
