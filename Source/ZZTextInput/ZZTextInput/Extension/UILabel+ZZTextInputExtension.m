//
//  UILabel+ZZTextInputExtension.m
//  ZZTextInput
//
//  Created by Zhang_yD on 2017/3/17.
//  Copyright © 2017年 Z. All rights reserved.
//

#import "UILabel+ZZTextInputExtension.h"

@implementation UILabel (ZZTextInputExtension)

- (CGSize)labelSize {
    return  [self.text sizeWithAttributes:@{NSFontAttributeName : self.font}];
}

- (CGFloat)labelWidth {
    return self.labelSize.width;
}
- (CGFloat)labelHeight {
    return self.labelSize.height;
}

@end
