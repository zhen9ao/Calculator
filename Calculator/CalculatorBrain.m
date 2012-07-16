//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Gao Zheng on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain ()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

- (void)pushOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (id)program 
{
    return [self.programStack copy];
}

- (void)empty {
    self.programStack = nil;
}

- (void)removeLastItem
{
    [self.programStack removeLastObject];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"stack = %@", self.programStack];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    if (![program isKindOfClass:[NSArray class]]) return @"Invalid program!";
    
    NSMutableArray *stack = [program mutableCopy];
    NSMutableArray *expressionArray = [NSMutableArray array];
    
    while (stack.count > 0) {
        [expressionArray addObject:[self deBracket:[self descriptioOfTopOfStack:stack]]];
    }
    
    return [expressionArray componentsJoinedByString:@","];
}

+ (NSString *)descriptioOfTopOfStack:(NSMutableArray *)stack
{
    NSString *description;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject]; else return @"";
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        return [topOfStack description];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        if (![self isOperation:topOfStack] || 
            [self isNoOperandOperation:topOfStack]) {
            description = topOfStack;
        } else if ([self isOneOperandOperation:topOfStack]) {
            NSString *x = [self deBracket:[self descriptioOfTopOfStack:stack]];
            description = [NSString stringWithFormat:@"%@(%@)", topOfStack, x];
        } else if ([self isTwoOperandOperation:topOfStack]) {
            NSString *x = [self descriptioOfTopOfStack:stack];
            NSString *y = [self descriptioOfTopOfStack:stack];
            
            if ([topOfStack isEqualToString:@"+"] ||
                [topOfStack isEqualToString:@"-"]) {
                description = [NSString stringWithFormat:@"(%@ %@ %@)",
                               [self deBracket:x], topOfStack, [self deBracket:y]];
            } else {
                description = [NSString stringWithFormat:@"%@ %@ %@",
                               x, topOfStack, y];
            }
        }
    }
    
    return description;
}

+ (NSString *)deBracket:(NSString *)expression
{
    NSString *description = expression;
    
    if ([expression hasPrefix:@"("] && [expression hasSuffix:@")"]) {
        description = [description substringFromIndex:1];
        description = [description substringToIndex:[description length] -1];
    }
    
    NSRange openBracket = [description rangeOfString:@"("];
    NSRange closeBracket = [description rangeOfString:@")"];
    
    if (openBracket.location >= closeBracket.location) return expression;
    else return description;
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfTheStack = [stack lastObject];
    if (topOfTheStack) [stack removeLastObject];
    
    if ([topOfTheStack isKindOfClass:[NSNumber class]]) {
        result = [topOfTheStack doubleValue];
    } else if ([topOfTheStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfTheStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        } else if ([@"/" isEqualToString:operation]) {
            double divider = [self popOperandOffStack:stack];
            if (divider) {
                result = [self popOperandOffStack:stack] / divider;
            } else {
                result = 0;
            }
        } else if ([@"-" isEqualToString:operation]) {
            double second = [self popOperandOffStack:stack];
            double first = [self popOperandOffStack:stack];
            result = first - second;
        } else if ([@"sin" isEqualToString:operation]) {
            result = sin([self popOperandOffStack:stack]);
        } else if ([@"cos" isEqualToString:operation]) {
            result = cos([self popOperandOffStack:stack]);
        } else if ([@"sqrt" isEqualToString:operation]) {
            result = sqrt([self popOperandOffStack:stack]);
        } else if ([@"PI" isEqualToString:operation]) {
            result = M_PI;
        } else if ([@"log" isEqualToString:operation]) {
            result = log([self popOperandOffStack:stack]);
        } else if ([@"±" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack] * -1;
        }    
    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack = nil;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    for (int i = 0; i < [stack count]; i++) {
        id obj = [stack objectAtIndex:i];
        
        if ([obj isKindOfClass:[NSString class]] && ![self isOperation:obj]) {
            id value = [variableValues valueForKey:obj];
            
            if (![value isKindOfClass:[NSNumber class]]) {
                value = [NSNumber numberWithInt:0];
            }
            
            [stack replaceObjectAtIndex:i withObject:value];
        }
    }
    
    return [self popOperandOffStack:stack];
}

+ (BOOL)isNoOperandOperation:(NSString *)operation
{
    NSSet *operationSet = [NSSet setWithObjects:@"PI", nil];
    
    return [operationSet containsObject:operation];
}

+ (BOOL)isOneOperandOperation:(NSString *)operation
{
    NSSet *operationSet = [NSSet setWithObjects:@"sin",@"cos",@"sqrt",@"log", @"±", nil];

    return [operationSet containsObject:operation];
}

+ (BOOL)isTwoOperandOperation:(NSString *)operation
{
    NSSet *operationSet = [NSSet setWithObjects:@"+",@"-",@"*",@"/", nil];
    
    return [operationSet containsObject:operation];
}

+ (BOOL)isOperation:(NSString *)operation
{
    return 
    [self isNoOperandOperation:operation] || 
    [self isOneOperandOperation:operation] || 
    [self isTwoOperandOperation:operation];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet *variables = nil;
    
    if ([program isKindOfClass:[NSArray class]]) variables = [NSMutableSet set];
    
    for (id obj in program) {
        if ([obj isKindOfClass:[NSString class]] && ![self isOperation:obj]) {
            [variables addObject:obj];
        }
    }
    
    if ([variables count] == 0) return nil; else return [variables copy];
}

@end
