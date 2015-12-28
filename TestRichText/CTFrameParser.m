//
//  CTFrameParser.m
//  CoreText
//
//  Created by 何江浩 on 15/12/28.
//  Copyright © 2015年 何江浩. All rights reserved.
//

#import "CTFrameParser.h"

#import <CoreText/CoreText.h>

@implementation CTFrameParser

+ (NSDictionary *) attributesWithConfig:(CTFrameParserConfig *)config {
    CGFloat fontSize = config.fontSize;
    CTFontRef fontRef = CTFontCreateWithName(CFSTR("ArialMT"), fontSize, NULL);
    
    //段落属性的设置不用
    //CGFloat lineSpacing = config.lineSpace;
    
    UIColor *textColor = config.textColor;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    
    
    
    CFRelease(fontRef);
    
    return dict;
}

+ (CoreTextData *) parseContent:(NSString *)content config:(CTFrameParserConfig *)config {
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSAttributedString *contentString = [[NSAttributedString alloc]initWithString:content
                                                                       attributes:attributes];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentString);
    //获得绘制区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);//约束区域
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    
    CGFloat textHeight = coreTextSize.height;
    
    CTFrameRef frame = [self createFrameWithFramesetter:frameSetter config:config height:textHeight];
    
    CoreTextData *data = [[CoreTextData alloc] init];
    data.ctFrame = frame;
    data.height = textHeight;
    
    CFRelease(frameSetter);
    CFRelease(frame);
    
    return data;
}

+(CoreTextData *) parseTemplateFile:(NSString *)path config:(CTFrameParserConfig *) config {
    NSAttributedString *contetnt = [self loadTemplateFile:path config:config];
    return [self parseAttributedContent:contetnt config:config];
}

+ (NSAttributedString *) loadTemplateFile:(NSString *)path config:(CTFrameParserConfig *)config {
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    if (data) {
        NSError *error;
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if ([arr isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in arr) {
                NSString *type = [dict objectForKey:@"type"];
                if ([type isEqualToString:@"txt"]) {
                    //根据给定的信息设置排版
                    NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                }
            }
        }
    }
    return result;
}


+ (NSAttributedString *) parseAttributedContentFromNSDictionary:(NSDictionary *)dict
                                                         config:(CTFrameParserConfig *)config {
    NSMutableDictionary *attributes = (NSMutableDictionary *)[self attributesWithConfig:config];
    UIColor *color = [self colorFromTemplate:dict[@"color"]];
    if (color) {
        attributes[(id)kCTForegroundColorAttributeName] = (id) color;
    }
    //设置字体大小
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize > 0) {
        CTFontRef fontRef = CTFontCreateWithName(CFSTR("ArialMT"), fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    NSString *content = dict[@"content"];
    return [[NSAttributedString alloc] initWithString:content attributes:attributes];
}

+ (UIColor *) colorFromTemplate:(NSString *)name {
    if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    } else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    } else if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    } else {
        return nil;
    }
}

+ (CoreTextData *) parseAttributedContent:(NSAttributedString *)content config:(CTFrameParserConfig *)config {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:textHeight];
    CoreTextData *data = [[CoreTextData alloc] init];
    data.ctFrame = frame;
    data.height = textHeight;
    return data;
    
}

+ (CTFrameRef) createFrameWithFramesetter:(CTFramesetterRef)frameSetter
                                   config:(CTFrameParserConfig *)config
                                   height:(CGFloat)height {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    //cfrangeMake 0 表示字符串中的所有字符
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}


@end
