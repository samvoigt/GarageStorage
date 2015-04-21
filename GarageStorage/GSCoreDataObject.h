//
//  GSCoreDataObject.h
//  
//
//  Created by Sam Voigt on 4/20/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GSCoreDataObject : NSManagedObject

@property (nonatomic, retain) NSString * gs_Identifier;
@property (nonatomic, retain) NSString * gs_type;
@property (nonatomic, retain) NSNumber * gs_version;
@property (nonatomic, retain) NSString * gs_data;

@end
