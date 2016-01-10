//
//  CoreTextCell.m
//  TestRichText
//
//  Created by Johannes on 16/1/10.
//  Copyright © 2016年 何江浩. All rights reserved.
//

#import "CoreTextCell.h"
#import "CTDisplayView.h"

@interface CoreTextCell (){
    CTDisplayView *displayView;
}

@end

@implementation CoreTextCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        displayView = [[CTDisplayView alloc] init];
        [self addSubview:displayView];
    }
    return self;
}

@end
