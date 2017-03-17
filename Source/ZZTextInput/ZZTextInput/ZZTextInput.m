//
//  ZZTextInput.m
//  ZZTextInput
//
//  Created by Zhang_yD on 2017/3/17.
//  Copyright © 2017年 Z. All rights reserved.
//

#import "ZZTextInput.h"
#import "NSString+ZZTextInputExtension.h"
#import "UIView+ZZTextInputExtension.h"
#import "UIColor+ZZTextInputExtension.h"
#import "UILabel+ZZTextInputExtension.h"

NSString * const ZZRegExp = @"RegExp";
NSString * const ZZMsg = @"Msg";

#define kColor(a) [UIColor colorWithHex:a]
#define kFont(a) [UIFont systemFontOfSize:a]
#define ZZScreenWidth [UIScreen mainScreen].bounds.size.width
#define ZZScreenHeight [UIScreen mainScreen].bounds.size.height


@interface ZZTextInput ()
{
    struct {
        unsigned int completeFlg : 1;
        unsigned int validFlg : 1;
    } _delegateFlg;
}
@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UILabel *hintLabel;
@end

@interface ZZTextInput (Private)
- (void)zp_setup;
- (void)zp_shakeLabel;
- (void)zp_removeHandle;
- (void)zp_animationHint;
@end

@interface ZZTextInput (UITextField) <UITextFieldDelegate>
- (void)zp_textChange:(UITextField *)textField;
@end


@interface ZZTextInput (Keyboard)
- (void)zp_keyboardWillShow:(NSNotification *)note;
- (void)zp_keyboardWillHide:(NSNotification *)note;
@end

@implementation ZZTextInput
{
    CGFloat _originTextFieldY;
    BOOL _textValid;
    BOOL _isAnimating;
    NSString *_hintStr;
}

- (void)removeFromSuperview {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super removeFromSuperview];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self zp_setup];
        self.alpha = 0;
        _textValid = YES;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    self.frame = newSuperview.bounds;
}

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self.textField becomeFirstResponder];
    }];
}

- (void)setPreText:(NSString *)preText {
    _preText = [preText copy];
    _textField.text = _preText;
}
- (void)setDelegate:(id<ZZTextInputDelegate>)delegate {
    _delegate = delegate;
    _delegateFlg.completeFlg = [delegate respondsToSelector:@selector(textInput:completeEdit:)];
    _delegateFlg.validFlg = [delegate respondsToSelector:@selector(textInput:checkTextValid:)];
}

@end

@implementation ZZTextInput (Private)

- (void)zp_setup {
    UILabel *label = [[UILabel alloc] init];
    [self addSubview:label];
    label.textColor = [UIColor redColor];
    label.font = kFont(14);
    label.text = @"";
    label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    label.textAlignment = NSTextAlignmentCenter;
    label.height = label.labelHeight + 16;
    [label makeCornerWithRadius:label.height * 0.5];
    label.alpha = 0;
    _hintLabel = label;

    UITextField *textField = [[UITextField alloc] init];
    [self addSubview:textField];
    _textField = textField;
    textField.frame = CGRectMake(0, ZZScreenHeight - 50, ZZScreenWidth, 50);
    _originTextFieldY = textField.y;
    textField.font = kFont(15);
    textField.textColor = kColor(0x2a2a2b);
    textField.backgroundColor = [UIColor whiteColor];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    [textField addTarget:self action:@selector(zp_textChange:) forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zp_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zp_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self addTapGestureRecognizerWithTarget:self acion:@selector(zp_removeHandle)];
}

- (void)zp_shakeLabel {
    CAKeyframeAnimation *kfa = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat s = 16;
    kfa.values = @[@(-s),@(0),@(s),@(0),@(-s),@(0),@(s),@(0)];
    kfa.duration = .1f;
    kfa.repeatCount =2;
    kfa.removedOnCompletion = YES;
    [_hintLabel.layer addAnimation:kfa forKey:@"shake"];
}

- (void)zp_animationHint {
    if (_isAnimating) return;
    
    if (_textValid && _hintLabel.alpha > 0) {
        _isAnimating = YES;
        [UIView animateWithDuration:0.3 animations:^{
            _hintLabel.alpha = 0;
            _hintLabel.transform = CGAffineTransformMakeTranslation(0, 14);
        } completion:^(BOOL finished) {
            _isAnimating = NO;
            [self zp_animationHint];
        }];
    } else if (!_textValid && _hintLabel.alpha < 1) {
        _isAnimating = YES;
        _hintLabel.text = _hintStr;
        _hintLabel.y = _textField.y - 10 - _hintLabel.height;
        _hintLabel.transform = CGAffineTransformMakeTranslation(0, 14);
        _hintLabel.width = _hintLabel.labelWidth + 34;
        _hintLabel.centerX = self.width / 2;
        [UIView animateWithDuration:0.3 animations:^{
            _hintLabel.transform = CGAffineTransformIdentity;
            _hintLabel.alpha = 1;
        } completion:^(BOOL finished) {
            _isAnimating = NO;
            [self zp_animationHint];
        }];
    }
}

- (void)zp_removeHandle {
    [self.textField resignFirstResponder];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end

@implementation ZZTextInput (TextField)

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (!_textValid) {
        [self zp_shakeLabel];
        return NO;
    }
    if (_delegateFlg.completeFlg) {
        [_delegate textInput:self completeEdit:textField.text];
    }
    [textField resignFirstResponder];
    [self zp_removeHandle];
    return YES;
}

- (void)zp_textChange:(UITextField *)textField {
    _textValid = YES;
    if (_inputVerifys) {
        for (NSDictionary *verifyDict in _inputVerifys) {
            _textValid = [textField.text isValidateRegularExpression:verifyDict[ZZRegExp]];
            if (!_textValid) {
                _hintStr = verifyDict[ZZMsg];
                break;
            }
        }
    } else if (_delegateFlg.validFlg) {
        NSString *validStr = [_delegate textInput:self checkTextValid:_textField.text];
        _textValid = !validStr.length;
        _hintStr = validStr;
    }
    [self zp_animationHint];
}

@end


@implementation ZZTextInput (Keyboard)

- (void)zp_keyboardWillShow:(NSNotification *)note {
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardHeight = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:duration animations:^{
        _textField.y = _originTextFieldY - keyboardHeight;
    } completion:^(BOOL finished) {
        [self zp_textChange:_textField];
    }];
}

- (void)zp_keyboardWillHide:(NSNotification *)note {
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        _textField.y = _originTextFieldY;
    } completion:nil];
}

@end

