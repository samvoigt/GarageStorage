//
//  NSDate+GarageStorage.m
//  GarageStorage
//
//  Created by Samuel Voigt on 5/18/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "NSDate+GarageStorage.h"

@implementation NSDate (GarageStorage)

+ (NSDateFormatter *)gs_isoFormatter {
    
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    });
    return dateFormatter;
}

+ (NSDate *)gs_dateForString:(NSString *)string {
    
    return [[NSDate gs_isoFormatter] dateFromString:string];
}

- (NSString *)gs_stringFromDate {
    
    return [[NSDate gs_isoFormatter] stringFromDate:self];
}

@end
