//
//  Numpad.h
//  NumPad
//
//  Created by Jeffrey Berthiaume on 7/8/15.
//  Copyright (c) 2015 Pushplay.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumPad : UIView

+(void) setKeyboardFor:(UITextField *)textField;
+(void) setKeyboardFor:(UITextField *)textField withDecimal:(BOOL)dec andCalculator:(BOOL)calc maxCharacters:(NSInteger)maxCharacters;

-(void) setButtonTitleForTop:(NSString *)str;
-(void) setButtonTitleForBottom:(NSString *)str;

-(void) setCompletionButtonsToDone;
-(void) setCompletionButtonsToPrevNext;

-(void) setClearButtonToAllClear;
-(void) setClearButtonToBackspace;

-(void) enableDecimalEntry:(BOOL)enableDecimal;
-(void) enableCalculator:(BOOL)enableCalculator;

@end
