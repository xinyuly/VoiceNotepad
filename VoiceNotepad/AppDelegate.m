//
//  AppDelegate.m
//  VoiceNotepad
//
//  Created by xinyu on 2018/3/12.
//  Copyright © 2018年 MaChat. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+VNHex.h"
#import "NoteListController.h"
#import "VNNote.h"
#import "NoteManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [[UINavigationBar appearance] setBarTintColor:[UIColor systemColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],NSForegroundColorAttributeName,
                                               nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self addInitFileIfNeeded];
    NoteListController *controller = [[NoteListController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)addInitFileIfNeeded {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"hasInitFile"]) {
        VNNote *note = [[VNNote alloc] initWithTitle:nil
                                             content:NSLocalizedString(@"AboutText", nil)
                                         createdDate:[NSDate date]
                                          updateDate:[NSDate date]];
        [[NoteManager sharedManager] storeNote:note];
        [userDefaults setBool:YES forKey:@"hasInitFile"];
        [userDefaults synchronize];
    }
}


@end
