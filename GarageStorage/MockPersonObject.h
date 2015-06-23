//
//  MockPersonObject.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/21/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GarageStorage.h"
#import "Address.h"


@interface MockPersonObject : NSObject <GSMappableObject, GSSyncableObject>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Address *address;

@property (nonatomic) NSInteger age;
@property (nonatomic, strong) NSDate *birthdate;
@property (nonatomic, strong) NSArray *importantDates;

@property (nonatomic, strong) NSArray *siblings;
@property (nonatomic, strong) MockPersonObject *brother;

@property (nonatomic) GSSyncStatus syncStatus;

+ (MockPersonObject *)mockObject;

@end
