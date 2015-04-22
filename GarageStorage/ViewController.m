//
//  ViewController.m
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "ViewController.h"
#import "GSGarageStorage.h"


#import "GSMockMappableObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    GSMockMappableObject *sam = [GSMockMappableObject mockObject];
    
    GSGarage *garage = [[GSGarage alloc] init];
   
   // [garage deleteAllObjectsFromGarage];
    
   // [garage saveGarage];
    
    [garage parkObjectInGarage:sam];
    
   // [garage saveGarage];
    
    sam = nil;
    
    sam = [garage retrieveObjectOfClass:[GSMockMappableObject class] identifier:@"Sam"];
    
    
    NSLog(@"Sam: %@", sam);
    //NSArray *array = [mapper gsCoreDataObjectsFromObject:sam];
    
    //[mapper saveObjectsToCoreData:array];
    
    //GSFakeCoreDataObject *obj = array[0];
    
//    NSLog(@"\nid: %@\ntype: %@\ndata: %@", obj.gs_identifier, obj.gs_type, obj.gs_data);
//    NSLog(@"Pull it out of the store");
//    
//    GSMockMappableObject *fakeSamuel = [mapper objectFromGSCoreDataObject:obj];
//    
//    NSLog(@"GS object: %@", fakeSamuel);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
