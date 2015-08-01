//
//  ProductViewController.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProductViewController.h"
#import "CategoryLabel.h"
#import "MainTableViewController.h"
#import "ProductInfo.h"

@interface ProductViewController ()

@property (nonatomic, strong) NSMutableArray *allCategories;

@end

@implementation ProductViewController
#pragma mark - Private Methods
- (void)loadCategoryArray
{
    [[ProductDataManager sharedManager]requestForAddressWithCampusId:kCampusId];
}


//添加子视图控制器
- (void)addController
{
//    for(int i=0 ; i<self.allCategories.count; i++)
//    {
//        ProductInfo *pinfo = [self.allCategories objectAtIndex:i];
//        //循环创建vc
//    
//        
//    }
    MainTableViewController *vc1 = [[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
    vc1.title = @"小优推荐";
    vc1.categoryId = @"105";
    [self addChildViewController:vc1];
    
    MainTableViewController *vc2 = [[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
    vc2.title = @"最新体验";
    [self addChildViewController:vc2];
    
    MainTableViewController *vc3 = [[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
    vc3.title = @"特惠秒杀";
    [self addChildViewController:vc3];
    
    MainTableViewController *vc4 = [[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
    vc4.title = @"早餐上门";
    [self addChildViewController:vc4];
    
    MainTableViewController *vc5 = [[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
    vc5.title = @"更多分类";
    [self addChildViewController:vc5];
    
    MainTableViewController *vc6 = [[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
    vc6.title = @"家政服务";
    [self addChildViewController:vc6];
    
    MainTableViewController *vc7 = [[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
    vc7.title = @"水果上门";
    [self addChildViewController:vc7];
    
    MainTableViewController *vc8 = [[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
    vc8.title = @"酒水饮品";
    [self addChildViewController:vc8];
    
    MainTableViewController *vc9 = [[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
    vc9.title = @"饼干糕点";
    [self addChildViewController:vc9];
    
    MainTableViewController *vc10 = [[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
    vc10.title = @"快递代取";
    [self addChildViewController:vc10];
}

- (void)addLable
{
    
    for (int i = 0; i < 10; i++) {
        CGFloat lblW = 90;
        CGFloat lblH = 30;
        CGFloat lblY = 0;
        CGFloat lblX = i * lblW ;
        CategoryLabel *lbl1 = [[CategoryLabel alloc]init];
        UIViewController *vc = self.childViewControllers[i];
        lbl1.text = vc.title;
        lbl1.frame = CGRectMake(lblX, lblY , lblW, lblH);
        lbl1.font = [UIFont fontWithName:@"HYQiHei" size:5];
        lbl1.tag = i;
        lbl1.userInteractionEnabled = YES;
        [self.smallScrollView addSubview:lbl1];
        [lbl1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lblClick:)]];
    }
    self.smallScrollView.contentSize = CGSizeMake(90 * 10 , 0);
}

/** 标题栏label的点击事件 */
- (void)lblClick:(UITapGestureRecognizer *)recognizer
{
    CategoryLabel *titlelable = (CategoryLabel *)recognizer.view;
    CGFloat offsetX = titlelable.tag * self.bigScrollView.frame.size.width;
    CGFloat offsetY = self.bigScrollView.contentOffset.y;
    CGPoint offset = CGPointMake(offsetX, offsetY);
    [self.bigScrollView setContentOffset:offset animated:YES];
}

#pragma mark - Notification Methods
- (void)getCategoriesWithNotification:(NSNotification *)notification
{
    NSArray *valueArray = notification.object;
    self.allCategories = [NSMutableArray arrayWithCapacity:0];
    for(NSDictionary *valueDict in valueArray)
    {
        ProductInfo *pi = [[ProductInfo alloc]initWithDict:valueDict];
        [self.allCategories addObject:pi];
    }
    NSLog(@"有几个分类：%lu",(unsigned long)self.allCategories.count);
    //接受完分类信息，开始加载页面
    [self loadSubViews];
}

- (void)loadSubViews
{
    [self addController];
    [self addLable];
    CGFloat contentX = self.childViewControllers.count * ScreenWidth;
    self.bigScrollView.contentSize = CGSizeMake(contentX, 0);
    self.bigScrollView.pagingEnabled = YES;
    
    // 默认状态控制器
    UIViewController *vc = [self.childViewControllers firstObject];
    vc.view.frame = self.bigScrollView.bounds;
    [self.bigScrollView addSubview:vc.view];
    CategoryLabel *lable = [self.smallScrollView.subviews firstObject];
    lable.scale = 1.0;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.smallScrollView.showsHorizontalScrollIndicator = NO;
    self.smallScrollView.showsVerticalScrollIndicator = NO;
    self.bigScrollView.delegate = self;
}
#pragma mark - UIView Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"分类"];
    [self loadCategoryArray];

    //通知监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getCategoriesWithNotification:) name:kGetCategoryNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

#pragma mark - UIScrollView Delegat Methods
/** 滚动结束后调用（代码导致） */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 获得索引
    NSUInteger index = scrollView.contentOffset.x / self.bigScrollView.frame.size.width;
    
    // 滚动标题栏
    CategoryLabel *titleLable = (CategoryLabel *)self.smallScrollView.subviews[index];
    
    CGFloat offsetx = titleLable.center.x - self.smallScrollView.frame.size.width * 0.5;
    
    CGFloat offsetMax = self.smallScrollView.contentSize.width - self.smallScrollView.frame.size.width;
    if (offsetx < 0) {
        offsetx = 0;
    }else if (offsetx > offsetMax){
        offsetx = offsetMax;
    }
    
    CGPoint offset = CGPointMake(offsetx, self.smallScrollView.contentOffset.y);
    [self.smallScrollView setContentOffset:offset animated:YES];
    // 添加控制器
    MainTableViewController *MVc = self.childViewControllers[index];
    MVc.index = index;
    
    [self.smallScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != index) {
            CategoryLabel *temlabel = self.smallScrollView.subviews[idx];
            temlabel.scale = 0.0;
        }
    }];
    
    if (MVc.view.superview) return;
    
    MVc.view.frame = scrollView.bounds;
    [self.bigScrollView addSubview:MVc.view];
}

/** 滚动结束（手势导致） */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

/** 正在滚动 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 取出绝对值 避免最左边往右拉时形变超过1
    CGFloat value = ABS(scrollView.contentOffset.x / scrollView.frame.size.width);
    NSUInteger leftIndex = (int)value;
    NSUInteger rightIndex = leftIndex + 1;
    CGFloat scaleRight = value - leftIndex;
    CGFloat scaleLeft = 1 - scaleRight;
    CategoryLabel *labelLeft = self.smallScrollView.subviews[leftIndex];
    labelLeft.scale = scaleLeft;
    // 考虑到最后一个板块，如果右边已经没有板块了 就不在下面赋值scale了
    if (rightIndex < self.smallScrollView.subviews.count) {
        CategoryLabel *labelRight = self.smallScrollView.subviews[rightIndex];
        labelRight.scale = scaleRight;
    }
    
}

@end
