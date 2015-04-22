//
//  GSMockMappableObject.m
//  GarageStorage
//
//  Created by Sam Voigt on 4/21/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "GSMockMappableObject.h"

@implementation GSMockMappableObject

+ (GSObjectMapping *)objectMapping {
    GSObjectMapping *mapping = [[GSObjectMapping alloc] initWithClass:[self class]];
    
    [mapping addMappingsFromArray:@[@"name", @"state", @"age", @"siblings", @"brother"]];
    [mapping setIdentifyingAttribute:@"name"];
    
    return mapping;
}

+ (GSMockMappableObject *)mockObject {
    GSMockMappableObject *obj = [GSMockMappableObject new];
    
    obj.name = @"Sam";
    obj.state = @"MA";
    
    obj.age = 31;
    
    obj.siblings = @[[GSMockMappableObject mockObject2], [GSMockMappableObject mockObject3], @35, @"yo dawg"];
    
    obj.brother = [GSMockMappableObject mockObject2];
    
    return obj;
}

+ (GSMockMappableObject *)mockObject2 {
    GSMockMappableObject *obj = [GSMockMappableObject new];
    
    obj.name = @"Nick";
    obj.state = @"CT";
    
    obj.age = 26;
    
    return obj;
}

+ (GSMockMappableObject *)mockObject3 {
    GSMockMappableObject *obj = [GSMockMappableObject new];
    
    obj.name = @"Emily";
    obj.state = @"VT";
    
    obj.age = 24;
    
    return obj;
}

@end
