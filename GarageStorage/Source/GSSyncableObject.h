//
//  GSSyncableObject.h
//  GarageStorage
//
//  Created by Sam Voigt on 6/23/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#ifndef GarageStorage_GSSyncableObject_h
#define GarageStorage_GSSyncableObject_h

typedef NS_ENUM(NSInteger, GSSyncStatus) {
    GSSyncStatusUndetermined,
    GSSyncStatusNotSynced,
    GSSyncStatusSyncing,
    GSSyncStatusSynced
};

@protocol GSSyncableObject <NSObject>

@property (nonatomic) GSSyncStatus syncStatus;

@end

#endif
