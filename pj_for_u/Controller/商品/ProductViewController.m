//
//  ProductViewController.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProductViewController.h"
#import "HACursor.h"
#import "UIView+Extension.h"
#import "HATestView.h"

@interface ProductViewController ()
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (strong,nonatomic) HACursor *cursor;
@end

@implementation ProductViewController

#pragma mark - 加载
- (NSMutableArray *)createPageViews{
    NSMutableArray *pageViews = [NSMutableArray array];
    for (NSInteger i = 0; i < self.titles.count; i++) {
        HATestView *textView = [[HATestView alloc]init];
        textView.label.text = self.titles[i];
        [pageViews addObject:textView];
    }
    return pageViews;
}

#pragma mark - UIView Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    //不允许有重复的标题
    self.titles = @[@"家政服务",@"水果上门",@"代取快递",@"特惠秒杀",@"最新体验",@"特色服务"];
    
    _cursor = [[HACursor alloc]init];
    _cursor.frame = CGRectMake(0, 64, self.view.width, 29);
    _cursor.titles = self.titles;
    _cursor.pageViews = [self createPageViews];
    //设置根滚动视图的高度
    _cursor.rootScrollViewHeight = self.view.frame.size.height - 109;
    //默认值是白色
    _cursor.titleNormalColor = [UIColor blackColor];
    //默认值是白色
    _cursor.titleSelectedColor = [UIColor redColor];
    _cursor.showSortbutton = NO;
    _cursor.minFontSize = 14;
    _cursor.maxFontSize = 14;
    _cursor.isGraduallyChangFont = NO;
    //在isGraduallyChangFont为NO的时候，isGraduallyChangColor不会有效果
    //cursor.isGraduallyChangColor = NO;
    [self.view addSubview:_cursor];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.navigationController popViewControllerAnimated:YES];

}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}


@end
