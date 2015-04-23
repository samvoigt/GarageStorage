//
//  GSMappableObject.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/23/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#ifndef GarageStorage_GSMappableObject_h
#define GarageStorage_GSMappableObject_h

@class GSObjectMapping;

@protocol GSMappableObject <NSObject>

+ (GSObjectMapping *)objectMapping;

@end

#endif
