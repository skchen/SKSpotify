//
//  SKSpotifyPlayer.h
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/4/20.
//  Copyright © 2016年 SK. All rights reserved.
//

@import SKUtils;

@class SPTAuth;

@interface SKSpotifyPlayer : SKPlayer<NSString *>

- (nonnull instancetype)initWithAuth:(nonnull SPTAuth *)auth;

@end
