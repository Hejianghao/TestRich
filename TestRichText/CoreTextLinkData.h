//
//  CoreTextLinkData.h
//  TestRichText
//
//  Created by Johannes on 16/1/10.
//  Copyright © 2016年 何江浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreTextLinkData : NSObject

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) NSRange range;

@end
