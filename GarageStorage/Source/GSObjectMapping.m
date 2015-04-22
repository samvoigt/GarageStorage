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

@property (strong, nonatomic, readwrite) NSMutableDictionary *directKeyMappings;
@property (strong, nonatomic, readwrite) NSMutableDictionary *relationshipMappings;

@end

@implementation GSObjectMapping

- (instancetype)initWithClass:(Class)mappableClass {
    self = [super init];
    if (self) {
        self.classNameForMapping = NSStringFromClass(mappableClass);
        self.directKeyMappings = [NSMutableDictionary new];
        self.relationshipMappings = [NSMutableDictionary new];
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
    [self.directKeyMappings addEntriesFromDictionary:dictionary];
}

- (void)addRelationshipMappingFromKeypath:(NSString *)fromKeypath toKeypath:(NSString *)toKeypath withMapping:(GSObjectMapping *)mapping {
    [self.relationshipMappings addEntriesFromDictionary:@{fromKeypath :
                                                              @{kDestinationKeyPathKey : toKeypath,
                                                                kMappingKey : mapping}
                                                          }];
    
}

-(void)setIdentifyingAttribute:(NSString *)identifyingAttribute {
    if (self.directKeyMappings[identifyingAttribute] != nil) {
        _identifyingAttribute = identifyingAttribute;
    }
    else {
        NSLog(@"Identifing Attribute not listed as mapped attribute. Please set identifying attribute after setting up the rest of your mappings.");
    }
}

@end
