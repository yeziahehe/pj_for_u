//
//  YFCycleScrollView.m
//  SJFood
//
//  Created by 叶帆 on 15/3/18.
//  Copyright (c) 2015年 Ye Fan. All rights reserved.
//

#import "YFCycleScrollView.h"
#import "YFAsynImageView.h"

@interface YFCycleScrollView ()

@end

@implementation YFCycleScrollView

@synthesize cycleArray,cycleDelegate;

-(void)asyncImageViewTappedWithGesture:(UITapGestureRecognizer *)gesture
{
    YFAsynImageView *asynImgView = (YFAsynImageView *)(gesture.view);
    if(asynImgView.tag < 0 || asynImgView.tag >= self.cycleArray.count)
        return;
    if(asynImgView.tag == 0)
        [self.cycleDelegate didCycleScrollViewTappedWithIndex:(self.cycleArray.count-2)];
    else if(asynImgView.tag == self.cycleArray.count-1)
        [self.cycleDelegate didCycleScrollViewTappedWithIndex:0];
    else
        [self.cycleDelegate didCycleScrollViewTappedWithIndex:(asynImgView.tag-1)];
    
}

#pragma mark - Public methods
- (void)reloadWithImages:(NSArray *)images
             placeHolder:(NSString *)placeHolder
                cacheDir:(NSString *)cacheDir
{
    for(id v in self.subviews)
    {
        if([v isKindOfClass:[YFAsynImageView class]])
        {
            YFAsynImageView *asynImgView = (YFAsynImageView *)v;
            [asynImgView removeFromSuperview];
        }
    }
    self.cycleArray = [NSMutableArray arrayWithArray:images];
    if(images.count > 0)
    {
        [self.cycleArray insertObject:[images objectAtIndex:([images count]-1)] atIndex:0];
        [self.cycleArray addObject:[images objectAtIndex:0]];
        
        NSInteger index = 0;
        for(NSString *str in self.cycleArray)
        {
            //设置frame
            YFAsynImageView *asynImgView = [[YFAsynImageView alloc] init];
            CGRect rect = self.bounds;
            rect.size.width = ScreenWidth;
            rect.origin.x = index*ScreenWidth;
            rect.size.height = 150.f*ScreenWidth/320.f;
            asynImgView.frame = rect;
            asynImgView.contentMode = UIViewContentModeScaleAspectFill;
            //加载图片
            asynImgView.cacheDir = cacheDir;
            [asynImgView aysnLoadImageWithUrl:str placeHolder:placeHolder];
            //改变图片的大小
            asynImgView.image = [self OriginImage:asynImgView.image scaleToSize:rect.size];
            //加载手势
            asynImgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(asyncImageViewTappedWithGesture:)];
            [asynImgView addGestureRecognizer:tapGesture];
            asynImgView.tag = index;
            
            [self addSubview:asynImgView];
            index++;
        }
        [self setContentSize:CGSizeMake(ScreenWidth*self.cycleArray.count, 0)];
        [self setContentOffset:CGPointMake(ScreenWidth, 0)];
    }
    else
    {
        [self setContentSize:CGSizeZero];
        [self setContentOffset:CGPointZero];
        NSLog(@"CycyleScrollView 的元素为0.");
    }
}

//实现图片根据imageView的大小实现缩放
- (UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0,0,size.width,size.height-20)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - UIView methods
- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.pagingEnabled = YES;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.pagingEnabled = YES;
}

@end
