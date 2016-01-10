//
//  CoreTextTableViewController.m
//  TestRichText
//
//  Created by Johannes on 16/1/10.
//  Copyright © 2016年 何江浩. All rights reserved.
//

#import "CoreTextTableViewController.h"
#import "CoreTextCell.h"

@interface CoreTextTableViewController (){
    NSMutableArray *array;
}

@end

@implementation CoreTextTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return array.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ReuseIdentifier = @"CoreTextCell";
    CoreTextCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        cell = [[CoreTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseIdentifier];
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 0.0;
}

@end
