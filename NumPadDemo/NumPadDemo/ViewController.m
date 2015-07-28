//
//  ViewController.m
//  NumPadDemo
//
//  Created by Jeffrey Berthiaume on 7/8/15.
//  Copyright (c) 2015 Pushplay.net. All rights reserved.
//

#import "ViewController.h"
#import "NumPad.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [NumPad setKeyboardFor:self.amountTextField withDecimal:YES andCalculator:YES maxCharacters:8];
    self.amountTextField.tag = 1;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark Switch methods for testing functionality

-(IBAction)toggleDecimal:(UISwitch *)sender {
    NumPad *numpad = (NumPad *)self.amountTextField.inputView;
    [numpad enableDecimalEntry:sender.on];
}

-(IBAction)toggleCalculator:(UISwitch *)sender {
    NumPad *numpad = (NumPad *)self.amountTextField.inputView;
    [numpad enableCalculator:sender.on];
}

-(IBAction)toggleDone:(UISwitch *)sender {
    NumPad *numpad = (NumPad *)self.amountTextField.inputView;
    if (sender.on)
        [numpad setCompletionButtonsToPrevNext];
    else
        [numpad setCompletionButtonsToDone];
}

@end
