//
//  AppContext.h
//  Voice2Note
//
//
//  Created by xinyu on 2018/3/6.
//  Copyright © 2018年 MaChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppContext : NSObject

+ (instancetype)appContext;

@property (nonatomic, assign) BOOL hasUploadAddressBook;

@end
