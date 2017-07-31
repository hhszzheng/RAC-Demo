//
//  ViewController.m
//  RAC-Demo
//
//  Created by zyf on 2017/1/16.
//  Copyright © 2017年 zyf. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //文本框
//    [self textFieldTest];
    
    //手势
    [self tapGestureTest];
    
    
    //通知
    [self notificationTest];
    
    //定时器
//    [self timeTest];
    
    
    //KVO
    [self kvoTest];
    
    
    
    //登陆注册
    
    [self loginTest];
    
    
    
    
    
    [self concatTest];
    
    
    
    
    
    
    
}

- (void)loginTest{
    
    // 创建验证手机号的信号
    RACSignal *validphoneNumSignal = [_phoneNumTextField.rac_textSignal map:^id(NSString *text) {
        
        return @([self isValidUsername:text]);
    }];
    
    
    
    // 创建验证密码的信号
    RACSignal *validPasswordSignal = [_passwordTextField.rac_textSignal map:^id(NSString *text) {
        
        return @([self isValidPassword:text]);
        
    }];
    
    
    //通过信道返回的值，设置文本框的文字色
    RAC(_phoneNumTextField, textColor) = [validphoneNumSignal map:^id(NSNumber *usernameValid) {
        return [usernameValid boolValue] ? [UIColor cyanColor]:[UIColor redColor];
    }];
    
    
    // 通过信道返回的值，设置文本框的文字色
    RAC(_passwordTextField, textColor) = [validPasswordSignal map:^id(NSNumber *passwordValid) {
        
        return [passwordValid boolValue] ? [UIColor cyanColor]:[UIColor redColor];
        
    }];
    
    
    //把用户名和密码合成一个信道
    RACSignal *loginActiveSignal = [RACSignal combineLatest:@[validphoneNumSignal,validPasswordSignal] reduce:^id(NSNumber *phonenumValid, NSNumber *passwordValid){
        
        return @([phonenumValid boolValue] && [passwordValid boolValue]);
    }];
    
    [loginActiveSignal subscribeNext:^(NSNumber *loginActiveSignal) {
        
        if ([loginActiveSignal boolValue]) {
            _loginButton.enabled = YES;
            _loginButton.backgroundColor = [UIColor redColor];
        }else{
            _loginButton.enabled = NO;
            _loginButton.backgroundColor = [UIColor grayColor];
        }
        
        
        
    }];

    
}

    
    
    
    
- (BOOL)isValidUsername:(NSString *)text{
    
    if (text.length>11) {
        text = [text substringFromIndex:11];
    }
    
    
    if (text.length == 11) {
        return YES;
    }else{
        return NO;
    }
    
    
    
}

- (BOOL)isValidPassword:(NSString *)text{
    
    if (text.length>5 && text.length<10) {
        return YES;
    }else{
        return NO;
    }
}



#pragma mark-
#pragma mark 文本框1
- (void)textFieldTest{
    
    [[_phoneNumTextField rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(UITextField *x) {
        
        if (x.text.length<5) {
            _loginButton.enabled = NO;
            
            _loginButton.backgroundColor = [UIColor blackColor];
        }else{
            _loginButton.enabled = YES;
            _loginButton.backgroundColor = [UIColor redColor];
        }
        
        NSLog(@"%@",x.text);
        
        
    }];

    
}

#pragma mark-
#pragma mark 手势2
- (void)tapGestureTest{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [[tap rac_gestureSignal] subscribeNext:^(UITapGestureRecognizer *tap) {
       
        NSLog(@"tap");
    }];
    [self.view addGestureRecognizer:tap];
}

#pragma mark-
#pragma mark 通知3
- (void)notificationTest{
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
       
        NSLog(@"键盘将要出现");
        
    }];
    
    //不需要removeNotification
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(id x) {
        
        NSLog(@"键盘将要隐藏");
        
    }];

}

#pragma mark-
#pragma mark 定时器4
- (void)timeTest{
    
    //延迟两秒做什么
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
       
        NSLog(@"执行两秒了");
        
    }];
    
    //每一秒做一次
//    [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate *date) {
//       
//        NSLog(@"%@",date);
//        
//    }];
    
    
    
    
}

- (void)delegateTest{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"RAC" message:@"好不好" preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"确定");
    }];
    
    [alertVC addAction:cancel];
    [alertVC addAction:ok];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
    
    
    
}

#pragma mark-
#pragma mark KVO 5

- (void)kvoTest{
    
    
    
}





    //=================================================================
    //                              分割线
    //=================================================================
    
#pragma mark-
#pragma mark 顺序合并
    //concat----- 使用需求：有两部分数据：想让上部分先执行，完了之后再让下部分执行（都可获取值）
    
- (void)concatTest{
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        NSLog(@"发送上部请求");
        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    
    RACSignal *singnalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        NSLog(@"发送下部请求");
        [subscriber sendNext:@"下部分数据"];
        return nil;
    }];
    
    
    RACSignal *concatSignal = [signalA concat:singnalB];
    
    [concatSignal subscribeNext:^(id x) {
       
        NSLog(@"%@",x);
        
    }];
    
    
}
- (void)ZipWithTest{
    
    
    
    
    
    
    
    
    
}
    
    
    

    
    
    
    
    
    
    





















- (IBAction)commentAction:(id)sender {
    //代理
    [self delegateTest];

}


- (IBAction)loginButtonAction:(id)sender {
    
    NSLog(@"登陆");
    
}

- (IBAction)registerButtonAction:(id)sender {
    NSLog(@"注册");
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
    
}


@end
