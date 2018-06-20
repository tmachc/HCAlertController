//
//  ViewController.m
//  HCAlertController
//
//  Created by 韩冲 on 2018/6/20.
//  Copyright © 2018年 f2pool. All rights reserved.
//

#import "ViewController.h"
#import "HCAlertController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:16.0/255 green:116.0/255 blue:250.0/255 alpha:1];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 100, 30)];
    [btn1 setTitle:@"普通" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(clickBtn1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(10, 200, 100, 30)];
    [btn2 setTitle:@"输入框" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(clickBtn2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(10, 300, 100, 30)];
    [btn3 setTitle:@"选择框" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(clickBtn3:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
}

- (IBAction)clickBtn1:(UIButton *)sender
{
    HCAlertController *ac = [HCAlertController alertControllerWithTitle:@"提示" message:@"这是普通弹出框" preferredStyle:HCAlertControllerStyleAlert];
    HCAlertAction *aaok = [HCAlertAction actionWithTitle:@"确定" style:HCAlertActionStyleDefault handler:^(HCAlertAction * _Nonnull action) {
        
    }];
    HCAlertAction *aacancel = [HCAlertAction actionWithTitle:@"取消" style:HCAlertActionStyleCancel handler:^(HCAlertAction * _Nonnull action) {
        
    }];
    [ac addAction:aaok];
    [ac addAction:aacancel];
    [self presentViewController:ac animated:false completion:^{
        
    }];
}

- (IBAction)clickBtn2:(UIButton *)sender
{
    HCAlertController *ac = [HCAlertController alertControllerWithTitle:@"提示" message:@"请输入文字" preferredStyle:HCAlertControllerStyleAlert];
    HCAlertAction *aaok = [HCAlertAction actionWithTitle:@"确定" style:HCAlertActionStyleDefault handler:^(HCAlertAction * _Nonnull action) {
        
    }];
    HCAlertAction *aacancel = [HCAlertAction actionWithTitle:@"取消" style:HCAlertActionStyleCancel handler:^(HCAlertAction * _Nonnull action) {
        
    }];
    [ac addAction:aaok];
    [ac addAction:aacancel];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"输入文字";
    }];
    [self presentViewController:ac animated:false completion:^{
        
    }];
}

- (IBAction)clickBtn3:(UIButton *)sender
{
    HCAlertController *ac = [HCAlertController alertControllerWithTitle:@"提示" message:@"请输入文字" preferredStyle:HCAlertControllerStyleAlert];
    HCAlertAction *aaok = [HCAlertAction actionWithTitle:@"确定" style:HCAlertActionStyleDefault handler:^(HCAlertAction * _Nonnull action) {
        
    }];
    HCAlertAction *aacancel = [HCAlertAction actionWithTitle:@"取消" style:HCAlertActionStyleCancel handler:^(HCAlertAction * _Nonnull action) {
        
    }];
    [ac addAction:aaok];
    [ac addAction:aacancel];
    [ac addSelectItems:@[@"第一项", @"第二项", @"第三项", @"第四项"] defaultIndex:1];
    [self presentViewController:ac animated:false completion:^{
        
    }];
}

@end
