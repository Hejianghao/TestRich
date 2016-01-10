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


#pragma mark - 通过string返回一个CoreTextData对象
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

#pragma mark - 通过一个文本文件返回一个CoreTextData对象
+(CoreTextData *) parseTemplateFile:(NSString *)path config:(CTFrameParserConfig *)config {
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *linkArray = [NSMutableArray array];
    NSAttributedString *content = [self loadTemplateFile:path config:config imageArray:imageArray linkArray:linkArray];
    
    CoreTextData *data = [self parseAttributedContent:content config:config];
    data.imageArray = imageArray;
    data.linkArray = linkArray;
    return data;

}

#pragma mark - 获得attributedstring
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

+ (NSAttributedString *) loadTemplateFile:(NSString *)path config:(CTFrameParserConfig *)config imageArray:(NSMutableArray *)imageArray {
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    if (data) {
        id array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in array) {
                NSString *type = dict[@"type"];
                if ([type isEqualToString:@"txt"]) {
                    NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                } else if ([type isEqualToString:@"img"]) {
                    CoreTextImageData *imageData = [[CoreTextImageData alloc] init];
                    imageData.name = dict[@"name"];
                    imageData.position = result.length;
                    [imageArray addObject:imageData];
                    //创建空白占位符
                    NSAttributedString *as = [self parseImageDataFromDictionary:dict config:config];
                    [result appendAttributedString:as];
                }
            }
        }
    }
    return result;
}

+ (NSAttributedString *) loadTemplateFile:(NSString *)path
                                   config:(CTFrameParserConfig *)config
                               imageArray:(NSMutableArray *)imageArray
                                linkArray:(NSMutableArray *)linkArray{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    if (data) {
        id array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in array) {
                NSString *type = dict[@"type"];
                if ([type isEqualToString:@"txt"]) {
                    NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                } else if ([type isEqualToString:@"img"]) {
                    CoreTextImageData *imageData = [[CoreTextImageData alloc] init];
                    imageData.name = dict[@"name"];
                    imageData.position = result.length;
                    [imageArray addObject:imageData];
                    //创建空白占位符
                    NSAttributedString *as = [self parseImageDataFromDictionary:dict config:config];
                    [result appendAttributedString:as];
                } else if ([type isEqualToString:@"link"]) {
                    NSUInteger startPos = result.length;
                    NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                    NSUInteger length = result.length - startPos;
                    NSRange linkRange = NSMakeRange(startPos, length);
                    CoreTextLinkData *linkData = [[CoreTextLinkData alloc] init];
                    linkData.url = dict[@"url"];
                    linkData.title = dict[@"content"];
                    linkData.range = linkRange;
                    [linkArray addObject:linkData];
                }
            }
        }
    }
    return result;
}

static CGFloat ascentCallback(void *ref) {
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref) {
    return 0;
}

static CGFloat widthCallback(void *ref){
    return [(NSNumber *)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}


+ (NSAttributedString *) parseImageDataFromDictionary:(NSDictionary *)dict config:(CTFrameParserConfig *)config {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(dict));
    unichar objectReplaceChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplaceChar length:1];
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return  space;
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
