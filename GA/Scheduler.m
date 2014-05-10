//
//  Scheduler.m
//  GA
//
//  Created by Yuri Ageev on 14.01.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import "Scheduler.h"
#import "Task.h"
#import "Processor.h"
#import "Person.h"

#define QUEUE_SIZE          100
#define POPULATION_SIZE     20
#define SELECTED_SIZE       10

#define GENERATION_LIMIT    100000

@interface Scheduler ()

@property (nonatomic, assign) NSUInteger generationNumber;
@property (nonatomic, strong) NSMutableArray *population;
@property (nonatomic, strong) NSMutableArray *selected;
@property (nonatomic, strong) NSMutableDictionary *fitnessHash;

@end

@implementation Scheduler

- (id)init
{
    self = [super init];
    if (self) {
        [self createTaskQueue];
    }
    
    return self;
}

- (void)run {

    [self createFirstGeneration];
    [self optimize];
    [self printResult];
    NSLog(@"END");
}

- (void)optimize {
    NSAssert(self.taskQueue.count > 0, @"LOL");
    
    BOOL isRunning = YES;
    
    while (self.generationNumber < GENERATION_LIMIT && isRunning) {
        
        [self crossover];

        [self selection];

        [self createNewGeneration];

        self.generationNumber++;
    }
}

- (void)createFirstGeneration {
    self.population = [[NSMutableArray alloc] init];
    self.generationNumber = 1;
    [self populate];
}

- (void)populate {
    for (int index = 0; index < POPULATION_SIZE; index++) {
        [self.population addObject:[self create]];
    }
}

- (Person *)create {
    /*
     
     Ген представляет собой экзепляр системы с 4 процессорами.
     Ниже имеющиеся задачи случайным образом распределяются между имеющимися процессорами.
     
     Алгоритм:
     1. из списка процессоров выбирается случайный процессор
     2. из очереди берется случайная задача
     3. если у процессора достаточно ресурсов для исполнения задачи, она ставится в его очередь и удаляется из общего списка
     иначе возвращение к п. 1
     
     
     */
    
    Person *gen = [[Person alloc] init];

    NSMutableArray *tasks = self.taskQueue.mutableCopy;
    NSInteger taskCount = tasks.count;
    while (taskCount != 0) {
        NSInteger proIndex = arc4random_uniform((unsigned int)gen.processors.count);
        Processor *pro = gen.processors[proIndex];
        
        NSInteger taskIndex = arc4random_uniform((unsigned int)taskCount);
        Task *task = tasks[taskIndex];
        
        if (pro.freeResourceSize >= task.requeredProcessResource) {
            [pro postTask:task];
            --taskCount;
            [tasks removeObject:task];
        }
    }
    
    return gen;
}

- (void)crossover {
    NSMutableArray *crossingResult = [NSMutableArray array];
    
    for (int index = 0; index < POPULATION_SIZE; index += 2) {
        Person *parent1 = self.population[index];
        Person *parent2 = self.population[index + 1];
        
        Person *child = [self crossingParent1:parent1 parent2:parent2];
        [crossingResult addObject:child];
    }
    
    for (int index = 0; index < crossingResult.count; index++) {
        [self.population replaceObjectAtIndex:index withObject:crossingResult[index]];
    }
}

- (Person *)crossingParent1:(Person *) parent1 parent2:(Person *) parent2 {
    
    Processor *pro1 = parent1.processors[parent1.fitProIndex];
    Processor *pro2 = parent2.processors[parent2.fitProIndex];
    
    Person *dominatedParent;
    Person *secondParent;
    
    Processor *dominatedGen;
    Processor *secondGen;
    
    if (pro1.loadedBy > pro2.loadedBy) {
        dominatedGen = pro2;
        dominatedParent = parent2;
        secondParent = parent1;
        secondGen = pro1;
    } else {
        dominatedGen = pro1;
        dominatedParent = parent1;
        secondParent = parent2;
        secondGen = pro2;
    }

    NSMutableArray *pros = [NSMutableArray arrayWithCapacity:4];
    
    pros[0] = dominatedGen;
    pros[1] = [[Processor alloc] init];
    pros[2] = [[Processor alloc] init];
    pros[3] = [[Processor alloc] init];;

    dominatedParent.processors = [NSArray arrayWithArray:pros];
    
    NSMutableArray *tasks = self.taskQueue.mutableCopy;
    NSInteger taskCount = tasks.count;
    
    while (taskCount != 0) {
       
        NSInteger proIndex = arc4random_uniform((unsigned int)dominatedParent.processors.count);

        if (proIndex == 0) continue;
        
        Processor *pro = dominatedParent.processors[proIndex];
        NSInteger taskIndex = arc4random_uniform((unsigned int)taskCount);
        Task *task = tasks[taskIndex];
        
        if ([dominatedGen.taskQueue containsObject:task]) {
            --taskCount;
            [tasks removeObject:task];
            continue;
        }
        
        NSUInteger nIndex = NSNotFound;
        
        if (proIndex + 1 < dominatedParent.processors.count) {
            nIndex = proIndex + 1;
        } else if (nIndex - 1 != 0) {
            nIndex = proIndex - 1;
        }
        
        if (nIndex != NSNotFound) {
            Processor *nPro = dominatedParent.processors[nIndex];
            
            if (nPro.loadedBy > pro.loadedBy) {
                if (pro.freeResourceSize >= task.requeredProcessResource) {
                    [pro postTask:task];
                    --taskCount;
                    [tasks removeObject:task];
                }
            } else {
                if (nPro.freeResourceSize >= task.requeredProcessResource) {
                    [nPro postTask:task];
                    --taskCount;
                    [tasks removeObject:task];
                }
            }
        } else {
            if (pro.freeResourceSize >= task.requeredProcessResource) {
                [pro postTask:task];
                --taskCount;
                [tasks removeObject:task];
            }
        }
    }
    
    return dominatedParent;
}

- (void)selection {
    self.selected = [NSMutableArray array];
    self.fitnessHash = [NSMutableDictionary dictionary];
    
    NSMutableArray *fintessResults = [NSMutableArray array];
    
    for (int index = 0; index < self.population.count; index++) {
        NSUInteger fitness = [self fitness:self.population[index]];
        NSNumber *fitnessKey = [NSNumber numberWithInteger:fitness];
        
        self.fitnessHash[fitnessKey] = self.population[index];
        [fintessResults addObject:fitnessKey];
    }
    
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [fintessResults sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    for (int index = 0; index < 10; index++) {
        [self.selected addObject:self.fitnessHash[fintessResults[index]]];
    }
}

- (void)createNewGeneration {
    self.population = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < POPULATION_SIZE; index++) {
        if (index < self.selected.count) {
            [self.population addObject:self.selected[index]];
        } else {
            Person *gen = [self create];
            [self fitness:gen];
            [self.population addObject:gen];
        }
    }
}

- (NSInteger)fitness: (Person *)gen{
    
    __block NSUInteger loadedBy = 0;
    [gen.processors enumerateObjectsUsingBlock:^(Processor *pro, NSUInteger idx, BOOL *stop) {
        if (loadedBy < pro.loadedBy) {
            loadedBy = pro.loadedBy;
            gen.fitProIndex = idx;
        }
    }];
    
    return loadedBy;
}

#pragma mark - Utils

- (void)createTaskQueue {
    self.taskQueue = [NSMutableArray array];
    
    Task *task = [[Task alloc] init];
    task.requeredProcessResource = 10;
    [self.taskQueue addObject:task];
    
    task = [[Task alloc] init];
    task.requeredProcessResource = 20;
    [self.taskQueue addObject:task];
    
    task = [[Task alloc] init];
    task.requeredProcessResource = 10;
    [self.taskQueue addObject:task];
    
    task = [[Task alloc] init];
    task.requeredProcessResource = 30;
    [self.taskQueue addObject:task];
    
    task = [[Task alloc] init];
    task.requeredProcessResource = 20;
    [self.taskQueue addObject:task];
    
    task = [[Task alloc] init];
    task.requeredProcessResource = 40;
    [self.taskQueue addObject:task];
    
    task = [[Task alloc] init];
    task.requeredProcessResource = 30;
    [self.taskQueue addObject:task];
    
    task = [[Task alloc] init];
    task.requeredProcessResource = 10;
    [self.taskQueue addObject:task];
    
    task = [[Task alloc] init];
    task.requeredProcessResource = 30;
    [self.taskQueue addObject:task];
    
    task = [[Task alloc] init];
    task.requeredProcessResource = 20;
    [self.taskQueue addObject:task];
}

- (void)printResult {
    NSLog(@"******************************");
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    for (int index = 0; index < self.population.count; index++) {
        [resultString appendFormat:@"%ld \n", (long)[self fitness:self.population[index]]];
    }
    
    NSLog(@"\nfitness\n%@", resultString);
}

@end
