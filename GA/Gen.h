//
//  Gen.h
//  GA
//
//  Created by Yuri Ageev on 15.01.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gen : NSObject

@property (nonatomic, strong) NSArray *genes;

@property (nonatomic, assign) NSInteger leftHalf;
@property (nonatomic, assign) NSInteger rightHalf;

@property (nonatomic, strong) NSArray *processors;

@property (nonatomic, assign) NSUInteger fitProIndex;

@end
