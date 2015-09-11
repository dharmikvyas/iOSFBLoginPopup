//
//  Application.m
//  babaa
//
//  Created by My Mac on 6/15/15.
//  Copyright (c) 2015 BABAA. All rights reserved.
//

#import "Application.h"

@implementation Application

- (BOOL)openURL:(NSURL*)url {
    NSLog(@"Calling Open URL");
    
    NSLog(@"Open==> %@", [url absoluteString]);
    if ([[url absoluteString] hasPrefix:@"https://m.facebook.com/v2.2/dialog/oauth?sdk_version="]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationAuthNotificationFB object:url];
        
        NSLog(@"Calling FB Dialog");
        return NO;
    }
    return [super openURL:url];
}

@end
