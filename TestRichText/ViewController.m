//
//  ViewController.m
//  TestRichText
//
//  Created by 何江浩 on 15/12/28.
//  Copyright © 2015年 何江浩. All rights reserved.
//

#import "ViewController.h"
#import "CTFrameParser.h"
#import "CTDisplayView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CTFrameParserConfig *config = [[CTFrameParserConfig alloc] init];
    debugLog(@"%@",[[NSBundle mainBundle] pathForResource:@"file" ofType:@"txt"]);
    
    CoreTextData *coreText = [CTFrameParser parseTemplateFile:[[NSBundle mainBundle] pathForResource:@"file" ofType:@"txt"] config:config];
    
    CTDisplayView *view = [[CTDisplayView alloc] initWithFrame:CGRectMake(20.f, 20.f, SCREENWIDTH - 20.f, coreText.height + 20.f)];
    
    view.backgroundColor = [UIColor clearColor];
    view.data = coreText;
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
