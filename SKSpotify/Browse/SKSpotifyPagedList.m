//
//  SKSpotifyPagedList.m
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/5/31.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "SKSpotifyPagedList.h"

#import <Spotify/Spotify.h>

@interface SKSpotifyPagedList ()

@property(nonatomic, strong, nonnull, readonly) NSMutableArray *mutableList;
@property(nonatomic, strong, nonnull, readonly) SPTListPage *lastPage;

@end

@implementation SKSpotifyPagedList

@synthesize finished;

- (nonnull instancetype)initWithListPage:(nonnull SPTListPage *)listPage {
    self = [super init];
    
    _mutableList = [[NSMutableArray alloc] init];
    
    [self append:listPage];
    
    return self;
}

- (nonnull NSArray *)list {
    return _mutableList;
}

- (void)append:(id)newPage {
    if([newPage isKindOfClass:[SPTListPage class]]) {
        _lastPage = newPage;
        
        SPTListPage *playlistList = (SPTListPage *)newPage;
        
        [_mutableList addObjectsFromArray:playlistList.items];
        finished = !playlistList.hasNextPage;
    }
}

@end
