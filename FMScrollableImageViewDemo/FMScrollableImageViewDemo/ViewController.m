//
//  ViewController.m
//  FMScrollableImageViewDemo
//
//  Created by Maurizio Cremaschi on 9/20/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "ViewController.h"
#import "FMScrollableImageView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollableImageView.imageView.image = [UIImage imageNamed:@"image.jpg"];
}

@end
