//
//  MonitorViewController.m
//  SmartSleep
//
//  Created by William Cai on 16/7/15.
//  Copyright © 2016年 William Cai. All rights reserved.
//

#import "MonitorViewController.h"
#import "DeviceStatisticsTableViewController.h"
#import "AuthorizationViewController.h"

@interface MonitorViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *titlesView;
@property (nonatomic, weak) UIScrollView *contentView;
@property (nonatomic, weak) UIView *bar;
@property (nonatomic, weak) UIButton *selectedButton;

@end

@implementation MonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavigationBar];
    [self setChildViewController];
    [self setTitleView];
    [self setContentView];
    
}

- (void)setChildViewController{
    DeviceStatisticsTableViewController *deviceStatisticVC = [[DeviceStatisticsTableViewController alloc] init];
    [self addChildViewController:deviceStatisticVC];
}

- (void)setNavigationBar {
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"navigationbar_addfriends" highlightedImage:@"navigationbar_addfriends_highlighted" target:self action:@selector(addFriends)];
    
    self.view.backgroundColor = GlobalBackground;
}

- (void)setTitleView {
    // 顶部标签栏view
    UIView *titlesView = [[UIView alloc] init];
    titlesView.backgroundColor = [UIColor whiteColor];
    titlesView.width = self.view.width;
    titlesView.height = TitlesViewH;
    titlesView.y = TitlesViewY;
    [self.view addSubview:titlesView];
    self.titlesView = titlesView;
    
    // 底部的绿色指示器
    UIView *bar = [[UIView alloc] init];
    bar.backgroundColor = RGBColor(47, 191, 104);
    bar.height = 2.3;
    bar.y = titlesView.height - bar.height;
    self.bar = bar;
    
    // 内部的子标签
    NSArray *titles = @[@"我的设备"];
    CGFloat width = 100;
    CGFloat height = titlesView.height;
    
    for (NSInteger i = 0; i<titles.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = i;
        button.height = height;
        button.width = width;
        button.x = i * width;
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:RGBColor(47, 191, 104) forState:UIControlStateDisabled];
        [button addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        [titlesView addSubview:button];
        
        // 默认点击了第一个按钮
        if (i == 0) {
            button.enabled = NO;
            self.selectedButton = button;
            
            // 让按钮内部的label根据文字内容来计算尺寸
            self.bar.width = button.width;
            self.bar.centerX = button.centerX;
        }
    }
    [titlesView addSubview:bar];
}

- (void)titleClick:(UIButton *)button {
    // 修改按钮状态
    self.selectedButton.enabled = YES;
    button.enabled = NO;
    self.selectedButton = button;
    
    // 动画
    [UIView animateWithDuration:0.25 animations:^{
        self.bar.width = button.width;
        self.bar.centerX = button.centerX;
    }];
    
    // 滚动
    CGPoint offset = self.contentView.contentOffset;
    offset.x = button.tag * self.contentView.width;
    [self.contentView setContentOffset:offset animated:YES];
}

- (void)setContentView{
    
    // 不要自动调整inset
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *contentView = [[UIScrollView alloc] init];
    contentView.frame = self.view.bounds;
    contentView.delegate = self;
    contentView.pagingEnabled = YES;
    [self.view insertSubview:contentView atIndex:0];
    contentView.contentSize = CGSizeMake(contentView.width * self.childViewControllers.count, 0);
    self.contentView = contentView;
    
    // 添加第一个控制器的view
    [self scrollViewDidEndScrollingAnimation:contentView];
}

- (void)addFriends {
    AuthorizationViewController *vc = [[AuthorizationViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 当前的索引
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    
    // 取出子控制器
    UITableViewController *vc = self.childViewControllers[index];
    vc.view.x = scrollView.contentOffset.x;
    vc.view.y = 0;
    vc.view.height = scrollView.height;
    
    [scrollView addSubview:vc.view];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
    // 点击按钮
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    [self titleClick:self.titlesView.subviews[index]];
}

@end
