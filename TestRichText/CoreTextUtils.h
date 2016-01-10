//
//  CoreTextUtils.h
//  TestRichText
//
//  Created by Johannes on 16/1/10.
//  Copyright © 2016年 何江浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextData.h"

@interface CoreTextUtils : NSObject

+(CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data;

@end
