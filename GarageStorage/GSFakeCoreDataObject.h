//
//  GSFakeCoreDataObject.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSFakeCoreDataObject : NSObject

@property (nonatomic, strong) NSString *gs_Identifier;
@property (nonatomic, strong) NSString *gs_Type;
@property (nonatomic, strong) NSNumber *gs_Version;
@property (nonatomic, strong) NSString *gs_Data;

@end
