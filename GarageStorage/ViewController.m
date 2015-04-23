//
//  ViewController.m
//  GarageStorage
//
//  Created by Sam Voigt on 4/20/15.
//  Copyright (c) 2015 Wellframe. All rights reserved.
//

#import "ViewController.h"
#import "GarageStorage.h"

#import "MockPersonObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MockPersonObject *sam = [MockPersonObject mockObject];
    
    GSGarage *garage = [[GSGarage alloc] init];
   
    [garage parkObjectInGarage:sam];
    
    sam = nil;
    
    sam = [garage retrieveObjectOfClass:[MockPersonObject class] identifier:@"Sam"];
    
    NSLog(@"Sam: %@", sam);
}

@end
