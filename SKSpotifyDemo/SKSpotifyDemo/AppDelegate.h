//
//  AppDelegate.h
//  SKSpotifyDemo
//
//  Created by Shin-Kai Chen on 2016/4/20.
//  Copyright © 2016年 SK. All rights reserved.
//

#import <UIKit/UIKit.h>

@import SKSpotify;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SKSpotifyPlayer *player;

@end

