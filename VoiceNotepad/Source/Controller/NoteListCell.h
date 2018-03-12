//
//  NoteListCell.h
//  Voice2Note
//
//  Created by xinyu on 2018/3/6.
//  Copyright © 2018年 MaChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VNNote.h"

@interface NoteListCell : UITableViewCell

@property (nonatomic, assign) NSInteger index;

+ (CGFloat)heightWithNote:(VNNote *)note;

- (void)updateWithNote:(VNNote *)note;

@end
