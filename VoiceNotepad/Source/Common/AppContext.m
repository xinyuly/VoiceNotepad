//
//  AppContext.m
//  Voice2Note
//
//  Created by xinyu on 2018/3/6.
//  Copyright © 2018年 MaChat. All rights reserved.
//

#import "AppContext.h"

static NSString* kHasUploadAddressBookKey = @"kHasUploadAddressBookKey";

@implementation AppContext

+ (instancetype)appContext {
  static id instance = nil;
  static dispatch_once_t onceToken = 0L;
  dispatch_once(&onceToken, ^{
    instance = [[AppContext alloc] init];
  });
  return instance;
}

- (BOOL)hasUploadAddressBook {
  return [[[NSUserDefaults standardUserDefaults] objectForKey:kHasUploadAddressBookKey] boolValue];
}

- (void)setHasUploadAddressBook:(BOOL)hasUploadAddressBook {
  [[NSUserDefaults standardUserDefaults] setBool:hasUploadAddressBook forKey:kHasUploadAddressBookKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

