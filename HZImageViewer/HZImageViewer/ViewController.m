//
//  ViewController.m
//  HZImageViewer
//
//  Created by mewe on 2018/1/4.
//  Copyright © 2018年 zenon. All rights reserved.
//

#import "ViewController.h"
#import "HZImageViewer.h"

@interface ViewController ()
@property (nonatomic,  copy) NSArray       *imageList;
@property (nonatomic,strong) HZImageViewer *imageViewer;
@property (nonatomic,assign) BOOL           isCycle;
@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupRightItem];
    
    NSMutableArray *mutList = [[NSMutableArray alloc] init];
    for (int i= 1; i<3; i++) {
        NSString *name=[NSString stringWithFormat:@"test%d",i];
        UIImage *testImage = [UIImage imageNamed:name];
        if (testImage) {
            [mutList addObject:testImage];
        }
    }
 
    self.imageList = mutList;
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

@end
