//
//  main.m
//  blockTest
//
//  Created by Yans on 16/6/3.
//  Copyright © 2016年 Yans. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 始终能够正常运行
 这个例子可以正常运行，存在exampleA中的栈只有在block停止执行之后才会被释放。
 因为不管这个block是由系统分配到栈还是手动分配到堆中，都可以执行。
 */
void exampleA() {
    char a = 'A';
    ^{
        NSLog(@"%c",a);
    }();
}

/*
 只有在使用ARC的情况下才能正常运行
 如果不使用ARC或者手动copy，这个block是个栈块，分配到exampleB_addBlockToArray()栈上。
 而当它执行exampleB中执行时，由于栈被清空，block不再有效。
 */
void exampleB_addBlockToArray(NSMutableArray *array) {
    char b = 'B';
    [array addObject:[^{
        NSLog(@"%c",b);
    } copy]];
}

void exampleB() {
    NSMutableArray *array = [NSMutableArray new];
    exampleB_addBlockToArray(array);
    void (^blockB)() = [array objectAtIndex:0];
    blockB();
}

/*
 始终能够正常运行
 由于block在自己的环路中不捕获任何变量，它不需要在运行的时候设置state.
 它会作为一个全局块编译，它既不在栈也不在堆，而是代码片段的一部分。所以它始终执行。
 */
void exampleC_addBlockToArray(NSMutableArray *array) {
    [array addObject:^{
        NSLog(@"C");
    }];
}

void exampleC() {
    NSMutableArray *array = [NSMutableArray array];
    exampleC_addBlockToArray(array);
    void (^block)() = [array objectAtIndex:0];
    block();
}

/*
 只有在使用ARC的情况下才能正常运行
 如果不使用ARC，block是一个栈块，会分配在exampleD_getBlock()的栈上。然后当功能返回的时候会立即失效。
 然而，以这个例子来说，这个错误非常明显，所以编译器进行编译会失败。
 错误提示是：error: returning block that lives on the local stack（错误，返回的block位于本地的栈）。
 */
typedef void (^dBlock)();

dBlock exampleD_getBlock() {
    char d = 'D';
    return ^{
        NSLog(@"%c\n", d);
    };
}


void exampleD() {
    exampleD_getBlock()();
}

/*
 只有在使用ARC的情况下才能正常运行
 这个例子和例子4类似，除了编译器没有认出有错误，所以代码会进行编译然后崩溃。
 更糟糕的是，这个例子比较特别，如果你关闭了优化，则可以正常运行。所以在测试的时候需要注意。
 */
typedef void (^eBlock)();

eBlock exampleE_getBlock() {
    char e = 'E';
    void (^block)() = ^{
        NSLog(@"%c\n", e);
    };
    return block;
}

void exampleE() {
    eBlock block = exampleE_getBlock();
    block();
}
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        exampleA();
        exampleB();
        exampleC();
        exampleD();
        exampleE();
        
        void (^print)(NSString *string) = ^(NSString *string){
            NSLog(@"PRINT:%@",string);
        };
        print(@"string");
        
    }
    return 0;
}
