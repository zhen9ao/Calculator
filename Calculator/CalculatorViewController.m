//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Gao Zheng on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userIsEnteredPeriod;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize calculation = _calculation;
@synthesize variables = _variables;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize userIsEnteredPeriod = _userIsEnteredPeriod;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (void)appendToCalculation:(NSString *)text 
{
//    self.calculation.text = [self.calculation.text stringByReplacingOccurrencesOfString:@" =" withString:@""];
//    self.calculation.text = [self.calculation.text stringByAppendingFormat:@"%@ ", text];
    self.calculation.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (void)synchronizeView
{
    id result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    
    if ([result isKindOfClass:[NSNumber class]]) self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];
    else self.display.text = result;
    
    self.calculation.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    
    self.variables.text = [[[[[[[self programVariables] description]
                               stringByReplacingOccurrencesOfString:@"{" withString:@""] 
                              stringByReplacingOccurrencesOfString:@"}" withString:@""] 
                             stringByReplacingOccurrencesOfString:@";" withString:@""] 
                            stringByReplacingOccurrencesOfString:@"\"" withString:@""] 
                           stringByReplacingOccurrencesOfString:@"<null>" withString:@"0"];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (NSDictionary *)programVariables
{
    NSArray *variableArray = [[CalculatorBrain variablesUsedInProgram:self.brain.program] allObjects];
    
    return [self.testVariableValues dictionaryWithValuesForKeys:variableArray];
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)variablePressed:(UIButton *)sender 
{
    [self.brain pushVariable:sender.currentTitle];
    [self synchronizeView];
}

- (IBAction)pointPressed 
{
    NSRange range = [self.display.text rangeOfString:@"."];
    if (range.location == NSNotFound) {
        self.display.text = [self.display.text stringByAppendingString:@"."];
    }
    self.userIsInTheMiddleOfEnteringANumber = YES;
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    [self.brain pushOperation:sender.currentTitle];
    self.userIsEnteredPeriod = YES;
    [self synchronizeView];
}

- (IBAction)enterPressed
{
    [self.brain pushOperand:[self.display.text doubleValue]];
//    [self appendToCalculation:self.display.text];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userIsEnteredPeriod = NO;
    [self synchronizeView];
}

- (IBAction)backspacePressed 
{
    self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
    if ([self.display.text isEqualToString:@""] ||
        [self.display.text isEqualToString:@"-"]) {
        self.display.text = @"0";
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
}

- (IBAction)undoPressed 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
        if ([self.display.text isEqualToString:@""] || [self.display.text isEqualToString:@"-"]) {
            [self synchronizeView];
        }
    } else {
        [self.brain removeLastItem];
        [self synchronizeView];
    }
}

- (IBAction)signChangePressed 
{ 
    self.display.text = [[NSNumber numberWithDouble:([self.display.text doubleValue] * -1)] stringValue];
}

- (IBAction)clearPressed {
    [self.brain empty];
    self.testVariableValues = nil;
    self.display.text = @"0";
    self.calculation.text = @"";
    self.variables.text = @"";
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)test1Pressed 
{
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithDouble:-4], @"x",
                               [NSNumber numberWithDouble:3], @"a",
                               [NSNumber numberWithDouble:4], @"b", nil];
    [self synchronizeView];
}

- (IBAction)test2Pressed 
{
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithDouble:-5], @"x", nil];
    [self synchronizeView];
}

- (IBAction)nilPressed 
{
    self.testVariableValues = nil;
    [self synchronizeView];
}


- (void)viewDidUnload 
{
    [super viewDidUnload];
}
@end
