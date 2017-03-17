//
//  ViewController.m
//  ZZTextInput
//
//  Created by Zhang_yD on 2017/3/17.
//  Copyright © 2017年 Z. All rights reserved.
//

#import "ViewController.h"
#import "ZZTextInput.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController () <ZZTextInputDelegate>

@property (nonatomic, weak) UIButton *button1;
@property (nonatomic, weak) UIButton *button2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button1 = [[UIButton alloc] init];
    [self.view addSubview:button1];
    button1.frame = CGRectMake(0, 20, ScreenWidth, (ScreenHeight - 20) / 2);
    button1.titleLabel.font = [UIFont systemFontOfSize:16];
    [button1 setTitle:@"使用inputVerifys" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(click1) forControlEvents:UIControlEventTouchUpInside];
    _button1 = button1;
    
    UIButton *button2 = [[UIButton alloc] init];
    [self.view addSubview:button2];
    button2.frame = CGRectMake(0, 20 + (ScreenHeight - 20) / 2, ScreenWidth, (ScreenHeight - 20) / 2);
    button2.titleLabel.font = [UIFont systemFontOfSize:16];
    [button2 setTitle:@"使用delegate" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchUpInside];
    _button2 = button2;
    
}

- (void)click1 {
    ZZTextInput *text = [[ZZTextInput alloc] init];
    text.delegate = self;
    text.preText = @"100";
    text.inputVerifys = @[@{ZZRegExp : @"^\\d{0,10}$",
                            ZZMsg : @"请输入10位以内的数字"}];
    [text show];
}

- (void)click2 {
    ZZTextInput *text = [[ZZTextInput alloc] init];
    text.delegate = self;
    [text show];
}

#pragma mark - ZZTextInputDelegate
- (void)textInput:(ZZTextInput *)textInput completeEdit:(NSString *)text {
    if ([text isEqualToString:@"999"]) {
        [_button2 setTitle:text forState:UIControlStateNormal];
    } else {
        [_button1 setTitle:text forState:UIControlStateNormal];
    }
}

- (NSString *)textInput:(ZZTextInput *)textInput checkTextValid:(NSString *)text {
    if (![text isEqualToString:@"999"]) return @"只能输入999";
    return nil;
}

@end
