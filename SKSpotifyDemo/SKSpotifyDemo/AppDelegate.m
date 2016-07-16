//
//  AppDelegate.m
//  SKSpotifyDemo
//
//  Created by Shin-Kai Chen on 2016/4/20.
//  Copyright © 2016年 SK. All rights reserved.
//

#import "AppDelegate.h"

#import <Spotify/Spotify.h>

static NSString * const kSpotifyClientId = @"4d4573064a0b4f64ad0629adc987184a";
static NSString * const kSpotifyClientCallback = @"skspotify://callback";
static NSString * const kSpotifySessionUserDefaultKey = @"SessionUserDefaultsKey";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[SPTAuth defaultInstance] setClientID:kSpotifyClientId];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:kSpotifyClientCallback]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope]];
    [[SPTAuth defaultInstance] setSessionUserDefaultsKey:kSpotifySessionUserDefaultKey];
    
    _player = [[SKSpotifyListPlayer alloc] initWithAuth:[SPTAuth defaultInstance]];
    
    if(![[SPTAuth defaultInstance] session].isValid) {
        // Construct a login URL and open it
        NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
        
        // Opening a URL in Safari close to application launch may trigger
        // an iOS bug, so we wait a bit before doing so.
        [application performSelector:@selector(openURL:)
                          withObject:loginURL afterDelay:0.1];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            
            if (error != nil) {
                NSLog(@"*** Auth error: %@", error);
                return;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
        }];
        return YES;
    }
    
    return NO;
}

@end
