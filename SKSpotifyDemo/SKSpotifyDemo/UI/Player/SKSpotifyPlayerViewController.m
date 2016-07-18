//
//  ViewController.m
//  SKYoutubePlayer
//
//  Created by Shin-Kai Chen on 2016/4/19.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKSpotifyPlayerViewController.h"

#import <Spotify/Spotify.h>
#import <SKSpotify/SKSpotify.h>
#import "AppDelegate.h"

@interface SKSpotifyPlayerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation SKSpotifyPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    self.player = app.player;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak __typeof(self.player) weakPlayer = self.player;
    
    [self.listPlayer setSource:_page atIndex:_index callback:^(NSError * _Nullable error) {
        
        if(error) {
            NSLog(@"Unable to set source: %@", error);
        } else {
            [weakPlayer start:^(NSError * _Nullable error) {
                if(error) {
                    NSLog(@"Unable to start: %@", error);
                }
            }];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player stop:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"Unable to stop: %@", error);
        }
    }];
}

- (void)playerDidChangeSource:(SKPlayer *)player {
    [super playerDidChangeSource:player];
    
    SKListPlayer *listPlayer = (SKListPlayer *)player;
    id source = [listPlayer.source objectAtIndex:listPlayer.index];
    
    if([source isKindOfClass:[NSString class]]) {
        [SPTTrack trackWithURI:[NSURL URLWithString:source] session:[SPTAuth defaultInstance].session callback:^(NSError *error, id object) {
            if(error) {
                NSLog(@"load track error: %@", error);
            } else {
                SPTTrack *track = object;
                [_nameLabel setText:track.name];
            }
        }];
    } else if([source isKindOfClass:[SPTPartialTrack class]]) {
        SPTPartialTrack *partialTrack = (SPTPartialTrack *)source;
        [_nameLabel setText:partialTrack.name];
    } else {
        [_nameLabel setText:@"N/A"];
    }
}

@end
