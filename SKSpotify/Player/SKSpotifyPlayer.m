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

@property(nonatomic, copy, nullable) NSURL *uri;

@property(nonatomic, assign) BOOL stopOnRequest;

@end

@implementation SKSpotifyPlayer

- (nonnull instancetype)initWithAuth:(nonnull SPTAuth *)auth {
    self = [super init];
    
    _auth = auth;
    _innerPlayer = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
    
    _innerPlayer.playbackDelegate = self;
    
    _stopOnRequest = NO;
    
    return self;
}

#pragma mark - Abstract

- (void)_setSource:(id)source callback:(SKErrorCallback)callback {
    if([source isKindOfClass:[NSString class]]) {
        _uri = [NSURL URLWithString:source];
    } else if([NSStringFromClass([source class]) isEqualToString:@"SPTPartialTrack"]) {
        SPTPartialTrack *partialTrack = source;
        _uri = partialTrack.uri;
    } else {
        callback([NSError errorWithDomain:@"Source not support" code:0 userInfo:nil]);
        return;
    }
    
    [super _setSource:source callback:callback];
}

- (void)_start:(SKErrorCallback)callback {
    SKErrorCallback loginCallback = ^(NSError *error) {
        if(error) {
            callback(error);
        } else {
            [self _start:callback];
        }
    };
    
    if([_innerPlayer loggedIn]) {
        [_innerPlayer playURIs:@[_uri] fromIndex:0 callback:callback];
    } else {
        [_innerPlayer loginWithSession:_auth.session callback:loginCallback];
    }
}

- (void)_resume:(SKErrorCallback)callback {
    [_innerPlayer setIsPlaying:YES callback:callback];
}

- (void)_pause:(SKErrorCallback)callback {
    [_innerPlayer setIsPlaying:NO callback:callback];
}

- (void)_stop:(SKErrorCallback)callback {
    __weak __typeof(_innerPlayer) weakInnerPlayer = _innerPlayer;
    
    _stopOnRequest = YES;
    
    [_innerPlayer setIsPlaying:NO callback:^(NSError *error) {
        if(error) {
            callback(error);
        } else {
            [weakInnerPlayer stop:callback];
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

- (void)_getProgress:(SKTimeCallback)success failure:(SKErrorCallback)failure {
    success(_innerPlayer.currentPlaybackPosition);
}

- (void)_getDuration:(SKTimeCallback)success failure:(SKErrorCallback)failure {
    if(_state==SKPlayerPlaying) {
        success(_innerPlayer.currentTrackDuration);
    } else {
        [SPTTrack trackWithURI:_uri session:_auth.session callback:^(NSError *error, id object) {
            if(error) {
                failure(error);
            } else {
                SPTTrack *track = object;
                success(track.duration);
            }
        }];
    }
}

- (void)playbackDidComplete:(nonnull id)playback {
    if(_looping) {
        [self stop:^(NSError * _Nullable error) {
            if(error) {
                NSLog(@"Unable to stop: %@", error);
            }
            
            [self start:^(NSError * _Nullable error) {
                if(error) {
                    NSLog(@"Unable to start: %@", error);
                } else {
                    SKLog(@"restart success");
                }
            }];
        }];
    } else {
        [super playbackDidComplete:playback];
    }
}

#pragma mark - SPTAudioStreamingPlaybackDelegate

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    SKLog(@"didChangePlaybackStatus %@", @(isPlaying));
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSURL *)trackUri {
    SKLog(@"didStartPlayingTrack %@", trackUri);
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri {
    SKLog(@"didStopPlayingTrack %@", trackUri);
    
    if(!_stopOnRequest) {
        [self playbackDidComplete:_source];
    }
    
    _stopOnRequest = NO;
}

@end
