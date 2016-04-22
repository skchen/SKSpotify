//
//  SKSpotifyPlaybackTableViewController.m
//  SKSpotifyDemo
//
//  Created by Shin-Kai Chen on 2016/4/21.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKSpotifyPlaybackTableViewController.h"

#import <Spotify/Spotify.h>

#import "SKSpotifyPlayerViewController.h"

@interface SKSpotifyPlaybackTableViewController ()

@property(nonatomic, strong, nullable) SPTListPage *page;

@end

@implementation SKSpotifyPlaybackTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_page.tracksForPlayback count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SKSpotifyPlaybackTableViewCell"];
    
    SPTTrack *track = [_page.tracksForPlayback objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", track.name]];
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    SPTTrack *track = [_page.tracksForPlayback objectAtIndex:indexPath.row];
    
    SKSpotifyPlayerViewController *destinationViewController = segue.destinationViewController;
    destinationViewController.uri = track.uri.absoluteString;
}

#pragma mark - NSNotification

-(void)sessionUpdatedNotification:(NSNotification *)notification {
    SPTAuth *auth = [SPTAuth defaultInstance];
    SPTSession *session = auth.session;
    if([session isValid]) {
        [SPTSearch performSearchWithQuery:@"X-Japan" queryType:SPTQueryTypeTrack accessToken:session.accessToken callback:^(NSError *error, id object) {
            
            _page = object;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

@end
