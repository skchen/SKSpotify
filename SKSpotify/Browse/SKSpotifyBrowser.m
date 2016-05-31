//
//  SKSpotifyBrowser.m
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/5/31.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKSpotifyBrowser.h"

#import <Spotify/Spotify.h>

static const NSUInteger kPageSizeDefault = 50;

static NSString * const kCacheKeyFeaturedPlaylists = @"FeaturedPlaylists";

@interface SKSpotifyBrowser ()

@property(nonatomic, copy, readonly, nonnull) NSString *token;

@end

@implementation SKSpotifyBrowser

- (nonnull instancetype)initWithToken:(nonnull NSString *)token {
    self = [super init];
    
    _pageSize = kPageSizeDefault;
    
    _token = token;
    
    return self;
}

- (void)listFeaturedPlaylists:(BOOL)refresh extend:(BOOL)extend country:(nullable NSString *)country locale:(nullable NSString *)locale timestamp:(nullable NSDate *)timestamp success:(nonnull SKPagedListCallback)success failure:(nonnull SKErrorCallback)failure {

    [SPTBrowse requestFeaturedPlaylistsForCountry:country limit:_pageSize offset:0 locale:locale timestamp:timestamp accessToken:_token callback:^(NSError *error, id object) {
        
        if(error) {
            failure(error);
        } else {
            SPTFeaturedPlaylistList *featuredPlaylistList = (SPTFeaturedPlaylistList *)object;
        }
    }];
}

@end
