//
//  SKSpotifyPagedList.h
//  SKSpotify
//
//  Created by Shin-Kai Chen on 2016/5/31.
//  Copyright © 2016年 SK. All rights reserved.
//

#import <SKUtils/SKUtils.h>

@class SPTListPage;

@interface SKSpotifyPagedList : NSObject<SKPagedList>

@property(nonatomic, strong, nonnull, readonly) SPTListPage *lastPage;

- (nonnull instancetype)initWithListPage:(nonnull SPTListPage *)list;

@end
