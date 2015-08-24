//
//  ProImageView.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProImageView.h"


@interface ProImageView ()


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *gradeLabel;
@property (strong, nonatomic) IBOutlet UILabel *saleNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *discountLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIImageView *lineImage;
@property (strong, nonatomic) IBOutlet UIImageView *cutImageView;

@end

@implementation ProImageView

- (void)loadWithImages:(NSArray *)images
{
    self.pageControl.numberOfPages = images.count;
    self.pageControl.currentPage = 0;
    
    if (images.count <= 1) {
        self.scrollView.scrollEnabled = NO;
    }
    else {
        self.scrollView.scrollEnabled = YES;
    }

    
    for (int i = 0; i < images.count; i++) {
        YFAsynImageView *asynImgView = [[YFAsynImageView alloc] init];
        asynImgView.cacheDir = kImageCacheDir;
        [asynImgView aysnLoadImageWithUrl:images[i] placeHolder:@"home_image_default.png"];
        
        //设置frame
        CGRect rect = CGRectMake(i * ScreenWidth, 0, ScreenWidth, self.scrollView.frame.size.height);
        asynImgView.frame = rect;
        asynImgView.contentMode = UIViewContentModeScaleToFill;
        
        [self.scrollView addSubview:asynImgView];
    }
    
    [self.scrollView setContentSize:CGSizeMake(ScreenWidth * images.count, 0)];
    

}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    
    self.pageControl.currentPage = page;
    [self.scrollView setContentOffset:CGPointMake(page * self.scrollView.frame.size.width, 0) animated:YES];

}



-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.scrollView.delegate = self;

}

-(void)setProInfo:(ProductionInfo *)proInfo{
    _proInfo = proInfo;
    self.nameLabel.text = proInfo.name;
    self.messageLabel.text = proInfo.message;
    self.saleNumLabel.text = [NSString stringWithFormat:@"销量：%@",proInfo.saleNumber];
    CGFloat discountPrice = [proInfo.price doubleValue] - [proInfo.discountPrice doubleValue];
    
    if ([proInfo.isDiscount isEqualToString:@"1"]) {
        self.oldPriceLabel.hidden = NO;
        self.discountLabel.hidden = NO;
        self.lineImage.hidden = NO;
        self.cutImageView.hidden = NO;
        
        self.priceLabel.text = [NSString stringWithFormat:@"￥: %.1f",[proInfo.discountPrice doubleValue]];
        self.discountLabel.text = [NSString stringWithFormat:@"( 省%.1f元 )",discountPrice];
        self.oldPriceLabel.text = [NSString stringWithFormat:@"%@",proInfo.price];

    } else {
        self.priceLabel.text = [NSString stringWithFormat:@"￥: %.1f",[proInfo.price doubleValue]];
        
        self.lineImage.hidden = YES;
        self.oldPriceLabel.hidden = YES;
        self.discountLabel.hidden = YES;
        self.cutImageView.hidden = YES;
    }
    
    
    
    if (!proInfo.grade) {
        self.gradeLabel.text = proInfo.grade;
    }
    
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:10];
    [images addObject:proInfo.imgUrl];
    [images addObjectsFromArray:[proInfo.info componentsSeparatedByString:@","]];

    [self loadWithImages:images];

}

@end
