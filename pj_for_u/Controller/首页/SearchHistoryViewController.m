//
//  SearchHistoryViewController.m
//  SJFood
//
//  Created by 叶帆 on 14/12/17.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

#import "SearchHistoryViewController.h"

#define kSearchHistoryArray     @"SearchHistoryArray"

@interface SearchHistoryViewController ()
@property (nonatomic, strong)NSUserDefaults *userDefaults;
@property (nonatomic, strong)NSMutableArray *searchHistoryArray;
@end

@implementation SearchHistoryViewController
@synthesize searchBar,searchHistoryTableView,clearSearchHistoryView,noSearchHistoryView;
@synthesize userDefaults,searchHistoryArray;

#pragma mark - IBAction Methods
- (IBAction)clearSearchButtonClicked:(id)sender {
    [self.searchBar resignFirstResponder];
    [self.userDefaults removeObjectForKey:kSearchHistoryArray];
    self.searchHistoryArray = [NSMutableArray arrayWithCapacity:0];
    self.searchHistoryTableView.tableFooterView = self.noSearchHistoryView;
    [self.searchHistoryTableView setContentSize:self.searchHistoryTableView.tableFooterView.frame.size];
    [self.searchHistoryTableView reloadData];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UIViewController Methods
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [self.userDefaults arrayForKey:kSearchHistoryArray];
    if (nil == array) {
        self.searchHistoryArray = [NSMutableArray arrayWithCapacity:0];
        self.searchHistoryTableView.tableFooterView = self.noSearchHistoryView;
    }
    else {
        self.searchHistoryArray = [NSMutableArray arrayWithArray:array];
        self.searchHistoryTableView.tableFooterView = self.clearSearchHistoryView;
    }
    [self.searchHistoryTableView setContentSize:self.searchHistoryTableView.tableFooterView.frame.size];
    [self.searchHistoryTableView reloadData];
}

- (NSString *)checkFieldValid
{
    NSString *searchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.searchBar.text = searchText;
    if(searchBar.text.length < 1)
        return @"请输入正确的搜索内容";
    else
        return nil;
}

#pragma mark - UISearchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *checkString = [self checkFieldValid];
    if (checkString) {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:checkString customView:nil hideDelay:2.f];
    }
    else{
        [self.searchHistoryArray removeObject:self.searchBar.text];
        [self.searchHistoryArray insertObject:self.searchBar.text atIndex:0];
        [self.userDefaults setObject:self.searchHistoryArray forKey:kSearchHistoryArray];
        [self.userDefaults synchronize];
        [self dismissViewControllerAnimated:NO completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kSearchButtonNotification object:self.searchBar.text];
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self resignAllField];
}

- (void)resignAllField
{
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resignAllField];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchHistoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.searchHistoryArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14.f];
    cell.textLabel.textColor = kLightTextColor;
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSearchButtonNotification object:[self.searchHistoryArray objectAtIndex:indexPath.row]];
    [self.searchHistoryArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];
    [self.userDefaults setObject:self.searchHistoryArray forKey:kSearchHistoryArray];
    [self.userDefaults synchronize];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
