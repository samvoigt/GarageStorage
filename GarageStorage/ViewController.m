//
//  ViewController.m
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "ViewController.h"
#import "GSObjectMapper.h"
#import "GSCoreDataObject.h"
#import "GSObjectMapping.h"

#import "GSFakeMappableObject.h"
#import "GSFakeCoreDataObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    GSFakeMappableObject *sam = [GSFakeMappableObject mockObject];
    
    GSObjectMapper *mapper = [GSObjectMapper new];
    
    NSArray *array = [mapper gsCoreDataObjectsFromObject:sam];
    
    GSFakeCoreDataObject *obj = array[0];
    
    NSLog(@"\nid: %@\ntype: %@\ndata: %@", obj.gs_Identifier, obj.gs_type, obj.gs_data);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
