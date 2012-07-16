//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Gao Zheng on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushOperation:(NSString *)operation;
- (id)performOperation:(NSString *)operation;
- (void)pushVariable:(NSString *)variable;
- (void)empty;
- (void)removeLastItem;

@property (readonly) id program;

+ (id)runProgram:(id)program;
+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;

@end
