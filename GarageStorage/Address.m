//
//  Address.m
//  GarageStorage
//
//  Created by Sam Voigt on 5/4/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "Address.h"

@implementation Address

+ (GSObjectMapping *)objectMapping {
    
    GSObjectMapping *mapping = [GSObjectMapping mappingForClass:[self class]];
    
    [mapping addMappingsFromArray:@[@"street", @"city", @"zip"]];
        
    return mapping;
}

+ (Address *)mockAddress {
    
    Address *address = [Address new];
    address.street = @"330 Congress St.";
    address.city = @"Boston";
    address.zip = @"02140";

    return address;
}

@end
