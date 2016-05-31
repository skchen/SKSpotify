//
//  SKSpotifyBrowser.m
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/5/31.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKSpotifyBrowser.h"

#import <Spotify/Spotify.h>

#import "SKSpotifyPagedList.h"

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
    
    NSString *cacheKey = [self cacheKeyWithElements:4, kCacheKeyFeaturedPlaylists, country, locale, timestamp];
    
    [self pagedListAsync:refresh extend:extend cacheKey:cacheKey request:^(id<SKPagedList>  _Nullable pagedList, SKWrappedPagedListCallback  _Nonnull success, SKErrorCallback  _Nonnull failure) {
        
        if(pagedList) {
            NSLog(@"pagedList");
        } else {
            [SPTBrowse requestFeaturedPlaylistsForCountry:country limit:_pageSize offset:0 locale:locale timestamp:timestamp accessToken:_token callback:^(NSError *error, id object) {
                
                if(error) {
                    failure(error);
                } else {
                    SKSpotifyPagedList *pagedList = [[SKSpotifyPagedList alloc] initWithListPage:object];
                    success(pagedList);
                }
            }];
        }
    } success:success failure:failure];

    
}

@end
