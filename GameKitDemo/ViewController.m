//
//  ViewController.m
//  GameKitDemo
//
//  Created by Momo on 16/4/26.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>
@interface ViewController ()<GKPeerPickerControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (IBAction)buildConnect:(UIButton *)sender;
- (IBAction)sendData:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *connectStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property (nonatomic,strong) GKSession * session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:tap];
}
- (IBAction)buildConnect:(UIButton *)sender {
    //1.创建设备列表控制器 (iOS7.0以下才可以用)
    GKPeerPickerController * ppc = [[GKPeerPickerController alloc]init];
    
    //2.设置代理
    ppc.delegate = self;
    
    //3.显示控制器  销毁则是dismiss
    [ppc show];
}

- (IBAction)sendData:(UIButton *)sender {
    if (self.imageView.image == nil) {
        return;
    }
    
    NSData * data = UIImagePNGRepresentation(self.imageView.image);
    [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}


#pragma mark -- GKPeerPickerControllerDelegate
/**
    连接到某个设备就会调用
    peerID 设备的蓝牙ID
    session 连接会话（通过session通道传输和发送数据）要保存起来这个session，因为传送数据的时候需要这个通道
 */
-(void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session{
    
    
    // 1.连接结束后 销毁蓝牙连接显示设备的控制器
    [picker dismiss];
    
    // 2.保存session 作为传送数据的通道
    self.session = session;
    
    // 3.处理接收的数据 (Handler:处理接收数据的句柄对象)
    //   接收到蓝牙设备的数据就会自动调用self的 -receiveData:fromPeer:inSession:context:
    [self.session setDataReceiveHandler:self withContext:nil];
    
    NSLog(@"didConnectPeer --- %@",peerID);
}

#pragma mark - 接收到蓝牙设备传输的数据，就会自动调用
-(void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context{
    self.imageView.image = [UIImage imageWithData:data];
    self.sendStatusLabel.text = @"图片接收成功";
    
    // 将图片写入相册
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil);
}

#pragma mark - 点击取消时调用该函数
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker{
    
}

#pragma mark - 设备连接或断开连接时调用该方法
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state){
        case GKPeerStateConnected:
            NSLog(@"connected");
            self.connectStatusLabel.text = [NSString stringWithFormat:@"连接设备%@",peerID];
            break;
            
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            self.session = nil;
            self.connectStatusLabel.text = @"没有连接";
            self.sendStatusLabel.text = @"没有图片发送";
            break;
        default:
            break;
    }
}

#pragma mark - 手势（打开相册 选择相片）
- (void)tapClick:(UITapGestureRecognizer *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        //如果不是相册 则返回
        return;
    }
    
    // 1.创建图片选择控制器
    UIImagePickerController * ipc = [[UIImagePickerController alloc]init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // 2.设置代理
    ipc.delegate = self;
    
    // 3.显示控制器
    [self presentViewController:ipc animated:YES completion:nil];
    
}

#pragma mark - 监听图片选择
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    // 1.选择完图片后 销毁图片选择控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 2.显示选中的图片
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    
    
}








@end
