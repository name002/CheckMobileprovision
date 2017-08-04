//
//  AppDelegate.m
//  CheckMobileprovision
//
//  Created by elong on 2017/8/3.
//  Copyright © 2017年 QCxy. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowViewController.h"

@interface AppDelegate ()

@property (strong) MainWindowViewController *mainWindowViewController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.mainWindowViewController = [[MainWindowViewController alloc] initWithWindowNibName:@"MainWindowViewController"];
    [self.mainWindowViewController showWindow:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
