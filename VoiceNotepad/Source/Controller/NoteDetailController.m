//
//  NoteDetailController.m
//  Voice2Note
//
//  Created by xinyu on 2018/3/6.
//  Copyright © 2018年 MaChat. All rights reserved.
//

#import "NoteDetailController.h"
#import "SVProgressHUD.h"
#import "VNConstants.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlyDataUploader.h"
#import "iflyMSC/IFlyContact.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "Colours.h"
#import "UIColor+VNHex.h"
#import "AppContext.h"
@import MessageUI;

static const CGFloat kViewOriginY = 70;
static const CGFloat kTextFieldHeight = 30;
static const CGFloat kToolbarHeight = 44;
static const CGFloat kVoiceButtonWidth = 100;

@interface NoteDetailController () <IFlyRecognizerViewDelegate, UIActionSheetDelegate,
                                    MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) VNNote *note;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) IFlyRecognizerView *iflyRecognizerView;
@property (nonatomic, assign) BOOL isEditingTitle;

@end


@implementation NoteDetailController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNote:(VNNote *)note {
  self = [super init];
  if (self) {
    _note = note;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.view setBackgroundColor:[UIColor whiteColor]];
  [self initComps];
  [self setupNavigationBar];
  [self setupSpeechRecognizer];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self save];
}

#pragma mark - Private Methods
- (void)setupNavigationBar {
  UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ActionSheetSave", @"")
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(save)];

  UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_white"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(moreActionButtonPressed)];
  self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:moreItem, saveItem, nil];
}

- (void)setupSpeechRecognizer {
  NSString *initString = [NSString stringWithFormat:@"%@=%@", [IFlySpeechConstant APPID], kIFlyAppID];

  [IFlySpeechUtility createUtility:initString];
  _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
  _iflyRecognizerView.delegate = self;

  [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
  [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
  [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
}

- (void)initComps {
  CGRect frame = CGRectMake(kHorizontalMargin, kViewOriginY, self.view.frame.size.width - kHorizontalMargin * 2, kTextFieldHeight);

  UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboard)];
  doneBarButton.width = ceilf(self.view.frame.size.width) / 3 - 30;

  UIBarButtonItem *voiceBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"micro_small"] style:UIBarButtonItemStylePlain target:self action:@selector(useVoiceInput)];
  voiceBarButton.width = ceilf(self.view.frame.size.width) / 3;

  UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kToolbarHeight)];
  toolbar.tintColor = [UIColor systemColor];
  toolbar.items = [NSArray arrayWithObjects:doneBarButton, voiceBarButton, nil];

  //标题
//    UITextField *textField = [[UITextField alloc] init];
//    textField.placeholder = NSLocalizedString(@"标题", nil);
  frame = CGRectMake(kHorizontalMargin,
                     0,
                     self.view.frame.size.width - kHorizontalMargin * 2,
                     self.view.frame.size.height - kVoiceButtonWidth - kVerticalMargin * 2);
  _contentTextView = [[UITextView alloc] initWithFrame:frame];
  _contentTextView.textColor = [UIColor systemDarkColor];
  _contentTextView.font = [UIFont systemFontOfSize:16];
  _contentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
  _contentTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
  [_contentTextView setScrollEnabled:YES];
  if (_note) {
    _contentTextView.text = _note.content;
  }
  _contentTextView.inputAccessoryView = toolbar;
  [self.view addSubview:_contentTextView];

  _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_voiceButton setFrame:CGRectMake((self.view.frame.size.width - kVoiceButtonWidth) / 2, self.view.frame.size.height - kVoiceButtonWidth - kVerticalMargin, kVoiceButtonWidth, kVoiceButtonWidth)];
  [_voiceButton setTitle:NSLocalizedString(@"VoiceInput", @"") forState:UIControlStateNormal];
  [_voiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  _voiceButton.layer.cornerRadius = kVoiceButtonWidth / 2;
  _voiceButton.layer.masksToBounds = YES;
  [_voiceButton setBackgroundColor:[UIColor systemColor]];
  [_voiceButton addTarget:self action:@selector(useVoiceInput) forControlEvents:UIControlEventTouchUpInside];
  [_voiceButton setTintColor:[UIColor whiteColor]];
  [self.view addSubview:_voiceButton];
}

- (void)startListenning {
  [_iflyRecognizerView start];
  NSLog(@"start listenning...");
}

- (void)useVoiceInput {
  if (![AppContext appContext].hasUploadAddressBook) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"UploadABForBetter", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ActionSheetCancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"GotoUploadAB", @""), nil];
    [alertView show];
    [[AppContext appContext] setHasUploadAddressBook:YES];
    return;
  }
  
  [self hideKeyboard];
  [self startListenning];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1) {
    IFlyDataUploader *_uploader = [[IFlyDataUploader alloc] init];
    IFlyContact *iFlyContact = [[IFlyContact alloc] init]; NSString *contactList = [iFlyContact contact];
    [_uploader setParameter:@"uup" forKey:@"subject"];
    [_uploader setParameter:@"contact" forKey:@"dtt"];
    //启动上传
    [_uploader uploadDataWithCompletionHandler:^(NSString *grammerID, IFlySpeechError *error) {
      [SVProgressHUD showSuccessWithStatus:@"上传成功"];
    } name:@"contact" data:contactList];
  }
}

#pragma mark - IFlyRecognizerViewDelegate

- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast {
  NSMutableString *result = [[NSMutableString alloc] init];
  NSDictionary *dic = [resultArray objectAtIndex:0];
  for (NSString *key in dic) {
    [result appendFormat:@"%@", key];
  }
  _contentTextView.text = [NSString stringWithFormat:@"%@%@", _contentTextView.text, result];
}

- (void)onError:(IFlySpeechError *)error {
  NSLog(@"errorCode:%@", error);
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                        delay:0.f
                      options:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]
                   animations:^
   {
     CGRect keyboardFrame = [[userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
     CGFloat keyboardHeight = keyboardFrame.size.height;

     CGRect frame = _contentTextView.frame;
     frame.size.height = self.view.frame.size.height - kViewOriginY - kTextFieldHeight - keyboardHeight - kVerticalMargin - kToolbarHeight,
     _contentTextView.frame = frame;
   }               completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                        delay:0.f
                      options:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]
                   animations:^
   {
     CGRect frame = _contentTextView.frame;
     frame.size.height = self.view.frame.size.height - kViewOriginY - kTextFieldHeight - kVoiceButtonWidth - kVerticalMargin * 3;
     _contentTextView.frame = frame;
   }               completion:NULL];
}

- (void)hideKeyboard {
  if ([_contentTextView isFirstResponder]) {
    _isEditingTitle = NO;
    [_contentTextView resignFirstResponder];
  }
}

#pragma mark - Save

- (void)save {
  [self hideKeyboard];
  if ((_contentTextView.text == nil || _contentTextView.text.length == 0)) {
    return;
  }
  NSDate *createDate;
  if (_note && _note.createdDate) {
    createDate = _note.createdDate;
  } else {
    createDate = [NSDate date];
  }
  VNNote *note = [[VNNote alloc] initWithTitle:nil
                                       content:_contentTextView.text
                                   createdDate:createDate
                                    updateDate:[NSDate date]];
  _note = note;
  BOOL success = [note Persistence];
  if (success) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCreateFile object:nil userInfo:nil];
  } else {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SaveFail", @"")];
  }
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - More Action

- (void)moreActionButtonPressed {
  [self hideKeyboard];
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"ActionSheetCancel", @"")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"ActionSheetCopy", @""),
                                NSLocalizedString(@"ActionSheetMail", @""), nil];
  [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _contentTextView.text;
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"CopySuccess", @"")];
  } else if (buttonIndex == 1) {
    if ([MFMailComposeViewController canSendMail]) {
      [self sendEmail];
    } else {
      [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"CanNoteSendMail", @"")];
    }
  } else if (buttonIndex == 2) {
    [self shareToWeixin];
  }
}

#pragma mark - Eail

- (void)sendEmail {
  MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
  [composer setMailComposeDelegate:self];
  if ([MFMailComposeViewController canSendMail]) {
    NSString *string = NSLocalizedString(@"form_note_email", nil);
    [composer setSubject:string];
    [composer setMessageBody:_contentTextView.text isHTML:NO];
    [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:composer animated:YES completion:nil];
  } else {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"CanNoteSendMail", @"")];
  }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
  if (result == MFMailComposeResultFailed) {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendEmailFail", @"")];
  } else if (result == MFMailComposeResultSent) {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendEmailSuccess", @"")];
  }
  [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Weixin
- (void)shareToWeixin {
  if (_contentTextView.text == nil || _contentTextView.text.length == 0) {
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"InputTextNoData", @"")];
    return;
  }

}

@end
