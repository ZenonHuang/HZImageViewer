//
//  ViewController.m
//  HZImageViewer
//
//  Created by mewe on 2018/1/4.
//  Copyright © 2018年 zenon. All rights reserved.
//

#import "ViewController.h"
#import "HZImageViewer.h"


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

- (void)setupRightItem{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"不循环"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(tapRightItem:)];
    

    self.navigationItem.rightBarButtonItem = item;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)tapButton:(id)sender {
    
    [self presentViewController:self.imageViewer animated:YES completion:nil];
}

- (IBAction)tapPushButton:(id)sender {

    [self.navigationController pushViewController:self.imageViewer animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.imageList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SampleCellIdentifier
                                                                       forIndexPath:indexPath];
    
    UIImage *image         =   self.imageList[indexPath.row];
    UIImageView *imageView =   [[UIImageView alloc] initWithImage:image];
    imageView.contentMode  =   UIViewContentModeScaleAspectFit;
    
    imageView.frame = cell.bounds;
    [cell.contentView addSubview:imageView];
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    self.imageViewer.pageIndex = indexPath.row;
    [self presentViewController:self.imageViewer animated:YES completion:nil];
    
}

#pragma mark - getter
- (HZImageViewer *)imageViewer{
    if (!_imageViewer) {
        _imageViewer = [[HZImageViewer alloc] init];
    }
    
    _imageViewer.isCycle = self.isCycle;
    
    if (self.imageList) {
        _imageViewer.dataList = self.imageList;
    }
 
    return _imageViewer;
}

- (UICollectionView *)collectionView{
    if (!_collectionView ){
          CGRect frame = [UIScreen mainScreen].bounds;
        _collectionView = [[UICollectionView alloc] initWithFrame:frame 
                                             collectionViewLayout:self.flowLayout];
        _collectionView.delegate   = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[UICollectionViewCell class]
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
            UIImage *testImage = [UIImage imageNamed:name];
            if (testImage) {
                [mutList addObject:testImage];
            }
        }
        
        _imageList = [mutList copy];
    }
    return _imageList;
}
@end
