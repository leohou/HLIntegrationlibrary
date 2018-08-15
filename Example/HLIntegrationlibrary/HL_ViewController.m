//
//  HL_ViewController.m
//  HLIntegrationlibrary
//
//  Created by leohou on 06/19/2017.
//  Copyright (c) 2017 leohou. All rights reserved.
//

#import "HL_ViewController.h"
#import <sys/utsname.h>
@interface HL_ViewController ()

@end

@implementation HL_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self getIphoneType];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(NSString *)getIphoneType{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    return platform;
}


@end
