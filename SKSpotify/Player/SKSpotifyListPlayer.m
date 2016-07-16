//
//  SKSpotifyListPlayer.m
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/7/16.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKSpotifyListPlayer.h"

#import "SKSpotifyPlayer.h"

@implementation SKSpotifyListPlayer

- (nonnull instancetype)initWithAuth:(nonnull SPTAuth *)auth {
    SKSpotifyPlayer *innerPlayer = [[SKSpotifyPlayer alloc] initWithAuth:auth];
    self = [super initWithPlayer:innerPlayer];
    return self;
}

@end
