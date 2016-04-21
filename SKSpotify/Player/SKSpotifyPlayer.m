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
    _semaphore = dispatch_semaphore_create(0);
    
    NSURL *trackURI = [NSURL URLWithString:_source];
    
    [_innerPlayer loginWithSession:_auth.session callback:^(NSError *error) {
        if(error) {
            _error = error;
            dispatch_semaphore_signal(_semaphore);
        } else {
            [_innerPlayer playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
                if(error) {
                    _error = error;
                    dispatch_semaphore_signal(_semaphore);
                } else {
                    [_innerPlayer setIsPlaying:NO callback:^(NSError *error) {
                        _error = error;
                        dispatch_semaphore_signal(_semaphore);
                    }];
                }
            }];
        }
    }];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    return _error;
}

- (nullable NSError *)_start {
    _semaphore = dispatch_semaphore_create(0);
    
    [_innerPlayer setIsPlaying:YES callback:^(NSError *error) {
        _error = error;
        dispatch_semaphore_signal(_semaphore);
    }];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    return _error;
}

- (nullable NSError *)_pause {
    _semaphore = dispatch_semaphore_create(0);
    
    [_innerPlayer setIsPlaying:NO callback:^(NSError *error) {
        _error = error;
        dispatch_semaphore_signal(_semaphore);
    }];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    return _error;
}

- (nullable NSError *)_stop {
    _semaphore = dispatch_semaphore_create(0);
    
    [_innerPlayer stop:^(NSError *error) {
        _error = error;
        dispatch_semaphore_signal(_semaphore);
    }];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    return _error;
}

- (nullable NSError *)_seekTo:(int)msec {
    float offset = (float)msec/1000;
    
    _semaphore = dispatch_semaphore_create(0);
    
    [_innerPlayer seekToOffset:offset callback:^(NSError *error) {
        _error = error;
        dispatch_semaphore_signal(_semaphore);
    }];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    return _error;
}

- (int)getCurrentPosition {
    return round(_innerPlayer.currentPlaybackPosition*1000);
}

- (int)getDuration {
    return round(_innerPlayer.currentTrackDuration*1000);
}

@end
