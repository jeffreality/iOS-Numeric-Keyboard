//
//  Numpad.m
//  NumPad
//
//  Created by Jeffrey Berthiaume on 7/8/15.
//  Copyright (c) 2015 Pushplay.net. All rights reserved.
//

#import "NumPad.h"

@interface NumPad ()

typedef enum {
    calculatorAdd       = 1,
    calculatorSubtract  = 2,
    calculatorMultiply  = 3,
    calculatorDivide    = 4
} calculatorOperations;

@property (nonatomic, strong) UIView      *contentView;
@property (nonatomic, strong) UIView      *keyline1;
@property (nonatomic, strong) UIView      *keyline2;
@property (nonatomic, strong) UIButton    *keyBack;
@property (nonatomic, strong) UIButton    *keyPeriod;
@property (nonatomic, strong) UIButton    *keyFunctionTop;
@property (nonatomic, strong) UIButton    *keyFunctionBottom;

@property (nonatomic, assign) UITextField *textField;
@property (nonatomic, strong) NSNumber    *characterMax;

@property (nonatomic, strong) NSNumber    *calculatorDisplay;
@property (nonatomic, strong) NSNumber    *clearShouldBackspace;

@property (nonatomic, strong) NSNumber    *previousTotal;
@property (nonatomic, strong) NSNumber    *operation;
@property (nonatomic, strong) NSNumber    *operationClear;

@end

@implementation NumPad

#define RGB(r,g,b)                              [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define DEVICE_WIDTH                            [[UIScreen mainScreen] bounds].size.width
#define DEVICE_HEIGHT                           [[UIScreen mainScreen] bounds].size.height

+(void) setKeyboardFor:(UITextField *)textField withDecimal:(BOOL)dec andCalculator:(BOOL)calc maxCharacters:(NSInteger)maxCharacters {
    NumPad *numpad = [[NumPad alloc] init];
    numpad.textField = textField;
    if (maxCharacters > 0)
        numpad.characterMax = @(maxCharacters);
    else
        numpad.characterMax = nil;
    textField.inputView = numpad;
    
    [numpad enableDecimalEntry:dec];
    [numpad enableCalculator:calc];
}

+(void) setKeyboardFor:(UITextField *)textField {
    // commonly used shortcut
    [NumPad setKeyboardFor:textField withDecimal:NO andCalculator:NO maxCharacters:0];
}

- (id) init {
    self = [super init];
    if (self) {
        self.keyline1 = [[UIView alloc] init];
        self.keyline1.backgroundColor = RGB( 48,  50,  54);
        [self addSubview:self.keyline1];
        
        self.keyline2 = [[UIView alloc] init];
        self.keyline2.backgroundColor = RGB(191, 191, 191);
        [self addSubview:self.keyline2];
        
        [self enableDecimalEntry:NO];
        [self enableCalculator:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

-(void) checkMaxKeysPressed {
    if (self.characterMax && self.textField.text.length > [self.characterMax longValue]) {
        self.textField.text = [self.textField.text substringToIndex:self.textField.text.length-(self.textField.text.length>0)];
    }
}

-(void) keyClearAction {
    if ([self.clearShouldBackspace isEqual:@YES]) {
        if(self.textField.text.length > 0)
            self.textField.text = [self.textField.text substringToIndex:self.textField.text.length-1];
    } else {
        self.textField.text = @"";
        self.operation = nil;
        self.previousTotal = nil;
    }
}

-(void) keyFunctionTopAction {
    NSInteger prevTag = self.textField.tag - 1;
    if (prevTag < 0)
        prevTag = 0;
    
    // Try to find next responder
    UIResponder *nextResponder = [self.textField.superview viewWithTag:prevTag];
    if (nextResponder && ![self.textField.superview viewWithTag:prevTag].hidden) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so do nothing
    }
    
}

-(void) keyFunctionBottomAction {
    NSInteger nextTag = self.textField.tag + 1;
    // Try to find next responder
    UIResponder *nextResponder = [self.textField.superview viewWithTag:nextTag];
    if (nextResponder && ![self.textField.superview viewWithTag:nextTag].hidden) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [self.textField resignFirstResponder];
    }
    
}

-(void) keyPeriodAction {
    if ([self.operationClear isEqual:@YES]) {
        self.textField.text = @"";
        self.operationClear = @NO;
    }
    if(!self.textField.text || [self.textField.text isEqualToString:@""])
        self.textField.text = @"0";
    
    if([self.textField.text isEqualToString:@"-"])
        self.textField.text = @"-0";
    
    self.textField.text = [self.textField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    self.textField.text = [self.textField.text stringByAppendingString:@"."];
    
    [self checkMaxKeysPressed];
}

-(void) keyNumberAction:(UIButton*)sender{
    if ([self.operationClear isEqual:@YES]) {
        self.textField.text = @"";
        self.operationClear = @NO;
    }
    self.textField.text = [self.textField.text stringByAppendingString:sender.titleLabel.text];
    
    [self checkMaxKeysPressed];
}

-(void) keyEqual {
    if (self.previousTotal)
        switch ([self.operation longValue]) {
            case calculatorAdd:
                self.textField.text = [@([self.previousTotal floatValue] + [self.textField.text floatValue]) stringValue];
                break;
            case calculatorSubtract:
                self.textField.text = [@([self.previousTotal floatValue] - [self.textField.text floatValue]) stringValue];
                break;
            case calculatorMultiply:
                self.textField.text = [@([self.previousTotal floatValue] * [self.textField.text floatValue]) stringValue];
                break;
            case calculatorDivide:
                if ([self.textField.text integerValue] != 0)
                    self.textField.text = [@([self.previousTotal floatValue] / [self.textField.text floatValue]) stringValue];
                else
                    self.textField.text = @"0"; // technically, NAN; for all practical purposes, 0 is fine so we can keep the field numeric only
                break;
                
            default:
                break;
        }
    
    if ([self.characterMax longValue] > 0 && [self.textField.text length] > [self.characterMax longValue]) {
        // trim the value
        self.textField.text = [@"" stringByPaddingToLength:[self.characterMax longValue] withString:@"9" startingAtIndex:0];
    }
    
    self.previousTotal = nil;
    self.operation = nil;
}

-(void) keyOperation:(calculatorOperations)operation {
    if (self.operation && self.operationClear) {
        // they hit a different operation, may want to override
        // i.e. 3+*2 -> 3*2
        self.operation = @(operation);
        self.operationClear = @YES;
        return;
    }
    
    if (self.operation)
        [self keyEqual];
    if (![self.textField.text isEqualToString:@""])
        self.previousTotal = @([self.textField.text floatValue]);
    self.operation = @(operation);
    self.operationClear = @YES;
}

-(void) keyAdd {
    [self keyOperation:calculatorAdd];
}

-(void) keySubtract {
    if ([self.operationClear isEqual:@YES]) {
        // minus
        self.textField.text = @"-";
        self.operationClear = @NO;
    } else
        // subtract
        [self keyOperation:calculatorSubtract];
}

-(void) keyMultiply {
    [self keyOperation:calculatorMultiply];
}

-(void) keyDivide {
    [self keyOperation:calculatorDivide];
}

-(void) setButtonTitleForTop:(NSString *)str {
    [self.keyFunctionTop setTitle:str forState:UIControlStateNormal];
}

-(void) setButtonTitleForBottom:(NSString *)str {
    [self.keyFunctionBottom setTitle:str forState:UIControlStateNormal];
}

-(void) setCompletionButtonsToDone {
    self.keyFunctionTop.hidden = YES;
    [self setButtonTitleForBottom:@"Done"];
}

-(void) setCompletionButtonsToPrevNext {
    self.keyFunctionTop.hidden = NO;
    [self setButtonTitleForTop:@"Prev"];
    [self setButtonTitleForBottom:@"Next"];
}

-(void) enableDecimalEntry:(BOOL)enableDecimal {
    if (enableDecimal)
        self.keyPeriod.hidden = NO;
    else
        self.keyPeriod.hidden = YES;
}

-(void) enableCalculator:(BOOL)enableCalculator {
    if (enableCalculator) {
        self.calculatorDisplay = @YES;
        [self setClearButtonToAllClear];
    } else {
        self.calculatorDisplay = @NO;
        [self setClearButtonToBackspace];
    }
    [self centerPad]; // redraw the display
}

-(void) setClearButtonToAllClear {
    self.clearShouldBackspace = @NO;
    [self.keyBack setTitle:@"Clear" forState:UIControlStateNormal];
}

-(void) setClearButtonToBackspace {
    self.clearShouldBackspace = @YES;
    [self.keyBack setTitle:@"⌫ " forState:UIControlStateNormal];
}

-(UIButton *) createButtonWithTitle:(NSString *)title andPosition:(CGPoint)buttonSize {
    float ratio = 1.0f;
    
    if (DEVICE_WIDTH > DEVICE_HEIGHT)
        ratio = 12.0f;
    else
        ratio = 8.0f;
    
    float buttonWidth = self.bounds.size.width / ratio;
    float buttonHeight = buttonWidth / 1.7f;
    float margin = buttonWidth / 6.0f;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(margin + buttonSize.x * (buttonWidth + margin), margin + buttonSize.y * (buttonHeight + margin), buttonWidth, buttonHeight);
    [btn setTitle:title forState:UIControlStateNormal];
    
    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    if ([title length] == 1)
        btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:buttonHeight];
    else
        btn.titleLabel.font = [UIFont fontWithName:@"AlNile-Bold" size:buttonWidth - margin];
    [btn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.shadowOffset = CGSizeMake(1.0f, 1.0f);
    [self.contentView addSubview:btn];
    
    return (btn);
}

-(void) layoutKeys {
    
    if (self.contentView) {
        [self.contentView removeFromSuperview];
        self.contentView = nil;
    }
    
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    
    NSArray *numbers = @[@7, @8, @9, @4, @5, @6, @1, @2, @3, @0];
    
    if ([self.calculatorDisplay isEqual:@NO]) {
        numbers = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @0];
    }
    
    for (NSInteger j = 0; j < [numbers count]; j++) {
        float x = j % 3;
        float y = j / 3;
        UIButton *btn = [self createButtonWithTitle:[[numbers objectAtIndex:j] stringValue] andPosition:CGPointMake(x, y)];
        
        [btn addTarget:self action:@selector(keyNumberAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSInteger calculatorIndex = 0;
    if ([self.calculatorDisplay isEqual:@YES]) {
        
        // add calc buttons here
        
        calculatorIndex = 1;
        
        UIButton *btn;
        btn = [self createButtonWithTitle:@"÷" andPosition:CGPointMake(3, 0)];
        [btn addTarget:self action:@selector(keyDivide) forControlEvents:UIControlEventTouchUpInside];
        
        btn = [self createButtonWithTitle:@"×" andPosition:CGPointMake(3, 1)];
        [btn addTarget:self action:@selector(keyMultiply) forControlEvents:UIControlEventTouchUpInside];
        
        btn = [self createButtonWithTitle:@"−" andPosition:CGPointMake(3, 2)];
        [btn addTarget:self action:@selector(keySubtract) forControlEvents:UIControlEventTouchUpInside];
        
        btn = [self createButtonWithTitle:@"+" andPosition:CGPointMake(3, 3)];
        [btn addTarget:self action:@selector(keyAdd) forControlEvents:UIControlEventTouchUpInside];
        
        btn = [self createButtonWithTitle:@"=" andPosition:CGPointMake(2, 3)];
        [btn addTarget:self action:@selector(keyEqual) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    self.keyPeriod = [self createButtonWithTitle:@"." andPosition:CGPointMake(1, 3)];
    
    self.keyBack = [self createButtonWithTitle:[self.keyBack titleForState:UIControlStateNormal] andPosition:CGPointMake(3 + calculatorIndex, 0)];
    
    self.keyFunctionTop = [self createButtonWithTitle:@"Prev" andPosition:CGPointMake(3 + calculatorIndex, 2)];
    self.keyFunctionBottom = [self createButtonWithTitle:@"Next" andPosition:CGPointMake(3 + calculatorIndex, 3)];
    
    [self.keyBack addTarget:self action:@selector(keyClearAction) forControlEvents:UIControlEventTouchUpInside];
    [self.keyPeriod addTarget:self action:@selector(keyPeriodAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.keyFunctionTop addTarget:self action:@selector(keyFunctionTopAction) forControlEvents:UIControlEventTouchUpInside];
    [self.keyFunctionBottom addTarget:self action:@selector(keyFunctionBottomAction) forControlEvents:UIControlEventTouchUpInside];
    
    // set contentView frame to only encompass buttons
    
    float ratio = 1.0f;
    
    if (DEVICE_WIDTH > DEVICE_HEIGHT)
        ratio = 12.0f;
    else
        ratio = 8.0f;
    
    float buttonWidth = self.bounds.size.width / ratio;
    float buttonHeight = buttonWidth / 1.7f;
    float margin = buttonWidth / 6.0f;
    
    self.contentView.frame = CGRectMake(0, 0, margin * 2 + (4 + calculatorIndex) * (buttonWidth + margin), margin * 2 + 4 * (buttonHeight + margin));
    
    [self addSubview:self.contentView];
}

-(void) centerPad {
    // center the pad in the middle of the screen
    // to be called when orientation changes
    self.frame = CGRectMake(0.0, 0.0, DEVICE_WIDTH, DEVICE_HEIGHT * 0.4f);
    self.keyline1.frame = CGRectMake(0, 0, DEVICE_WIDTH, 1);
    self.keyline2.frame = CGRectMake(0, 1, DEVICE_WIDTH, 1);
    
    [self layoutKeys];
    
    self.contentView.center = self.center;
}

- (void) didRotate:(NSNotification *)notification {
    [self centerPad];
}

@end
