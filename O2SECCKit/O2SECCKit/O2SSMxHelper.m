//
//  O2SSMxHelper.m
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import "O2SSMxHelper.h"
#import "O2SBigInt.h"
#import "O2SSM2Cipher.h"
#import "O2SECPointFp.h"
#import "O2SSM2Cipher+Private.h"
#import "O2SSMxUtils.h"
#import "O2SECFieldElementFp.h"
#import "O2SSM3Digest.h"

//无论RSA还是SM2，加解密问题，一切都归于数学问题，涉及“大数“运算，字符串可以用“大数”表示，加解密无非就是 ”大数“变成另一个”大数“
//一个字符串NSString(如"hello world") 转成 NSData，NSData转换成 16进制的字符串(如"68656C6C6F20776F726C64")，这个l6进制字符串就是一个16进制”大数“
//大数运算 如："C8" + "A3" = "016B"
//
//SM2 加解密
//备注：椭圆曲线坐标点运算 详情EC_Fp
//注：这里的坐标点如G点，Q点及椭圆曲线生成的点当作大数处理 如：规定每个点为16进制4位{"00ff","f840"}那么值就是“00fff840”,之后通过位数重新切分成点
//1、选定一条椭圆曲线Ep(a,b) 并取椭圆曲线上一点，作为基点G
//2、选择一个大数k作为私钥，并生成公钥 Q = kG
//3、Ep(a,b)和n、G点、Q点提供给客户端这几个参数经过ASN.1编码生成der即为"公钥" 备注：der不一定明确的含Ep(a,b)和G点的值，Q值一定有，根据内部类型值也可确定椭圆曲线
//4、Ep(a,b)和n、G点、k值提供给服务端这几个参数经过ASN.1编码生成der即为"私钥" 备注：der不一定明确的含Ep(a,b)和G点及Q点的值，k值一定有，根据内部类型值也可确定椭圆曲线，"私钥"信息包含“公钥”，Q = kG 计算得到，
//      一般提供的der文件密钥可通过https://aks.jd.com/tools/sec/ ASN.1在线解析工具获取相关的p、a、b、G点、n的值以及Q点或k
//5、加解密原理解释例子：
//  M为明文,r是随机一个“大数” C1 = rG，C1为随机点，Q为公钥点,C2 = M⊕rQ (实际为 C2 = M⊕KDF(rQ,ml) 看：♦️)， r∈[1，n-1]
//  公钥加密：密文C是C1,C2,C3组合的字节流 C = C1+C2+C3,
//  私钥解码：求M ∵ 已知 C1 = rG,C2 = M⊕rQ,Q = kG, C1 = rG
//              ∵ 椭圆曲线特性(Fp域内运算满足交换律、结合律、分配律) rQ = r(kG) = k(rG) = kC1
//              ∴ 结果：rQ = kC1
//              ∵ M = (M⊕rQ)⊕rQ = (C2)⊕kC1,  一般是使用⊕(异或)处理,原因(a⊕b)⊕b == a
//              ∴ 结果：M = (C2)⊕kC1（实际为M = C2⊕KDF(kC1,ml)看：♦️）,C2(密文C获取 已知),k(服务器私钥 已知)和C1(密文C获取 已知)
//
//  ♦️注意：上方 C2 = M⊕rQ 改成 C2 = M⊕KDF(rQ,ml)，M = (C2)⊕kC1 改成 M = C2⊕KDF(kC1,ml) ，C2.len == M.len【别名ml】 == KDF(rQ,ml).len == KDF(kC1,ml).len，长度值相等
//         上方 C1 = rG 一般情况下前面还要加上0x04表示未压缩形式(C1 = 0x04+rG)
//  C3 = HASH_SM3(rQx+M+rQy)
//
//      |---   64 byte C1  ---||--- M(len) C2---||------ 32 byte C3 ------|
//      |                     ||                ||                        |
//      |----x1----|----y1----||                ||                        |
//      |          |          ||                ||                        |
//  C = F0...................0802..............C9A1......................B8
//  注意C1的长度与坐标点长度相等
//
// 以上"+"基本是字符串拼接

//假设在加密过程中，有一个第三者H，H只能知道椭圆曲线 Ep(a,b)、公钥Q、基点G、密文C，而通过公钥Q、基点G求私钥k或者通过密文点C、基点P求随机数r都是非常困难的，因此得以保证数据传输的安全
//
//下面的加解密使用的是Fp上的椭圆曲线(p是大于3的素数，y^2 = x^3 + ax + b, a,b∈Fp,且(4a^3 + 27b^2) mod p = 0),非F2m上的椭圆曲线(y^2 + xy = x^3 + ax^2 + b, a,b∈F2m,且b=0)。
//
// asn.1解码 03 42 00
//      03是bit string的tag
//      42是bit string的length
//      00是bit string的unused bit
//      04说明是没有压缩的
//      剩下为公钥point值

@implementation O2SSMxHelper

#pragma mark - SM2

/// sm2加密
/// @param plainData 明文
/// @param publicKey 公钥Q 非der 可通过asn.1解码获得
/// @param cipher 椭圆曲线相关系数(p,a,b,Gx,Gy,n)
/// @param cipherMode c1+c2+c3或c1+c3+c2
+ (NSData *)sm2DoEncrypt:(NSData *)plainData
               publicKey:(NSString *)publicKey
                  cipher:(O2SSM2Cipher *)cipher
              cipherMode:(O2SSM2CipherMode)cipherMode
{
    BOOL repeat = NO;
    NSString *C1, *C2, *C3;
    
    do {
        repeat = NO;
        
        // 随机一个r
        O2SBigInt *r = [cipher randomBigIntegerK];
            
        //NSLog(@"%@",cipher.curve.toString);
            
        //🌟 C1 = 04 || rG (rG即点{x1,y1})
        O2SECPointFp *rGPoint = [cipher kG:r];
        NSUInteger pointLen = cipher.getPointLen;
        //x1
        NSString *rGPointX = [O2SSMxUtils leftPad:[[[rGPoint getX] toBigInteger] toString:16] num:pointLen/2];
        //y1
        NSString *rGPointY = [O2SSMxUtils leftPad:[[[rGPoint getY] toBigInteger] toString:16] num:pointLen/2];
        NSString *rG = [NSString stringWithFormat:@"%@%@", rGPointX, rGPointY];
        C1 = [NSString stringWithFormat:@"04%@", rG];
            
        //压缩
        //C1 = [cipher.curve encodePoint:rGPoint compressed:YES];
            
            
        //rQ (rQ即点{x2,y2})
        O2SECPointFp *rQPoint = [cipher kP:r PPointHex:publicKey];
        if (rQPoint == nil)
        {
            return nil;
        }
        //x2
        NSString *rQPointX = [O2SSMxUtils leftPad:[[[rQPoint getX] toBigInteger] toString:16] num:pointLen/2];
        //y2
        NSString *rQPointY = [O2SSMxUtils leftPad:[[[rQPoint getY] toBigInteger] toString:16] num:pointLen/2];
        //NSString *rQ = [NSString stringWithFormat:@"%@%@", rQPointX, rQPointY];
        //NSLog(@"rQ:%@",rQ);
            
        NSData *rQPointXData = [O2SSMxUtils dataByHexString:rQPointX];
        NSData *rQPointYData = [O2SSMxUtils dataByHexString:rQPointY];
            
        //t = KDF(x2y2,M_LEN)
        //🌟 C2 = M⊕t
        NSUInteger ml = plainData.length;
        NSMutableData *x2_y2 = [NSMutableData data];
        [x2_y2 appendData:rQPointXData];
        [x2_y2 appendData:rQPointYData];
        NSData *t = [O2SSM3Digest KDF:x2_y2 keylen:(int)ml];
        NSString *tHex = [O2SSMxUtils hexStringByData:t];
        O2SBigInt *tBigInt = [[O2SBigInt alloc] initWithString:tHex radix:16];
        if ([tBigInt compare:O2SBigInt.zero] == NSOrderedSame)
        {
            repeat = YES;
            continue;
        }
        O2SBigInt *plainBigInt = [[O2SBigInt alloc] initWithString:[O2SSMxUtils hexStringByData:plainData] radix:16];
        C2 = [[plainBigInt bitwiseXorByBigInt:tBigInt] toString:16];
        C2 = [O2SSMxUtils leftPad:C2 num:ml*2];
            
        //🌟 C3 = Hash(rQPointX+M+rQPointY)
        NSMutableData *x2_M_y2 = [NSMutableData data];
        [x2_M_y2 appendData:rQPointXData];
        [x2_M_y2 appendData:plainData];
        [x2_M_y2 appendData:rQPointYData];
        NSData *hash_sm3 = [O2SSM3Digest hashData:x2_M_y2];
        C3 = [O2SSMxUtils hexStringByData:hash_sm3];
    } while (repeat);
    
    
    NSString *C;
    if (cipherMode == O2SSM2CipherModeC1C2C3)
    {
        C = [NSString stringWithFormat:@"%@%@%@",C1,C2,C3];
    }
    else
    {
        C = [NSString stringWithFormat:@"%@%@%@",C1,C3,C2];
    }
//    NSLog(@"encrypt:%@",[C lowercaseString]);
    return [O2SSMxUtils dataByHexString:C];

}

/// sm2解密
/// @param cipherData 密文
/// @param privateKey 私钥k 非der 可通过asn.1解码获得
/// @param cipher 椭圆曲线相关系数(p,a,b,Gx,Gy,n)
/// @param cipherMode c1+c2+c3或c1+c3+c2
+ (NSData *)sm2DoDecrypt:(NSData *)cipherData
              privateKey:(NSString *)privateKey
                  cipher:(O2SSM2Cipher *)cipher
              cipherMode:(O2SSM2CipherMode)cipherMode
{

    NSUInteger pointLen = cipher.getPointLen;
    
    O2SBigInt *k = [[O2SBigInt alloc] initWithString:privateKey radix:16];
    if (cipherData.length <= 1)
    {
        return nil;
    }
    
    NSRange range_head = {0,1};
    NSData *headData = [cipherData subdataWithRange:range_head];
    
    //提取rG，不能直接拿C1当做rG，因为可能被压缩过
    NSUInteger C1_len = 0;
    O2SECPointFp *rGPoint;
    int8_t head;
    memcpy(&head, [headData bytes], 1);
    switch (head) {
        case 2:
        case 3:
        {
            C1_len = 1 + pointLen/4;
            NSRange rangeC1 = {0, C1_len};
            NSData *C1 = [cipherData subdataWithRange:rangeC1];
            rGPoint = [cipher.curve decodePointHex:[O2SSMxUtils hexStringByData:C1]];
        }
            break;
        case 4:
        case 6:
        case 7:
        {
            C1_len = 1 + pointLen/2;
            NSRange rangeC1 = {0, C1_len};
            NSData *C1 = [cipherData subdataWithRange:rangeC1];
            rGPoint = [cipher.curve decodePointHex:[O2SSMxUtils hexStringByData:C1]];
        }
            break;
        default:
            return nil;
            break;
    }
    
    if (rGPoint == nil)
    {
        return nil;
    }
    
    NSUInteger cipherLen = cipherData.length;
    if (cipherLen < C1_len + 32)
    {
        return nil;
    }
    
    NSData *C2,*C3;
    NSRange rangeC2,rangeC3;
    if (cipherMode == O2SSM2CipherModeC1C2C3)
    {
        rangeC3.location = cipherLen - 32;
        rangeC3.length = 32;
        
        rangeC2.location = C1_len;
        rangeC2.length = cipherLen - C1_len - 32;
    }
    else
    {
        rangeC3.location = C1_len;
        rangeC3.length = 32;
        
        rangeC2.location = C1_len + 32;
        rangeC2.length = cipherLen - C1_len - 32;
        
    }
    C2 = [cipherData subdataWithRange:rangeC2];
    NSString *C2Hex = [O2SSMxUtils hexStringByData:C2];
    C3 = [cipherData subdataWithRange:rangeC3];
    NSString *C3Hex = [O2SSMxUtils hexStringByData:C3];
    
    //kC1
    O2SECPointFp *kC1Point = [cipher kP:k PPoint:rGPoint];
    //x2
    NSString *kC1PointX = [O2SSMxUtils leftPad:[[[kC1Point getX] toBigInteger] toString:16] num:pointLen/2];
    //y2
    NSString *kC1PointY = [O2SSMxUtils leftPad:[[[kC1Point getY] toBigInteger] toString:16] num:pointLen/2];
    NSString *kC1 = [NSString stringWithFormat:@"%@%@", kC1PointX, kC1PointY];
//    NSLog(@"kC1:%@",kC1);
    
    NSData *kC1PointXData = [O2SSMxUtils dataByHexString:kC1PointX];
    NSData *kC1PointYData = [O2SSMxUtils dataByHexString:kC1PointY];
    NSData *kC1Data = [O2SSMxUtils dataByHexString:kC1];
    

    //M = (C2)⊕KDF(kC1,ml)
    //t = KDF(kC1,ml)
    NSUInteger ml = C2.length;
    NSData *kdf = [O2SSM3Digest KDF:kC1Data keylen:(int)ml];
    NSString *kdfHex = [O2SSMxUtils hexStringByData:kdf];
    O2SBigInt *t = [[O2SBigInt alloc] initWithString:kdfHex radix:16];
    if ([t compare:O2SBigInt.zero] == NSOrderedSame)
    {
        return nil;
    }
    O2SBigInt *C2BigInt = [[O2SBigInt alloc] initWithString:C2Hex radix:16];
    //M = (C2)^t
    O2SBigInt *plainBigInt = [C2BigInt bitwiseXorByBigInt:t];
    NSString *plainHex = [O2SSMxUtils leftPad:[plainBigInt toString:16] num:ml*2];
    NSData *plainData = [O2SSMxUtils dataByHexString:plainHex];
    
    //🌟 C3‘ = Hash(rQPointX+M+rQPointY)
    NSMutableData *x2_M_y2 = [NSMutableData data];
    [x2_M_y2 appendData:kC1PointXData];
    [x2_M_y2 appendData:plainData];
    [x2_M_y2 appendData:kC1PointYData];
    NSData *C3_t = [O2SSM3Digest hashData:x2_M_y2];
    NSString *C3Hex_t = [O2SSMxUtils hexStringByData:C3_t];
    
    //校验 C3 == C3‘ ？
    if ([C3Hex.lowercaseString isEqualToString:C3Hex_t.lowercaseString])
    {
        return plainData;
    }
    else
    {
        return nil;
    }
}

/// sm2 数字签名
/// @param userId 用户身份
/// @param srcData 被签名内容
/// @param privateKey 私钥k
/// @param cipher 椭圆曲线相关系数(p,a,b,Gx,Gy,n)
+ (NSData *)sm2DoSignUserId:(NSString *)userId srcData:(NSData *)srcData privateKey:(NSString *)privateKey cipher:(O2SSM2Cipher *)cipher
{
    NSString *rHex;
    NSString *sHex;
    @autoreleasepool {
        NSData *userIdData = [userId dataUsingEncoding: NSUTF8StringEncoding];
        NSString * userIdHex = [O2SSMxUtils hexStringByData:userIdData];
        NSString *ENTL_A = [NSString stringWithFormat:@"%lx",userIdData.length * 8];
        ENTL_A = [O2SSMxUtils leftPad:ENTL_A num:4];
        
        // 公钥 = 私钥*G点
        O2SBigInt *dA = [[O2SBigInt alloc] initWithString:privateKey radix:16];//私钥
        O2SECPointFp *PPoint = [cipher kG:dA];//公钥
        NSString *Px = [PPoint.getX.toBigInteger toString:16];
        Px = [O2SSMxUtils leftPad:Px num:cipher.getPointLen/2];
        NSString *Py = [PPoint.getY.toBigInteger toString:16];
        Py = [O2SSMxUtils leftPad:Py num:cipher.getPointLen/2];
        
        // Z_A = H256(ENTL_A || userId || a || b || Gx || Gy || Qx || Qy)
        NSMutableString *Z_A = [NSMutableString string];
        [Z_A appendString:ENTL_A];
        [Z_A appendString:userIdHex];
        [Z_A appendString:cipher.aHex];
        [Z_A appendString:cipher.bHex];
        [Z_A appendString:cipher.gxHex];
        [Z_A appendString:cipher.gyHex];
        [Z_A appendString:Px];
        [Z_A appendString:Py];
        NSData *Z_A_HashData = [O2SSMxHelper sm3DoHashWithData:[O2SSMxUtils dataByHexString:Z_A]];
        
        // M = Z_A || srcData
        NSMutableData *M = [NSMutableData data];
        [M appendData:Z_A_HashData];
        [M appendData:srcData];
        // e = H256(M)
        NSData *eData = [O2SSMxHelper sm3DoHashWithData:M];
        NSString *eHex = [O2SSMxUtils hexStringByData:eData];
        O2SBigInt *e = [[O2SBigInt alloc] initWithString:eHex radix:16];
        
        
        BOOL repeat = NO;
        do{
            repeat = NO;
            
            O2SBigInt *K = cipher.randomBigIntegerK;//[[O2SBigInt alloc] initWithString:@"6CB28D99385C175C94F94E934817663FC176D925DD72B727260DBAAE1FB2F96F" radix:16];;//
            O2SECPointFp *KPoint = [cipher kG:K];//随机一个点
            NSString *KxHex = [KPoint.getX.toBigInteger toString:16];
            KxHex = [O2SSMxUtils leftPad:KxHex num:cipher.getPointLen/2];
            O2SBigInt *Kx = [[O2SBigInt alloc] initWithString:KxHex radix:16];
            
            // r = (e+Kx) mod n
            O2SBigInt *r = [[e addByBigInt:Kx] modByBigInt:cipher.n];
            if ([r compare:O2SBigInt.zero] == NSOrderedSame || [[r addByBigInt:K] compare:cipher.n] == NSOrderedSame)
            {
                repeat = YES;
                continue;
            }
            rHex = [r toString:16];
            rHex = [O2SSMxUtils leftPad:rHex num:cipher.getPointLen/2];
            
            // s = ((1+dA)^-1 * (K-r*dA)) mod n
            O2SBigInt *t1 = [[O2SBigInt.one addByBigInt: dA] pow:[[O2SBigInt alloc] initWithInt:-1] mod:cipher.n];
            O2SBigInt *t2 = [K subByBigInt:[r multiplyByBigInt:dA]];
            O2SBigInt *s = [[t1 multiplyByBigInt:t2] modByBigInt:cipher.n];
            if ([s compare:O2SBigInt.zero] == NSOrderedSame)
            {
                repeat = YES;
                continue;
            }
            sHex = [s toString:16];
            sHex = [O2SSMxUtils leftPad:sHex num:cipher.getPointLen/2];
        }while (repeat);
    }
    return [O2SSMxUtils dataByHexString:[NSString stringWithFormat:@"%@%@",rHex,sHex]];
}


/// sm2 数字签名验签
/// @param userId 用户身份
/// @param srcData 被签名的内容
/// @param publicKey 公钥Q
/// @param cipher 椭圆曲线相关系数(p,a,b,Gx,Gy,n)
/// @param sign 签名校验值
+ (BOOL)sm2DoVerifyUserId:(NSString *)userId srcData:(NSData *)srcData publicKey:(NSString *)publicKey cipher:(O2SSM2Cipher *)cipher sign:(NSData *)sign
{
    @autoreleasepool {
        NSData *userIdData = [userId dataUsingEncoding: NSUTF8StringEncoding];
        NSString * userIdHex = [O2SSMxUtils hexStringByData:userIdData];
        NSString *ENTL_A = [NSString stringWithFormat:@"%lx",userIdData.length * 8];
        ENTL_A = [O2SSMxUtils leftPad:ENTL_A num:4];
        
        // 公钥
        NSUInteger len = publicKey.length / 2;
        NSString *Px = [publicKey substringWithRange:NSMakeRange(0, len)];
        Px = [O2SSMxUtils leftPad:Px num:cipher.getPointLen/2];
        NSString *Py = [publicKey substringWithRange:NSMakeRange(len,len)];
        Py = [O2SSMxUtils leftPad:Py num:cipher.getPointLen/2];
        
        // Z_A = H256(ENTL_A || userId || a || b || Gx || Gy || Qx || Qy)
        NSMutableString *Z_A = [NSMutableString string];
        [Z_A appendString:ENTL_A];
        [Z_A appendString:userIdHex];
        [Z_A appendString:cipher.aHex];
        [Z_A appendString:cipher.bHex];
        [Z_A appendString:cipher.gxHex];
        [Z_A appendString:cipher.gyHex];
        [Z_A appendString:Px];
        [Z_A appendString:Py];
        NSData *Z_A_HashData = [O2SSMxHelper sm3DoHashWithData:[O2SSMxUtils dataByHexString:Z_A]];
        
        // M = Z_A || srcData
        NSMutableData *M = [NSMutableData data];
        [M appendData:Z_A_HashData];
        [M appendData:srcData];
        // e = H256(M)
        NSData *eData = [O2SSMxHelper sm3DoHashWithData:M];
        NSString *eHex = [O2SSMxUtils hexStringByData:eData];
        O2SBigInt *e = [[O2SBigInt alloc] initWithString:eHex radix:16];
        
        // t = (r + s) mod n
        NSString *signHex = [O2SSMxUtils hexStringByData:sign];
        len = signHex.length / 2;
        NSString *rHex = [signHex substringWithRange:NSMakeRange(0, len)];
        O2SBigInt *r = [[O2SBigInt alloc] initWithString:rHex radix:16];
        
        O2SBigInt *n_1 = [cipher.n subByBigInt:O2SBigInt.one];
        
        // r ∈ [1,n-1];
        if ([r compare:O2SBigInt.one] == NSOrderedDescending || [r compare:n_1] == NSOrderedAscending)
        {
            return NO;
        }
        
        NSString *sHex = [signHex substringWithRange:NSMakeRange(len, len)];
        O2SBigInt *s = [[O2SBigInt alloc] initWithString:sHex radix:16];
        
        //s ∈ [1,n-1];
        if ([s compare:O2SBigInt.one] == NSOrderedDescending || [s compare:n_1] == NSOrderedAscending)
        {
            return NO;
        }
        O2SBigInt *t = [[r addByBigInt:s] modByBigInt:cipher.n];
        // t != 0
        if ([t compare:O2SBigInt.zero] == NSOrderedSame)
        {
            return NO;
        }
        
        //(x,y) = [s]G + [t]P
        O2SECPointFp *sGPoint = [cipher kG:s];
        O2SECPointFp *tPPoint = [cipher kP:t PPointHex:publicKey];
        O2SECPointFp *point = [sGPoint add:tPPoint];
        O2SBigInt *x = point.getX.toBigInteger;
        
        //R = (e + x) mod n
        O2SBigInt *R = [[e addByBigInt:x] modByBigInt:cipher.n];
        if ([r compare:R] == NSOrderedSame)
        {
            return YES;
        }
        return NO;
    }
}

#pragma mark - SM3

+ (NSData *)sm3DoHashWithString:(NSString *)msg
{
    return [O2SSM3Digest hash:msg];
}

+ (NSData *)sm3DoHashWithData:(NSData *)msg
{
    return [O2SSM3Digest hashData:msg];
}

#pragma mark - SM4

@end
