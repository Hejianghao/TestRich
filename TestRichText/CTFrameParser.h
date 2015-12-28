//
//  CTFrameParser.h
//  CoreText
//
//  Created by 何江浩 on 15/12/28.
//  Copyright © 2015年 何江浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTFrameParserConfig.h"
#import "CoreTextData.h"

@interface CTFrameParser : NSObject

+ (CoreTextData *) parseContent:(NSString *)content config:(CTFrameParserConfig *)config;

+ (CoreTextData *) parseTemplateFile:(NSString *)path config:(CTFrameParserConfig *) config;

@end
