//
//  GSObjectMapping.m
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "GSObjectMapping.h"

static NSString *const kDestinationKeyPathKey = @"kDestinationKeyPathKey";
static NSString *const kMappingKey = @"kMappingKey";

@interface GSObjectMapping ()

@property (nonatomic, readwrite) NSString *classNameForMapping;
@property (nonatomic, readwrite) NSString *identifyingAttribute;

@property (strong, nonatomic, readwrite) NSMutableDictionary *mappings;

@end

@implementation GSObjectMapping

+ (instancetype)mappingForClass:(Class)cls {
    return [[GSObjectMapping alloc] initWithClass:cls];
}

- (instancetype)initWithClass:(Class)cls {
    self = [super init];
    if (self) {
        self.classNameForMapping = NSStringFromClass(cls);
        self.mappings = [NSMutableDictionary new];
    }
    return self;
}

- (void)addMappingsFromArray:(NSArray *)array {
    NSMutableDictionary *mappings = [NSMutableDictionary new];
    
    for (NSString *propertyName in array) {
        [mappings setValue:propertyName forKey:propertyName];
    }
    [self addMappingsFromDictionary:mappings];
}

- (void)addMappingsFromDictionary:(NSDictionary *)dictionary {
    [self.mappings addEntriesFromDictionary:dictionary];
}

-(void)setIdentifyingAttribute:(NSString *)identifyingAttribute {
    if (self.mappings[identifyingAttribute] != nil) {
        _identifyingAttribute = identifyingAttribute;
    }
    else {
        NSLog(@"Identifing Attribute not listed as mapped attribute. Please set identifying attribute after setting up the rest of your mappings.");
    }
}

@end
