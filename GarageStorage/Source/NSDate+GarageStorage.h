//
//  NSDate+GarageStorage.h
//  GarageStorage
//
//  Created by Samuel Voigt on 5/18/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (GarageStorage)

+ (NSDateFormatter *)gs_isoFormatter;
+ (NSDate *)gs_dateForString:(NSString *)string;
- (NSString *)gs_stringFromDate;

@end
