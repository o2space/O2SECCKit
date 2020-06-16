//
//  O2SSMxUtils.m
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import "O2SSMxUtils.h"

@implementation O2SSMxUtils

+ (NSData *)dataByHexString:(NSString *)string
{
    if (![string isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    char byte = 0;
    
    NSString *upperString = [string uppercaseString];
    NSMutableData *data = [NSMutableData data];
    for (int i = 0; i < [upperString length]; i++)
    {
        NSInteger value = (NSInteger)[upperString characterAtIndex:i];
        if (value >= '0' && value <= '9')
        {
            if (i % 2 == 0)
            {
                byte = ((value - '0') << 4) & 0xf0;
                
                if (i == [upperString length] - 1)
                {
                    [data appendBytes:(const void *)&byte length:1];
                }
            }
            else
            {
                byte |= (value - '0') & 0x0f;
                [data appendBytes:(const void *)&byte length:1];
            }
        }
        else if (value >= 'A' && value <= 'F')
        {
            if (i % 2 == 0)
            {
                byte = ((value - 'A' + 10) << 4) & 0xf0;
                
                if (i == [upperString length] - 1)
                {
                    [data appendBytes:(const void *)&byte length:1];
                }
            }
            else
            {
                byte |= (value - 'A' + 10) & 0x0f;
                [data appendBytes:(const void *)&byte length:1];
            }
        }
        else
        {
            data = nil;
            break;
        }
    }
    
    return data;
}

+ (NSString *)hexStringByData:(NSData *)data
{
    if (![data isKindOfClass:[NSData class]])
    {
        return nil;
    }
    
    NSMutableString *hexStr = [NSMutableString string];
    const char *buf = [data bytes];
    for (int i = 0; i < [data length]; i++)
    {
        [hexStr appendFormat:@"%02X", buf[i] & 0xff];
    }
    return hexStr;
}

+ (NSString *)stringByBase64EncodeData:(NSData *)data
{
    if (![data isKindOfClass:[NSData class]])
    {
        return nil;
    }
    
    if (@available(iOS 7.0, *))
    {
        return [data base64EncodedStringWithOptions:0];
    }
    else
    {
        return [data base64Encoding];
    }
}

+ (NSData *)dataByBase64DecodeString:(NSString *)string
{
    if (![string isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    if (@available(iOS 7.0, *))
    {
        return [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    else
    {
        return [[NSData alloc] initWithBase64Encoding:string];
    }
}

+ (NSString *)stringByBase64DecodeString:(NSString *)string
{
    NSData *data = [self dataByBase64DecodeString:string];
    if(data)
    {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return @"";
}

+ (NSString *)leftPad:(NSString *)input num:(NSUInteger)num
{
    @autoreleasepool {
        if (input.length >= num)
        {
            return input;
        }
        
        NSMutableString *s = [NSMutableString string];
        NSUInteger len = num - input.length;
        for (int i = 0; i < len;)
        {
            if (i + 4 < len)
            {
                [s appendFormat:@"0000"];
                i += 4;
                continue;
            }
            else if (i + 3 < len)
            {
                [s appendFormat:@"000"];
                i += 3;
                continue;
            }
            else if (i + 2 < len)
            {
                [s appendFormat:@"00"];
                i += 2;
                continue;
            }
            else
            {
               [s appendFormat:@"0"];
                i += 1;
                continue;
            }
        }
        
        return [s stringByAppendingString:input];
    }
}

@end
