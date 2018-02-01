//
//  ViewController.m
//  ShopSDKDemo
//
//  Created by 陈剑东 on 2017/12/12.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+SPSDKCommon.h"
#import <ShopSDKUI/SPSDKTabBarViewController.h>


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *passBtn;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *bgImg = [UIImage imageFromGradientColors:@[[UIColor colorForString:@"#DE4A34"], [UIColor colorForString:@"#FB7E41"]]
                                         gradientType:SPSDKGradientTypeTopToBottom
                                                 size:self.view.bounds.size];
    self.backgroundImage.image = bgImg;

    
    self.passBtn.layer.cornerRadius = 20;
    self.passBtn.layer.borderWidth = 2;
    self.passBtn.layer.borderColor = [UIColor colorForString:@"#FFFFFF"].CGColor;
    
    self.button1.layer.cornerRadius = 25;
    self.button1.layer.borderWidth = 2;
    self.button1.layer.borderColor = [UIColor colorForString:@"#FFFFFF"].CGColor;
    
    self.button2.layer.cornerRadius = 25;
    self.button2.layer.borderWidth = 2;
    self.button2.layer.borderColor = [UIColor colorForString:@"#FFFFFF"].CGColor;
    
}

- (IBAction)showWithMobPay:(UIButton *)sender
{
    SPSDKTabBarViewController *tabVC = [[SPSDKTabBarViewController alloc] init];
    [tabVC setPayMode:SPSDKPayModeMobPay];
    [self presentViewController:tabVC animated:YES completion:nil];
}
- (IBAction)showWithCustomPay:(UIButton *)sender
{
    SPSDKTabBarViewController *tabVC = [[SPSDKTabBarViewController alloc] init];
    [tabVC setPayMode:SPSDKPayModeCustom];
    [self presentViewController:tabVC animated:YES completion:nil];

}


@end
