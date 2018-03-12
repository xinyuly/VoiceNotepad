//
//  VNNoteManager.h
//  Voice2Note
//
//  Created by xinyu on 2018/3/6.
//  Copyright © 2018年 MaChat. All rights reserved.
//

@import Foundation;

@class VNNote;
@interface NoteManager : NSObject

@property (nonatomic, strong) NSString *docPath;

- (NSMutableArray *)readAllNotes;

- (VNNote *)readNoteWithID:(NSString *)noteID;
- (BOOL)storeNote:(VNNote *)note;
- (void)deleteNote:(VNNote *)note;

- (VNNote *)todayNote;

+ (instancetype)sharedManager;

@end
