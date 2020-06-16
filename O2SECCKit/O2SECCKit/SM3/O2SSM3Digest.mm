//
//  O2SSM3Digest.m
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import "O2SSM3Digest.h"

namespace com
{
    namespace o2space
    {
        namespace sm3
        {
            /*
             * SM3算法产生的哈希值大小（单位：字节）
             */
            #define SM3_HASH_SIZE 32
            
            typedef struct SM3Context
            {
                unsigned int intermediateHash[SM3_HASH_SIZE / 4];
                unsigned char messageBlock[64];
            } SM3Context;
            #pragma mark - 方法定义

            /*
             * SM3计算函数
             */
            unsigned char *hash_sm3(const unsigned char *message, unsigned int messageLen, unsigned char digest[SM3_HASH_SIZE]);
            
            /*
             * 国密SM2加解密算法中的密钥派生函数kdf
             */
            int KDF_sm3(const unsigned char *cdata, unsigned int datalen, int keylen, unsigned char *retdata);
        
            #pragma mark - Private
            /*
             * 判断运行环境是否为小端
             */
            static const int endianTest = 1;
            #define IsLittleEndian() (*(char *)&endianTest == 1)
            
            /*
             * 向左循环移位
             */
            #define LeftRotate(word, bits) ( (word) << (bits) | (word) >> (32 - (bits)) )
            
            /*
             * 反转四字节整型字节序
             */
            unsigned int *ReverseWord(unsigned int *word)
            {
                unsigned char *byte, temp;
             
                byte = (unsigned char *)word;
                temp = byte[0];
                byte[0] = byte[3];
                byte[3] = temp;
             
                temp = byte[1];
                byte[1] = byte[2];
                byte[2] = temp;
                return word;
            }

            /*
             * T
             */
            unsigned int T(int i)
            {
                if (i >= 0 && i <= 15)
                    return 0x79CC4519;
                else if (i >= 16 && i <= 63)
                    return 0x7A879D8A;
                else
                    return 0;
            }


            /*
             * FF
             */
            unsigned int FF(unsigned int X, unsigned int Y, unsigned int Z, int i)
            {
                if (i >= 0 && i <= 15)
                    return X ^ Y ^ Z;
                else if (i >= 16 && i <= 63)
                    return (X & Y) | (X & Z) | (Y & Z);
                else
                    return 0;
            }
             
            /*
             * GG
             */
            unsigned int GG(unsigned int X, unsigned int Y, unsigned int Z, int i)
            {
                if (i >= 0 && i <= 15)
                    return X ^ Y ^ Z;
                else if (i >= 16 && i <= 63)
                    return (X & Y) | (~X & Z);
                else
                    return 0;
            }
             
            /*
             * P0 置换
             */
            unsigned int P0(unsigned int X)
            {
                return X ^ LeftRotate(X, 9) ^ LeftRotate(X, 17);
            }
             
            /*
             * P1 置换
             */
            unsigned int P1(unsigned int X)
            {
                return X ^ LeftRotate(X, 15) ^ LeftRotate(X, 23);
            }
             
            /*
             * 初始化函数
             */
            void SM3Init(SM3Context *context)
            {
                context->intermediateHash[0] = 0x7380166F;
                context->intermediateHash[1] = 0x4914B2B9;
                context->intermediateHash[2] = 0x172442D7;
                context->intermediateHash[3] = 0xDA8A0600;
                context->intermediateHash[4] = 0xA96F30BC;
                context->intermediateHash[5] = 0x163138AA;
                context->intermediateHash[6] = 0xE38DEE4D;
                context->intermediateHash[7] = 0xB0FB0E4E;
            }
             
            /*
             * 处理消息块 压缩
             */
            void CF(SM3Context *context)
            {
                int i;
                unsigned int W[68];
                unsigned int W_[64];
                unsigned int A, B, C, D, E, F, G, H, SS1, SS2, TT1, TT2;
             
                /* 消息扩展 */
                for (i = 0; i < 16; i++)
                {
                    W[i] = *(unsigned int *)(context->messageBlock + i * 4);
                    if (IsLittleEndian())
                        ReverseWord(W + i);
                    //printf("%d: %x\n", i, W[i]);
                }
                for (i = 16; i < 68; i++)
                {
                    W[i] = P1(W[i - 16] ^ W[i - 9] ^ LeftRotate(W[i - 3], 15))
                        ^ LeftRotate(W[i - 13], 7)
                        ^ W[i - 6];
                    //printf("%d: %x\n", i, W[i]);
                }
                for (i = 0; i < 64; i++)
                {
                    W_[i] = W[i] ^ W[i + 4];
                    //printf("%d: %x\n", i, W_[i]);
                }
             
                /* 消息压缩 */
                A = context->intermediateHash[0];
                B = context->intermediateHash[1];
                C = context->intermediateHash[2];
                D = context->intermediateHash[3];
                E = context->intermediateHash[4];
                F = context->intermediateHash[5];
                G = context->intermediateHash[6];
                H = context->intermediateHash[7];
                for (i = 0; i < 64; i++)
                {
                    SS1 = LeftRotate((LeftRotate(A, 12) + E + LeftRotate(T(i), i)), 7);
                    SS2 = SS1 ^ LeftRotate(A, 12);
                    TT1 = FF(A, B, C, i) + D + SS2 + W_[i];
                    TT2 = GG(E, F, G, i) + H + SS1 + W[i];
                    D = C;
                    C = LeftRotate(B, 9);
                    B = A;
                    A = TT1;
                    H = G;
                    G = LeftRotate(F, 19);
                    F = E;
                    E = P0(TT2);
                }
                context->intermediateHash[0] ^= A;
                context->intermediateHash[1] ^= B;
                context->intermediateHash[2] ^= C;
                context->intermediateHash[3] ^= D;
                context->intermediateHash[4] ^= E;
                context->intermediateHash[5] ^= F;
                context->intermediateHash[6] ^= G;
                context->intermediateHash[7] ^= H;
            }
            
            #pragma mark - Public
            
           /*
            * SM3算法主函数
            */
           unsigned char *SM3HashMsg(const unsigned char *message, unsigned int messageLen, unsigned char digest[SM3_HASH_SIZE])
           {
               SM3Context context;
               unsigned int i, remainder, bitLen;
            
               /* 初始化上下文 */
               SM3Init(&context);
            
               /* 对前面的消息分组进行处理 */
               for (i = 0; i < messageLen / 64; i++)
               {
                   memcpy(context.messageBlock, message + i * 64, 64);
                   CF(&context);
               }
            
               /* 填充消息分组，并处理 */
               bitLen = messageLen * 8;
               if (IsLittleEndian())
                   ReverseWord(&bitLen);
               remainder = messageLen % 64;
               memcpy(context.messageBlock, message + i * 64, remainder);
               context.messageBlock[remainder] = 0x80;
               if (remainder <= 55)
               {
                   /* 长度按照大端法占8个字节，该程序只考虑长度在 2**32 - 1（单位：比特）以内的情况，
                   * 故将高 4 个字节赋为 0 。*/
                   memset(context.messageBlock + remainder + 1, 0, 64 - remainder - 1 - 8 + 4);
                   memcpy(context.messageBlock + 64 - 4, &bitLen, 4);
                   CF(&context);
               }
               else
               {
                   memset(context.messageBlock + remainder + 1, 0, 64 - remainder - 1);
                   CF(&context);
                   /* 长度按照大端法占8个字节，该程序只考虑长度在 2**32 - 1（单位：比特）以内的情况，
                   * 故将高 4 个字节赋为 0 。*/
                   memset(context.messageBlock, 0, 64 - 4);
                   memcpy(context.messageBlock + 64 - 4, &bitLen, 4);
                   CF(&context);
               }
            
               /* 返回结果 */
               if (IsLittleEndian())
               for (i = 0; i < 8; i++)
                   ReverseWord(context.intermediateHash + i);
               memcpy(digest, context.intermediateHash, SM3_HASH_SIZE);
            
               return digest;
           }
        
           int KDF_sm3(const unsigned char *cdata, unsigned int datalen, int keylen, unsigned char *retdata)
           {
               
               int nRet = -1;
               unsigned char *pRet = nullptr;
               unsigned char *pData = nullptr;
               
               if(cdata==NULL || datalen<=0 || keylen<=0)
               {
                   if(pRet)
                       free(pRet);
                   if(pData)
                       free(pData);
                    
                   return nRet;
               }
               
               if(NULL == (pRet=(unsigned char *)malloc(keylen)))
               {
                   if(pRet)
                       free(pRet);
                   if(pData)
                       free(pData);
                    
                   return nRet;
               }
               
               if(NULL == (pData=(unsigned char *)malloc(datalen+4)))
               {
                   if(pRet)
                       free(pRet);
                   if(pData)
                       free(pData);
                    
                   return nRet;
               }
                
               memset(pRet,  0, keylen);
               memset(pData, 0, datalen+4);
                
               unsigned char cdgst[32]={0}; //摘要
               unsigned char cCnt[4] = {0}; //计数器的内存表示值
               int nCnt  = 1;  //计数器
               int nDgst = 32; //摘要长度
                
               int nTimes = (keylen+31)/32; //需要计算的次数
               int i=0;
               memcpy(pData, cdata, datalen);
               for(i=0; i<nTimes; i++)
               {
                   //cCnt
                   {
                       cCnt[0] =  (nCnt>>24) & 0xFF;
                       cCnt[1] =  (nCnt>>16) & 0xFF;
                       cCnt[2] =  (nCnt>> 8) & 0xFF;
                       cCnt[3] =  (nCnt    ) & 0xFF;
                   }
                   memcpy(pData+datalen, cCnt, 4);
                   SM3HashMsg(pData, datalen+4, cdgst);
                
                   if(i == nTimes-1) //最后一次计算，根据keylen/32是否整除，截取摘要的值
                   {
                       if(keylen%32 != 0)
                       {
                           nDgst = keylen%32;
                       }
                   }
                   memcpy(pRet+32*i, cdgst, nDgst);
                
                   i++;  //
                   nCnt ++;  //
               }
                
               if(retdata != NULL)
               {
                   memcpy(retdata, pRet, keylen);
               }
                
               nRet = 0;
               return nRet;
           }
        }
    }
}

using namespace com::o2space::sm3;

@implementation O2SSM3Digest

+ (NSData *)KDF:(NSData *)z keylen:(int)keylen
{
    Byte *byte = (Byte *)[z bytes];
    
    unsigned char output [keylen];
    memset(&output, 0, keylen);
    int nRet = KDF_sm3(byte, z.length, keylen, output);
    if (nRet == 0)
    {
        return [NSData dataWithBytes:output length:keylen];
    }
    return nil;
}

+ (NSData *)hash:(NSString *)message
{
    NSData *aData = [message dataUsingEncoding: NSUTF8StringEncoding];
    return [O2SSM3Digest hashData:aData];
}

+ (NSData *)hashData:(NSData *)data
{
    Byte *byte = (Byte *)[data bytes];
    //const char *input = message.UTF8String;
    unsigned char output [32];
    memset(&output, 0, 32);
    SM3HashMsg(byte, data.length, output);
    return [NSData dataWithBytes:output length:32];
//    return [NSString stringWithCString:(const char *)output encoding:NSUTF8StringEncoding];
}

@end
