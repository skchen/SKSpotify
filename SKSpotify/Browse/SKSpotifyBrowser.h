//
//  SKSpotifyBrowser.h
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/5/31.
//  Copyright © 2016年 SK. All rights reserved.
//

#import <SKUtils/SKUtils.h>

@interface SKSpotifyBrowser : SKPagedAsync

@property(nonatomic, assign) NSUInteger pageSize;

- (nonnull instancetype)initWithToken:(nonnull NSString *)token;

- (void)listFeaturedPlaylists:(BOOL)refresh extend:(BOOL)extend country:(nullable NSString *)country locale:(nullable NSString *)locale timestamp:(nullable NSDate *)timestamp success:(nonnull SKPagedListCallback)success failure:(nonnull SKErrorCallback)failure;

@end
