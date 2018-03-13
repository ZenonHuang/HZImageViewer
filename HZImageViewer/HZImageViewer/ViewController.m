//
//  ViewController.m
//  HZImageViewer
//
//  Created by mewe on 2018/1/4.
//  Copyright © 2018年 zenon. All rights reserved.
//

#import "ViewController.h"
#import "HZImageViewer.h"
#import "HZSampleListCell.h"

static NSString *const SampleCellIdentifier = @"SampleCellIdentifier";

@interface ViewController ()
@property (nonatomic,  copy) NSArray       *imageList;
@property (nonatomic,strong) HZImageViewer *imageViewer;
@property (nonatomic,assign) BOOL           isCycle;
@end

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupRightItem];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
- (void)setupRightItem{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"不循环"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(tapRightItem:)];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - action

- (void)tapRightItem:(UIBarButtonItem *)sender{
    
    self.isCycle = (!self.isCycle);
    if (self.isCycle) {
        sender.title = @"循环";
    }else{
        sender.title = @"不循环";
    }

}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.imageList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HZSampleListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SampleCellIdentifier
                                                                       forIndexPath:indexPath];
    NSString *name         =   self.imageList[indexPath.row];
    UIImage *testImage = [UIImage imageNamed:name];
    
    [cell configureImage:testImage];
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.imageList) {
        
        NSMutableArray *mutList = [[NSMutableArray alloc] init];
        for (NSString *name in self.imageList) {
           UIImage *image =  [UIImage imageNamed:name];
            [mutList addObject:image];
        }
        self.imageViewer.dataList = [mutList copy];
    }
    self.imageViewer.isCycle   = self.isCycle;
    self.imageViewer.pageIndex = indexPath.row;
    [self presentViewController:self.imageViewer animated:YES completion:nil];
    
}

#pragma mark - getter
- (HZImageViewer *)imageViewer{
    if (!_imageViewer) {
        _imageViewer = [[HZImageViewer alloc] init];
    }
    
    return _imageViewer;
}

- (UICollectionView *)collectionView{
    if (!_collectionView ){
        CGRect frame = [UIScreen mainScreen].bounds;
        _collectionView = [[UICollectionView alloc] initWithFrame:frame 
                                             collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor]; 
        _collectionView.delegate   = self;
        _collectionView.dataSource = self;
        
        _collectionView.bounces = YES;
       _collectionView.alwaysBounceVertical = YES;
        
        [_collectionView registerClass:[HZSampleListCell class]
            forCellWithReuseIdentifier:SampleCellIdentifier];
        
    }
    return _collectionView;
}

-(UICollectionViewFlowLayout *)flowLayout{
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _flowLayout.sectionInset    = UIEdgeInsetsMake(0,0,0,0);
        _flowLayout.minimumLineSpacing      = 0;
        _flowLayout.minimumInteritemSpacing = 0;
        
        CGSize size = [UIScreen mainScreen].bounds.size;
        _flowLayout.itemSize = CGSizeMake(size.width/3, size.width/3);
    }
    return _flowLayout;
}

- (NSArray *)imageList{
    if (!_imageList) {
  
        NSMutableArray *mutList = [[NSMutableArray alloc] init];
        for (int i= 1; i<3; i++) {
            NSString *name=[NSString stringWithFormat:@"test%d",i];
            [mutList addObject:name];
           
        }
        
        _imageList = [mutList copy];
    }
    return _imageList;
}
@end
