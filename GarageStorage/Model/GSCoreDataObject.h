//
//  GSCoreDataObject.h
//  GarageStorage
//
//  Created by Sam Voigt on 4/22/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GSCoreDataObject : NSManagedObject

@property (nonatomic, retain) NSDate * gs_creationDate;
@property (nonatomic, retain) NSString * gs_data;
@property (nonatomic, retain) NSString * gs_identifier;
@property (nonatomic, retain) NSDate * gs_modifiedDate;
@property (nonatomic, retain) NSString * gs_type;
@property (nonatomic, retain) NSNumber * gs_version;

@end
