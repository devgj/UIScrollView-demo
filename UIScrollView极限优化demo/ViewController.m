//
//  ViewController.m
//  UIScrollView极限优化demo
//
//  Created by imooc_gj on 15/6/6.
//  Copyright (c) 2015年 devgj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate>

/**
 *  保存可见的视图
 */
@property (nonatomic, strong) NSMutableSet *visibleImageViews;

/**
 *  保存可重用的
 */
@property (nonatomic, strong) NSMutableSet *reusedImageViews;

/**
 *  滚动视图
 */
@property (nonatomic, weak) UIScrollView *scrollView;

/**
 *  所有的图片名
 */
@property (nonatomic, strong) NSArray *imageNames;

@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加UIScrollView
    [self setupScrollView];
}

#pragma mark Init Views

// 添加UIScrollView
- (void)setupScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(self.imageNames.count * CGRectGetWidth(scrollView.frame), 0);
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    [self showImageViewAtIndex:0];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showImages];
    [self test];
}

- (void)test {
    NSMutableString *rs = [NSMutableString string];
    NSInteger count = [self.scrollView.subviews count];
    for (UIImageView *imageView in self.scrollView.subviews) {
        [rs appendFormat:@"%p - ", imageView];
    }
    [rs appendFormat:@"%ld", (long)count];
    NSLog(@"%@", rs);
}

#pragma mark - Private Method 

- (void)showImages {

    // 获取当前处于显示范围内的图片的索引
    CGRect visibleBounds = self.scrollView.bounds;
    CGFloat minX = CGRectGetMinX(visibleBounds);
    CGFloat maxX = CGRectGetMaxX(visibleBounds);
    CGFloat width = CGRectGetWidth(visibleBounds);
    
    NSInteger firstIndex = (NSInteger)floorf(minX / width);
    NSInteger lastIndex  = (NSInteger)floorf(maxX / width);
    
    // 处理越界的情况
    if (firstIndex < 0) {
       firstIndex = 0;
    }
    
    if (lastIndex >= [self.imageNames count]) {
        lastIndex = [self.imageNames count] - 1;
    }
    
    // 回收不再显示的ImageView
    NSInteger imageViewIndex = 0;
    for (UIImageView *imageView in self.visibleImageViews) {
        imageViewIndex = imageView.tag;
        // 不在显示范围内
        if (imageViewIndex < firstIndex || imageViewIndex > lastIndex) {
            [self.reusedImageViews addObject:imageView];
            [imageView removeFromSuperview];
        }
    }

    [self.visibleImageViews minusSet:self.reusedImageViews];
    
    // 是否需要显示新的视图
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        BOOL isShow = NO;
        
        for (UIImageView *imageView in self.visibleImageViews) {
            if (imageView.tag == index) {
                isShow = YES;
            }
        }
        
        if (!isShow) {
            [self showImageViewAtIndex:index];
        }
    }
}

// 显示一个图片view
- (void)showImageViewAtIndex:(NSInteger)index {
    
    UIImageView *imageView = [self.reusedImageViews anyObject];

    if (imageView) {
        [self.reusedImageViews removeObject:imageView];
    } else {
        imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }

    CGRect bounds = self.scrollView.bounds;
    CGRect imageViewFrame = bounds;
    imageViewFrame.origin.x = CGRectGetWidth(bounds) * index;
    imageView.tag = index;
    imageView.frame = imageViewFrame;
    imageView.image = [UIImage imageNamed:self.imageNames[index]];
    
    [self.visibleImageViews addObject:imageView];
    [self.scrollView addSubview:imageView];
}

#pragma mark - Getters and Setters

- (NSArray *)imageNames {
    if (_imageNames == nil) {
        NSMutableArray *imageNames = [NSMutableArray arrayWithCapacity:50];
        
        for (int i = 0; i < 50; i++) {
            NSString *imageName = [NSString stringWithFormat:@"img%d", i % 5];
            [imageNames addObject:imageName];
        }
        
        _imageNames = imageNames;
    }
    return _imageNames;
}

- (NSMutableSet *)visibleImageViews {
    if (_visibleImageViews == nil) {
        _visibleImageViews = [[NSMutableSet alloc] init];
    }
    return _visibleImageViews;
}

- (NSMutableSet *)reusedImageViews {
    if (_reusedImageViews == nil) {
        _reusedImageViews = [[NSMutableSet alloc] init];
    }
    return _reusedImageViews;
}

@end
