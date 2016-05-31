//
//  SKSpotifyBrowser.h
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/5/31.
//  Copyright © 2016年 SK. All rights reserved.
//

#import <SKUtils/SKUtils.h>

@class SPTPartialAlbum;
@class SPTPartialPlaylist;

@interface SKSpotifyBrowser : SKPagedAsync

@property(nonatomic, assign) NSUInteger pageSize;

- (nonnull instancetype)initWithToken:(nonnull NSString *)token;

- (void)listFeaturedPlaylists:(BOOL)refresh extend:(BOOL)extend country:(nullable NSString *)country locale:(nullable NSString *)locale timestamp:(nullable NSDate *)timestamp success:(nonnull SKPagedListCallback)success failure:(nonnull SKErrorCallback)failure;

- (void)listNewReleases:(BOOL)refresh extend:(BOOL)extend country:(nullable NSString *)country success:(nonnull SKPagedListCallback)success failure:(nonnull SKErrorCallback)failure;

- (void)listAlbum:(BOOL)refresh extend:(BOOL)extend album:(nonnull SPTPartialAlbum *)album market:(nullable NSString *)market success:(nonnull SKPagedListCallback)success failure:(nonnull SKErrorCallback)failure;

- (void)listPlaylist:(BOOL)refresh extend:(BOOL)extend playlist:(nonnull SPTPartialPlaylist *)playlist success:(nonnull SKPagedListCallback)success failure:(nonnull SKErrorCallback)failure;

@end
