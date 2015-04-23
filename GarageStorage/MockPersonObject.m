//
//  MockPersonObject.m
//  GarageStorage
//
//  Created by Sam Voigt on 4/21/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "MockPersonObject.h"

@implementation MockPersonObject

+ (GSObjectMapping *)objectMapping {
    GSObjectMapping *mapping = [GSObjectMapping mappingForClass:[self class]];
    
    [mapping addMappingsFromArray:@[@"name", @"state", @"age", @"siblings", @"brother"]];
    [mapping setIdentifyingAttribute:@"name"];
    
    return mapping;
}

+ (MockPersonObject *)mockObject {
    MockPersonObject *obj = [MockPersonObject new];
    
    obj.name = @"Sam";
    obj.state = @"MA";
    
    obj.age = 31;
    
    obj.siblings = @[[MockPersonObject mockObject2], [MockPersonObject mockObject3]];
    
    obj.brother = [MockPersonObject mockObject2];
    
    return obj;
}

+ (MockPersonObject *)mockObject2 {
    MockPersonObject *obj = [MockPersonObject new];
    
    obj.name = @"Nick";
    obj.state = @"CT";
    
    obj.age = 26;
    
    return obj;
}

+ (MockPersonObject *)mockObject3 {
    MockPersonObject *obj = [MockPersonObject new];
    
    obj.name = @"Emily";
    obj.state = @"VT";
    
    obj.age = 24;
    
    return obj;
}

@end
