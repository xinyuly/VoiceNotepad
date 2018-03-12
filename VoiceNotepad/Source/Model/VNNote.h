//
//  VNNote.h
//  Voice2Note
//
//  Created by xinyu on 2018/3/6.
//  Copyright © 2018年 MaChat. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VNNOTE_DEFAULT_TITLE NSLocalizedString(@"NoTitleNote", @"")

@interface VNNote : NSObject<NSCoding>

@property (nonatomic, strong) NSString *noteID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSDate *updatedDate;
@property (nonatomic, assign) NSInteger index;

- (id)initWithTitle:(NSString *)title
            content:(NSString *)content
        createdDate:(NSDate *)createdDate
         updateDate:(NSDate *)updatedDate;

- (BOOL)Persistence;

@end
