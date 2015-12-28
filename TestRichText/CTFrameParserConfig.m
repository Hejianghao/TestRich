//
//  CTFrameParserConfig.m
//  CoreText
//
//  Created by 何江浩 on 15/12/28.
//  Copyright © 2015年 何江浩. All rights reserved.
//

#import "CTFrameParserConfig.h"

@implementation CTFrameParserConfig

- (id) init {
    self = [super init];
    if ( self) {
        _width = SCREENWIDTH;
        _fontSize = 16.0f;
        _lineSpace = 8.0f;
        _textColor = UIColorFromRGB(0x00CED1);
    }
    return self;
}

@end
