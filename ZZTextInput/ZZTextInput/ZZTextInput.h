//
//  ZZTextInput.h
//  ZZTextInput
//
//  Created by Zhang_yD on 2017/3/17.
//  Copyright © 2017年 Z. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const ZZRegExp;
extern NSString * const ZZMsg;

@class ZZTextInput;

@protocol ZZTextInputDelegate <NSObject>
@optional;
- (void)textInput:(ZZTextInput *)textInput completeEdit:(NSString *)text;

// inputVerifys属性 or textInput:checkTextValid:代理  二选一
- (NSString *)textInput:(ZZTextInput *)textInput checkTextValid:(NSString *)text;
@end


@interface ZZTextInput : UIView

// exp: @[@{ZZRegExp : @"^\\d{0,10}$", ZZMsg : @"请输入10位以内数字"}];
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *inputVerifys;
@property (nonatomic, copy) NSString *preText;
@property (nonatomic, weak) id<ZZTextInputDelegate> delegate;

- (void)show;

@end
