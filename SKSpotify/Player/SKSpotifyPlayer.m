//
//  SKSpotifyPlayer.m
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/4/20.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKSpotifyPlayer.h"

#import <Spotify/Spotify.h>

@interface SKSpotifyPlayer ()

@property(nonatomic, strong, nonnull) SPTAuth *auth;
@property(nonatomic, strong, nullable) NSString *source;
@property(nonatomic, strong, nonnull) SPTAudioStreamingController *innerPlayer;

@property(nonatomic, strong, nullable) NSError *error;
@property(nonatomic, copy) dispatch_semaphore_t semaphore;

@end

@implementation SKSpotifyPlayer

- (nonnull instancetype)initWithAuth:(nonnull SPTAuth *)auth {
    self = [super init];
    
    _auth = auth;
    _innerPlayer = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
    
    return self;
}

#pragma mark - Abstract

- (nullable NSError *)_setDataSource:(nonnull NSString*)source {
    _source = source;
    return nil;
}

- (nullable NSError *)_prepare {
    if([self executeBlockingWise:^(SPTErrorableOperationCallback callback) {
        [_innerPlayer loginWithSession:_auth.session callback:callback];
    }]) {
        return _error;
    }
    
    NSURL *trackURI = [NSURL URLWithString:_source];
    
    if([self executeBlockingWise:^(SPTErrorableOperationCallback callback) {
        [_innerPlayer playURIs:@[ trackURI ] fromIndex:0 callback:callback];
    }]) {
        return _error;
    }
    
    return [self _pause];
}

- (nullable NSError *)_start {
    return [self executeBlockingWise:^(SPTErrorableOperationCallback callback) {
        [_innerPlayer setIsPlaying:YES callback:callback];
    }];
}

- (nullable NSError *)_pause {
    return [self executeBlockingWise:^(SPTErrorableOperationCallback callback) {
        [_innerPlayer setIsPlaying:NO callback:callback];
    }];
}

- (nullable NSError *)_stop {
    return [self executeBlockingWise:^(SPTErrorableOperationCallback callback) {
        [_innerPlayer stop:callback];
    }];
}

- (nullable NSError *)_seekTo:(int)msec {
    float offset = (float)msec/1000;
    
    return [self executeBlockingWise:^(SPTErrorableOperationCallback callback) {
        [_innerPlayer seekToOffset:offset callback:callback];
    }];
}

- (int)getCurrentPosition {
    return round(_innerPlayer.currentPlaybackPosition*1000);
}

- (int)getDuration {
    return round(_innerPlayer.currentTrackDuration*1000);
}

- (NSError *)executeBlockingWise:(void (^_Nonnull)(SPTErrorableOperationCallback))task {
    _semaphore = dispatch_semaphore_create(0);
    
    SPTErrorableOperationCallback callback = ^void(NSError *error) {
        _error = error;
        dispatch_semaphore_signal(_semaphore);
    };
    
    task(callback);
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    return _error;
}

@end
