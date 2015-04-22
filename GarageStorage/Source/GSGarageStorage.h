//
//  GSGarageStorage.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/22/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#ifndef GarageStorage_GSGarageStorage_h
#define GarageStorage_GSGarageStorage_h

extern NSString *const kGSTypeKey;
extern NSString *const kGSIdentifierKey;

#import "GSObjectMapping.h"

@protocol GSMappableObject <NSObject>

+ (GSObjectMapping *)objectMapping;

@end

#import "GSGarage.h"

#endif
