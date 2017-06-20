//
//  HL_ViewController.m
//  HLIntegrationlibrary
//
//  Created by leohou on 06/19/2017.
//  Copyright (c) 2017 leohou. All rights reserved.
//

#import "HL_ViewController.h"
#import "NSData+HL_WSUKit.h"
@interface HL_ViewController ()

@end

@implementation HL_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


    [NSData dataByGzippingData:nil];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
