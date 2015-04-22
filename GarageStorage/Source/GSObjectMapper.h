//
//  GSObjectMapper.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSGarageStorage.h"
#import "GSCoreDataObject.h"

@class GSObjectMapper;

@protocol GSObjectMapperDataSource <NSObject>

//- (GSCoreDataObject *)gsCoreDataObjectForObject:(id<GSMappableObject>)object;
//- (GSCoreDataObject *)gsCoreDataObjectForPromise:(NSDictionary *)promise;
//- (GSCoreDataObject *)gsCoreDataObjectForType:(NSString *)type identifier:(NSString *)identifier;

/**
 *  Returns a GSCoreDataObject entity.
 *
 *  @param object A GSMappableObject
 *
 *  @return A GSCoreDataObject entity. This is an existing entity if it matches the GSMappableObject, otherwise it will be a new entity. Guaranteed not to be nil.
 */
- (GSCoreDataObject *)newGSCoreDataObjectForObject:(id<GSMappableObject>)object;

/**
 *  Fetches a GSCoreDataObject entity.
 *
 *  @param object A GSMappableObject
 *
 *  @return A GSCoreDataObject entity matching the GSMappableObject. Can be nil if a matching entity has not been created yet.
 */
- (GSCoreDataObject *)fetchGSCoreDataObjectForObject:(id<GSMappableObject>)object;

/**
 *  Fetches a GSCoreDataObject fulfilling the promise.
 *
 *  @param promise An NSDictionary specifying a promised object.
 *
 *  @return The promsised object. Can be nil if the promised object does not exist in the Garage.
 */
- (GSCoreDataObject *)fetchGSCoreDataObjectForPromise:(NSDictionary *)promise;

@end

@interface GSObjectMapper : NSObject

/**
 *  Creates a GSMappableObject from a GSCoreDataObject
 *
 *  @param gsCoreDataObject A GSCoreDataObject currently in the MOC.
 *
 *  @return A GSMappableObject
 */
- (id<GSMappableObject>)mapGSCoreDataObjectToGSMappableObject:(GSCoreDataObject *)gsCoreDataObject;

/**
 *  Maps a GSMappableObject into an entity, which is provided by the delegate. Although there is no return object, the GSCoreDataObject returned by the delegate should be in a MOC.
 *
 *  @param object A GSMappableObject to store in the Garage.
 */
- (void)mapGSMappableObjectToGSCoreDataObject:(id<GSMappableObject>)object;

@property (weak, nonatomic) id<GSObjectMapperDataSource> delegate;

@end
