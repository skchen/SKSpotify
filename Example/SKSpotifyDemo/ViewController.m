//
//  ViewController.m
//  SKSpotifyDemo
//
//  Created by Shin-Kai Chen on 2016/4/20.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "ViewController.h"

@import SKSpotify;

@interface ViewController ()

@property(nonatomic, strong, nonnull) SKSpotifyPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _player = [[SKSpotifyPlayer alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
