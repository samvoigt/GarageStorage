//
//  GSObjectMapper.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSObjectMapping.h"
#import "GSCoreDataObject.h"

@class GSFakeCoreDataObject;

@interface GSObjectMapper : NSObject

- (void)registerMapping:(GSObjectMapping *)mapping;

- (id<GSMappableObject>)objectFromGSCoreDataObject:(GSCoreDataObject *)gsCoreDataObject;
- (NSArray *)gsCoreDataObjectsFromObject:(id<GSMappableObject>)object;

@end
