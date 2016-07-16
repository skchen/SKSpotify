//
//  SKSpotifyListPlayer.h
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/7/16.
//  Copyright © 2016年 SK. All rights reserved.
//

#import <SKUtils/SKUtils.h>

@class SPTAuth;

@interface SKSpotifyListPlayer : SKNestedListPlayer

- (nonnull instancetype)initWithAuth:(nonnull SPTAuth *)auth;

@end
