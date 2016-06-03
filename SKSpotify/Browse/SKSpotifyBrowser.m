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
static NSString * const kCacheKeyNewReleases = @"NewReleases";

static NSString * const kCacheKeyAlbum = @"Album";
static NSString * const kCacheKeyPlaylist = @"Playlist";

typedef void (^SKSpotifyPagedListCallback)(SKSpotifyPagedList * _Nonnull newPage);
typedef void (^SKSpotifyAsyncPagedListRequest)(SKSpotifyPagedListCallback success, SKErrorCallback failure);

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
    
    NSString *cacheKey = [SKCachedAsync cacheKeyWithElements:4, kCacheKeyFeaturedPlaylists, country, locale, timestamp];
    
    [self spotifyPagedListAsync:refresh extend:extend cacheKey:cacheKey request:^(SKSpotifyPagedListCallback success, SKErrorCallback failure) {
        [SPTBrowse requestFeaturedPlaylistsForCountry:country limit:_pageSize offset:0 locale:locale timestamp:timestamp accessToken:_token callback:^(NSError *error, id object) {
            
            if(error) {
                failure(error);
            } else {
                SKSpotifyPagedList *pagedList = [[SKSpotifyPagedList alloc] initWithListPage:object];
                success(pagedList);
            }
        }];
    } success:success failure:failure];
}

- (void)listNewReleases:(BOOL)refresh extend:(BOOL)extend country:(nullable NSString *)country success:(nonnull SKPagedListCallback)success failure:(nonnull SKErrorCallback)failure {
    
    NSString *cacheKey = [SKCachedAsync cacheKeyWithElements:2, kCacheKeyNewReleases, country];
    
    [self spotifyPagedListAsync:refresh extend:extend cacheKey:cacheKey request:^(SKSpotifyPagedListCallback success, SKErrorCallback failure) {
        NSError *error;
        NSURLRequest *request = [SPTBrowse createRequestForNewReleasesInCountry:@"US" limit:_pageSize offset:0 accessToken:_token error:&error];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if(error) {
                failure(error);
            } else {
                SPTListPage *newReleases = [SPTBrowse newReleasesFromData:data withResponse:response error:&error];
                
                if(error) {
                    failure(error);
                } else {
                    SKSpotifyPagedList *pagedList = [[SKSpotifyPagedList alloc] initWithListPage:newReleases];
                    success(pagedList);
                }
            }
            
        }] resume];
    } success:success failure:failure];
}

- (void)listAlbum:(BOOL)refresh extend:(BOOL)extend album:(nonnull SPTPartialAlbum *)album market:(nullable NSString *)market success:(nonnull SKPagedListCallback)success failure:(nonnull SKErrorCallback)failure {
    
    NSString *cacheKey = [SKCachedAsync cacheKeyWithElements:2, kCacheKeyAlbum, album.uri.absoluteString];
    
    [self spotifyPagedListAsync:refresh extend:extend cacheKey:cacheKey request:^(SKSpotifyPagedListCallback success, SKErrorCallback failure) {
        [SPTAlbum albumWithURI:album.uri accessToken:_token market:market callback:^(NSError *error, id object) {
            if(error) {
                failure(error);
            } else {
                SPTListPage *newPage = ((SPTAlbum *)object).firstTrackPage;
                SKSpotifyPagedList *pagedList = [[SKSpotifyPagedList alloc] initWithListPage:newPage];
                success(pagedList);
            }
        }];
    } success:success failure:failure];
}

- (void)listPlaylist:(BOOL)refresh extend:(BOOL)extend playlist:(nonnull SPTPartialPlaylist *)playlist success:(nonnull SKPagedListCallback)success failure:(nonnull SKErrorCallback)failure {
    
    NSString *cacheKey = [SKCachedAsync cacheKeyWithElements:2, kCacheKeyPlaylist, playlist.uri.absoluteString];
    
    [self spotifyPagedListAsync:refresh extend:extend cacheKey:cacheKey request:^(SKSpotifyPagedListCallback success, SKErrorCallback failure) {
        [SPTPlaylistSnapshot playlistWithURI:playlist.uri accessToken:_token callback:^(NSError *error, id object) {
            if(error) {
                failure(error);
            } else {
                SPTListPage *newPage = ((SPTPlaylistSnapshot *)object).firstTrackPage;
                SKSpotifyPagedList *pagedList = [[SKSpotifyPagedList alloc] initWithListPage:newPage];
                success(pagedList);
            }
        }];
    } success:success failure:failure];
}

- (nonnull SKAsyncPagedListRequest) spotifyPagedListRequest:(nonnull SKSpotifyAsyncPagedListRequest)spotifyRequest {
    return ^(id<SKPagedList>  _Nullable pagedList, SKWrappedPagedListCallback  _Nonnull success, SKErrorCallback  _Nonnull failure) {
        
        if(pagedList) {
            SKSpotifyPagedList *spotifyPagedList = (SKSpotifyPagedList *)pagedList;
            SPTListPage *lastPage = spotifyPagedList.lastPage;
            [lastPage requestNextPageWithAccessToken:_token callback:^(NSError *error, id object) {
                
                if(error) {
                    failure(error);
                } else {
                    [pagedList append:object];
                    success(pagedList);
                }
            }];
        } else {
            spotifyRequest(success, failure);
        }
    };
}

- (void)spotifyPagedListAsync:(BOOL)refresh extend:(BOOL)extend cacheKey:(nonnull id<NSCopying>)cacheKey request:(nonnull SKSpotifyAsyncPagedListRequest)spotifyAsyncRequest success:(nonnull SKPagedListCallback)success failure:(nonnull SKErrorCallback)failure {

    [self pagedListAsync:refresh extend:extend cacheKey:cacheKey request:[self spotifyPagedListRequest:spotifyAsyncRequest] success:success failure:failure];
}

@end
