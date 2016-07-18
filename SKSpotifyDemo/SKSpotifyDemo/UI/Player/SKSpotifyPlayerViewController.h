//
//  ViewController.h
//  SKSpotifyDemo
//
//  Created by Shin-Kai Chen on 2016/4/20.
//  Copyright © 2016年 SK. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SKUtils/SKUtils.h>
@class SPTListPage;

@interface SKSpotifyPlayerViewController : SKListPlayerViewController

@property(nonatomic, strong, nonnull) SPTListPage *page;
@property(nonatomic, assign) NSUInteger index;

@property(nonatomic, copy, nullable) NSString *uri;


@end

