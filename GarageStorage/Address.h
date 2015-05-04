//
//  Address.h
//  GarageStorage
//
//  Created by Sam Voigt on 5/4/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GarageStorage.h"

@interface Address : NSObject <GSMappableObject>

@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *zip;

+ (Address *)mockAddress;

@end
