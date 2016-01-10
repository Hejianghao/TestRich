//
//  CTDisplayView.m
//  CoreText
//
//  Created by 何江浩 on 15/12/28.
//  Copyright © 2015年 何江浩. All rights reserved.
//

#import "CTDisplayView.h"
#import <CoreText/CoreText.h>
#import "CoreTextData.h"
#import "CoreTextUtils.h"

@interface CTDisplayView ()<UIGestureRecognizerDelegate>

@end

@implementation CTDisplayView

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupEvents];
    }
    return self;
}

- (void) setupEvents {
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGestureDetected:)];
    //tapRecognizer.delegate = self;
    [self addGestureRecognizer:tapRecognizer];
    [self setUserInteractionEnabled:YES];
}

- (void) userTapGestureDetected:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    
    CoreTextLinkData *linkData = [CoreTextUtils touchLinkInView:self atPoint:point data:_data];
    if (linkData) {
        NSLog(@"hint link!");
    }
    
    for (CoreTextImageData *imageData in _data.imageArray) {
        CGRect imageRect = imageData.imagePosition;
        CGPoint imagePosition = imageRect.origin;
        imagePosition.y = self.bounds.size.height - imagePosition.y -imageRect.size.height;
        CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
        if (CGRectContainsPoint(rect, point)) {
            NSLog(@"bingo");
            break;
        }
    }
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if (self.data) {
        CTFrameDraw(self.data.ctFrame, context);
        if ([_data.imageArray count] != 0) {
            for (CoreTextImageData *imageData in _data.imageArray) {
                CGContextDrawImage(context, imageData.imagePosition, [UIImage imageNamed:imageData.name].CGImage);
            }
        }
    }
}

@end
