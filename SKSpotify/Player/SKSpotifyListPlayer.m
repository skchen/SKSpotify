//
//  SKSpotifyListPlayer.m
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/7/16.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKSpotifyListPlayer.h"

#import "SKSpotifyPlayer.h"

#import <Spotify/SPTListPage.h>

@implementation SKSpotifyListPlayer

- (nonnull instancetype)initWithAuth:(nonnull SPTAuth *)auth {
    SKSpotifyPlayer *innerPlayer = [[SKSpotifyPlayer alloc] initWithAuth:auth];
    self = [super initWithPlayer:innerPlayer];
    return self;
}

- (void)setSource:(id)source atIndex:(NSUInteger)index callback:(SKErrorCallback)callback {

    if([NSStringFromClass([source class]) isEqualToString:@"SPTListPage"]) {
        SPTListPage *page = (SPTListPage *)source;
        [super setSource:page.tracksForPlayback atIndex:index callback:callback];
    } else {
        [super setSource:source atIndex:index callback:callback];
    }
}

@end
