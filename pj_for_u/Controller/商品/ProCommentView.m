//
//  ProCommentView.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProCommentView.h"
#import "ProCommentTableViewCell.h"
#import "ProCommentDetail.h"

#define kLimit @"5"

@interface ProCommentView ()
@property(strong,nonatomic)NSMutableArray *allCommentMArray;
@end

@implementation ProCommentView
#pragma mark - NetWorking Methods
- (void)loadDataWithType:(NSString *)type
                  foodId:(NSString *)foodId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //接口地址
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetFoodCommentUrl];
    //传递参数存放的字典
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:foodId forKey:@"foodId"];
    [dict setObject:kCampusId forKey:@"campusId"];
    [dict setObject:kLimit forKey:@"limit"];
    
    NSString *page ;
    if([type isEqualToString:@"1"]){
        page = @"1";
        [dict setObject:page forKey:@"page"];
        self.page =2;
    }
    else if([type isEqualToString:@"2"]){
        NSString *pageString = [NSString stringWithFormat:@"%ld",(long)self.page];
        [dict setObject:pageString forKey:@"page"];
        self.page ++;
    }
    //进行post请求
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation,id responseObject) {
        
        NSArray *valueArray = [responseObject objectForKey:@"foodComments"];
        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:0];
        for(NSDictionary *valueDict in valueArray)
        {
            ProCommentDetail *pcd = [[ProCommentDetail alloc]initWithDict:valueDict];
            [tempArray addObject:pcd];
        }
        if ([type isEqualToString:@"1"]) {
            self.allCommentMArray = tempArray;
            [self.tableView reloadData];
            //===== NOTIFICATION
            [[NSNotificationCenter defaultCenter] postNotificationName:kIsTimeToEndRefreshNotification object:nil];

        }
        else if ([type isEqualToString:@"2"]){
            [self.allCommentMArray addObjectsFromArray:tempArray];
            [self.tableView reloadData];
            //===== NOTIFICATION
            [[NSNotificationCenter defaultCenter] postNotificationName:kIsTimeToEndRefreshNotification object:nil];

        }
        NSLog(@"Success:%lu",(unsigned long)self.allCommentMArray.count);
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
}

//下拉加载更多评论
-(void)loadMoreComments{
    [self loadDataWithType:@"2" foodId:self.proInfo.foodId];
}
//获取商品评论model后进行请求并加载
-(void)setProInfo:(ProductionInfo *)proInfo{
    _proInfo = proInfo;
    NSLog(@"当前食品的ID：%@",proInfo.foodId);
    [self loadDataWithType:@"1" foodId:proInfo.foodId];
    self.commentLabel.text = [NSString stringWithFormat:@"商品评价(%@)",proInfo.commentNumber];
}
#pragma mark - UIView Methosd
-(void)awakeFromNib{
    [super awakeFromNib];

    self.page = 2;
    UINib *nib = [UINib nibWithNibName:@"ProCommentTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"ProCommentTableViewCell"];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreComments)];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - UITableView Datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProCommentTableViewCell" ];
    ProCommentDetail *pcd = [self.allCommentMArray objectAtIndex:indexPath.row];
    cell.pcd = pcd;

    return cell;
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allCommentMArray.count;
}

//配合aotomaticDimension让tableviewcell高度自适应
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//实现高度自适应
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){

        CGSize buffer = self.tableView.contentSize;
        
        CGRect rect = self.tableView.frame;
        rect.size.width = ScreenWidth;
        rect.size.height = self.tableView.contentSize.height;
        self.tableView.frame = rect;
        
        self.tableView.contentSize = buffer;

        NSString *height = [NSString stringWithFormat:@"%f",self.tableView.contentSize.height];
        [[NSNotificationCenter defaultCenter]postNotificationName:kHeightForTBVNotification object:height];
    }
}
@end
