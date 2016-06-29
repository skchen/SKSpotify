//
//  SKSpotifyPlayer.m
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/4/20.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKSpotifyPlayer.h"

#import <Spotify/Spotify.h>

#undef SKLog
#define SKLog(__FORMAT__, ...) 

@interface SKSpotifyPlayer () <SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>

@property(nonatomic, strong, nonnull) SPTAuth *auth;
@property(nonatomic, strong, nonnull) SPTAudioStreamingController *innerPlayer;

@property(nonatomic, strong, nullable) NSError *error;
@property(nonatomic, copy) dispatch_semaphore_t semaphore;

@property(nonatomic, copy, nullable) SKErrorCallback startCallback;

@end

@implementation SKSpotifyPlayer

- (nonnull instancetype)initWithAuth:(nonnull SPTAuth *)auth {
    self = [super init];
    
    _auth = auth;
    _innerPlayer = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
    
    _innerPlayer.playbackDelegate = self;
    
    return self;
}

#pragma mark - Abstract

- (void)_setDataSource:(id)source {
    // Do Nothing
}

- (void)_prepare:(SKErrorCallback)callback {
    SKErrorCallback playCallback = ^(NSError *error) {
        if(error) {
            callback(error);
        } else {
            [self _pause:callback];
        }
    };
    
    SKErrorCallback loginCallback = ^(NSError *error) {
        if(error) {
            callback(error);
        } else {
            [_innerPlayer playURIs:@[_source.uri] fromIndex:0 callback:playCallback];
        }
    };
    
    if([_innerPlayer loggedIn]) {
        [_innerPlayer playURIs:@[_source.uri] fromIndex:0 callback:playCallback];
    } else {
        [_innerPlayer loginWithSession:_auth.session callback:loginCallback];
    }
}

- (void)_start:(SKErrorCallback)callback {
    _startCallback = callback;
    
    [_innerPlayer setIsPlaying:YES callback:^(NSError *error) {
        if(error) {
            _startCallback = nil;
            callback(error);
        }
    }];
}

- (void)_pause:(SKErrorCallback)callback {
    [_innerPlayer setIsPlaying:NO callback:callback];
}

- (void)_stop:(SKErrorCallback)callback {
    [_innerPlayer stop:^(NSError *error) {
        if(error) {
            callback(error);
        } else {
            callback(nil);
        }
    }];
}

- (void)_seekTo:(NSTimeInterval)time success:(SKTimeCallback)success failure:(SKErrorCallback)failure {
    [_innerPlayer seekToOffset:time callback:^(NSError *error) {
        if(error) {
            failure(error);
        } else {
            success(time);
        }
    }];
}

- (void)_getCurrentPosition:(SKTimeCallback)success failure:(SKErrorCallback)failure {
    success(_innerPlayer.currentPlaybackPosition);
}

- (void)_getDuration:(SKTimeCallback)success failure:(SKErrorCallback)failure {
    success(_innerPlayer.currentTrackDuration);
}

#pragma mark - SPTAudioStreamingPlaybackDelegate

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    
    SKLog(@"%@", @(isPlaying));
    
    if(_startCallback) {
        _startCallback(nil);
        _startCallback = nil;
    }
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSURL *)trackUri {
    SKLog(@"%@", trackUri);
}

@end
