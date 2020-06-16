//
//  O2SECFieldElementFp.m
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import "O2SECFieldElementFp.h"
#import "O2SECCurveFp.h"
#import "O2SECPointFp.h"
#import "O2SBigInt.h"

@interface O2SECFieldElementFp ()

@property (nonatomic, weak) O2SBigInt *q;
@property (nonatomic, strong) O2SBigInt *x;

@end

@implementation O2SECFieldElementFp


- (instancetype)initWithQ:(O2SBigInt *)q x:(O2SBigInt *)x
{
    if (self = [super init])
    {
        self.q = q;
        self.x = x;
    }
    return self;
}

/// 判断相等
/// @param other .
- (BOOL)equals:(O2SECFieldElementFp *)other
{
    @autoreleasepool {
        if (self == other)
        {
            return YES;
        }
        
        return ([self.q compare:other.q] == NSOrderedSame &&
                [self.x compare:other.x] == NSOrderedSame);
    }
    
}

/// 返回具体数值
- (O2SBigInt *)toBigInteger
{
    return self.x;
}

/// 取反
- (O2SECFieldElementFp *)negate
{
    @autoreleasepool {
        return [[O2SECFieldElementFp alloc] initWithQ:self.q x:[[self.x negate] modByBigInt:self.q]];
    }
}

/// 相加
/// @param b .
- (O2SECFieldElementFp *)add:(O2SECFieldElementFp *)b
{
    @autoreleasepool {
        O2SBigInt *tmp = [b toBigInteger];
        return [[O2SECFieldElementFp alloc] initWithQ:self.q x:[[self.x addByBigInt:tmp] modByBigInt:self.q]];
    }
}

/// 相减
/// @param b .
- (O2SECFieldElementFp *)subtract:(O2SECFieldElementFp *)b
{
    @autoreleasepool {
        O2SBigInt *tmp = [b toBigInteger];
        return [[O2SECFieldElementFp alloc] initWithQ:self.q x:[[self.x subByBigInt:tmp] modByBigInt:self.q]];
    }
}


/// 相乘
/// @param b .
- (O2SECFieldElementFp *)multiply:(O2SECFieldElementFp *)b
{
    @autoreleasepool {
        O2SBigInt *tmp = [b toBigInteger];
        return [[O2SECFieldElementFp alloc] initWithQ:self.q x:[[self.x multiplyByBigInt:tmp] modByBigInt:self.q]];
    }
}

/// 相除
/// @param b .
- (O2SECFieldElementFp *)divide:(O2SECFieldElementFp *)b
{
    @autoreleasepool {
        O2SBigInt *tmp = [[b toBigInteger] modInverseByBigInt:self.q];
        return [[O2SECFieldElementFp alloc] initWithQ:self.q x:[[self.x multiplyByBigInt:tmp] modByBigInt:self.q]];
    }
}

/// 平方
- (O2SECFieldElementFp *)square
{
    @autoreleasepool {
        return [[O2SECFieldElementFp alloc] initWithQ:self.q x:[[self.x square] modByBigInt:self.q]];
    }
}


#pragma mark - 点压缩 (y^2) mod n = a mod n,求y
// https://blog.csdn.net/qq_41746268/article/details/98730749
//对于给定的奇质数p，和正整数x,存在y满足1≤y≤p−1，且x≡y^2(mod p)x，则称y为x的模平方根
//对于正整数m,若同余式,若同余式x^2≡a(mod m)有解，则称a为模m的平方剩余，否则称为模m平方非剩余。
//是否存在模平方根
//根据欧拉判别条件:
//设p是奇质数，对于x^2≡a(mod p)
//a是模p的平方剩余的充要条件是(a^((p−1)/2)) % p = 1
//a是模p的平方非剩余的充要条件是(a^((p−1)/2)) % p = -1
//给定a,na,na,n(n是质数)，求x^2≡a(mod n)的最小整数解x
//代码复杂度O(log2(n))

///平方根
- (O2SECFieldElementFp *)modsqrt
{
    @autoreleasepool {
        O2SBigInt *b,*i,*k,*y;
        
        O2SBigInt *n = _q;
        O2SBigInt *a = _x;
        //n==2
        if ([n compare:[[O2SBigInt alloc] initWithInt:2]] == NSOrderedSame)
        {
            //a%n
            return [[O2SECFieldElementFp alloc] initWithQ:self.q x:[a modByBigInt:n]];
        }
        //qpow(a,(n-1)/2,n) == 1
        if ([[self _qpow:a b:[[n subByInt:1] divideByInt:2] p:n] compare:O2SBigInt.one] == NSOrderedSame)
        {
            //n%4 == 3
            if ([[n modByInt:4] compare:[[O2SBigInt alloc] initWithInt:3]] == NSOrderedSame)
            {
                //y=qpow(a,(n+1)/4,n)
                y = [self _qpow:a b:[[n addByInt:1] divideByInt:4] p:n];
            }
            else
            {
                //for(b=1,qpow(b,(n-1)/2,n) == 1,b++)
                for (b = O2SBigInt.one; [[self _qpow:b b:[[n subByInt:1] divideByInt:2] p:n] compare:O2SBigInt.one] == NSOrderedSame;)
                {
                    b = [b addByInt:1];
                }
                //i=(n-1)/2
                i = [[n subByInt:1] divideByInt:2];
                //k=0
                k = O2SBigInt.zero;
                //while(i%2==0)
                while ([[i modByInt:2] compare:O2SBigInt.zero] == NSOrderedSame)
                {
                    //i /= 2
                    i = [i divideByInt:2];
                    //k /= 2
                    k = [k divideByInt:2];
                    //t1=qpow(a,i,n)
                    O2SBigInt *t1 = [self _qpow:a b:i p:n];
                    //t2=qpow(b,k,n)
                    O2SBigInt *t2 = [self _qpow:b b:k p:n];
                    //(t1*t2+1)%n == 0
                    if ([[[[t1 multiplyByBigInt:t2] addByInt:1] modByBigInt:n] compare:O2SBigInt.zero] == NSOrderedSame)
                    {
                        //k+=(n-1)/2
                        k = [k addByBigInt:[[n subByInt:1] divideByInt:2]];
                    }
                }
                //tt1=qpow(a,(i+1)/2,n)
                O2SBigInt *tt1 = [self _qpow:a b:[[i addByInt:1] divideByInt:2] p:n];
                //tt2=qpow(b,k/2,n)
                O2SBigInt *tt2 = [self _qpow:b b:[k divideByInt:2] p:n];
                //y=tt1*tt2%n
                y = [[tt1 multiplyByBigInt:tt2] modByBigInt:n];
            }
            //y*2>n
            if ([[y multiplyByInt:2] compare:n] == NSOrderedDescending)
            {
                //y = n - y
                y = [n subByBigInt:y];
            }
            return [[O2SECFieldElementFp alloc] initWithQ:self.q x:y];
        }
        return [[O2SECFieldElementFp alloc] initWithQ:self.q x:[[O2SBigInt alloc] initWithInt:-1]];
    }
}

- (O2SBigInt *)_qpow:(O2SBigInt *)a b:(O2SBigInt *)b p:(O2SBigInt *)p
{
    @autoreleasepool {
        O2SBigInt *ans = O2SBigInt.one;
        //b != 0
        while ([b compare:O2SBigInt.zero] != NSOrderedSame)
        {
            //b&1
            if ([[b bitwiseAndByBigInt:O2SBigInt.one] compare:O2SBigInt.zero] != NSOrderedSame)
            {
                //ans = ans*a%p
                ans = [[ans multiplyByBigInt:a] modByBigInt:p];
            }
            //a=a*a%p
            a = [[a multiplyByBigInt:a] modByBigInt:p];
            //b>>=1
            b = [b shiftRight:1];
        }
        return ans;
    }
}

@end
