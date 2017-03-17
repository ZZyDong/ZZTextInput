//
//  NSString+ZZTextInputExtension.m
//  ZZTextInput
//
//  Created by Zhang_yD on 2017/3/17.
//  Copyright © 2017年 Z. All rights reserved.
//

#import "NSString+ZZTextInputExtension.h"

@implementation NSString (ZZTextInputExtension)

- (BOOL)isValidateRegularExpression:(NSString *)re {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
    return [predicate evaluateWithObject:self];
}

@end
