//
//  GSFakeMappableObject.m
//  GarageStorage
//
//  Created by Sam Voigt on 4/21/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "GSFakeMappableObject.h"

@implementation GSFakeMappableObject

+ (GSObjectMapping *)objectMapping {
    GSObjectMapping *mapping = [[GSObjectMapping alloc] initWithClass:[self class]];
    
    [mapping addMappingsFromArray:@[@"name", @"state", @"age", @"siblings", @"brother"]];
    [mapping setIdentifyingAttribute:@"name"];
    
    return mapping;
}

+ (GSFakeMappableObject *)mockObject {
    GSFakeMappableObject *obj = [GSFakeMappableObject new];
    
    obj.name = @"Sam";
    obj.state = @"MA";
    
    obj.age = 31;
    
    obj.siblings = @[[GSFakeMappableObject mockObject2], [GSFakeMappableObject mockObject3], @35, @"yo dawg"];
    
    obj.brother = [GSFakeMappableObject mockObject2];
    
    return obj;
}

+ (GSFakeMappableObject *)mockObject2 {
    GSFakeMappableObject *obj = [GSFakeMappableObject new];
    
    obj.name = @"Nick";
    obj.state = @"CT";
    
    obj.age = 26;
    
    return obj;
}

+ (GSFakeMappableObject *)mockObject3 {
    GSFakeMappableObject *obj = [GSFakeMappableObject new];
    
    obj.name = @"Emily";
    obj.state = @"VT";
    
    obj.age = 24;
    
    return obj;
}

@end
