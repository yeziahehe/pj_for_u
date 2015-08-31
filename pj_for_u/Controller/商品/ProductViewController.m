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
#import "CategoryInfo.h"
#import "ProductionInfo.h"
@interface ProductViewController ()

@property (nonatomic, strong) NSMutableArray *allCategories;
@property (nonatomic, strong) NSMutableArray *allProductionMArray;
@property (strong,nonatomic)MainTableViewController *currenVC;
@property (strong,nonatomic)MainTableViewController *NVC;
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
    for(int i=0 ; i<self.allCategories.count; i++)
    {
        CategoryInfo *pinfo = [self.allCategories objectAtIndex:i];
        //循环创建子vc
        MainTableViewController *mvc = [[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
        mvc.title = pinfo.category;
        mvc.categoryId = pinfo.categoryId;
        [self addChildViewController:mvc];
    }
}

- (void)addLable
{
    for (int i = 0; i < self.allCategories.count; i++) {
        CGFloat lblW = 90;
        CGFloat lblH = 30;
        CGFloat lblY = 0;
        CGFloat lblX = i * lblW ;
        CategoryLabel *lbl1 = [[CategoryLabel alloc]init];
        UIViewController *vc = self.childViewControllers[i];
        lbl1.text = vc.title;
        lbl1.frame = CGRectMake(lblX, lblY , lblW, lblH);
        lbl1.font = [UIFont systemFontOfSize:15];
        lbl1.tag = i;
        lbl1.userInteractionEnabled = YES;
        [self.smallScrollView addSubview:lbl1];
        [lbl1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lblClick:)]];
        self.smallScrollView.contentSize = CGSizeMake(90 * (i+1) , 0);

    }
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

- (void)loadSubViews
{
    [self addController];
    [self addLable];
    CGFloat contentX = self.childViewControllers.count * ScreenWidth;
    self.bigScrollView.contentSize = CGSizeMake(contentX, 0);
    self.bigScrollView.pagingEnabled = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.smallScrollView.showsHorizontalScrollIndicator = NO;
    self.bigScrollView.showsHorizontalScrollIndicator = NO;
    self.smallScrollView.showsVerticalScrollIndicator = NO;
    self.bigScrollView.delegate = self;
    
    // 默认状态控制器
    MainTableViewController *mvc = [self.childViewControllers firstObject];
    mvc.view.frame = self.bigScrollView.bounds;
    mvc.categoryId = [[self.childViewControllers firstObject] categoryId];
    [self.bigScrollView addSubview:mvc.view];
    CategoryLabel *lable = [self.smallScrollView.subviews firstObject];
    lable.scale = 1.0;
}

#pragma mark - Notification Methods
- (void)getCategoriesWithNotification:(NSNotification *)notification
{
    NSArray *valueArray = notification.object;
    self.allCategories = [NSMutableArray arrayWithCapacity:0];
    for(NSDictionary *valueDict in valueArray)
    {
        CategoryInfo *pi = [[CategoryInfo alloc]initWithDict:valueDict];
        [self.allCategories addObject:pi];
    }
    //接受完分类信息，开始加载页面
    [self loadSubViews];
}

#pragma mark - ViewController Lifecycle
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
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.NVC = self.childViewControllers[index];
    self.NVC.categoryId = [self.childViewControllers[index] categoryId];
    [self.smallScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != index) {
            CategoryLabel *temlabel = self.smallScrollView.subviews[idx];
            temlabel.scale = 0.0;
        }
    }];
    //如果nvc已经存在了，不作处理
    if (self.NVC.view.superview) return;
    
    self.NVC.view.frame = scrollView.bounds;
    [self.bigScrollView addSubview:self.NVC.view];
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
