//
//  SCXPlayer.m
//  AVPlayer视频播放库
//
//  Created by 孙承秀 on 2017/2/28.
//  Copyright © 2017年 孙承秀. All rights reserved.
//

#import "SCXPlayer.h"
#import <UIKit/UIKit.h>

// 获取bundle下面的图片
#define bundleImage(file) [@"SCXPlayer.bundle" stringByAppendingPathComponent:file]

#define frameBundleImage(file) [@"Frameworks/SCXPlayer.framework/WMPlayer.bundle" stringByAppendingPathComponent:file]

#define Ipad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// 静态无返回值函数，用一个指针
static void *playerStatusObserContext = &playerStatusObserContext;

// 在非全屏和全屏的情况下，手指滑动调节的有效范围
#define kHalfWidth self.frame.size.width / 2

#define kHalfHeight self.frame.size.height / 2

@implementation SCXPlayer

#pragma mark - 初始化
-(instancetype)init{

    if (self = [super init]) {
        
        [self initSCXPlayer];
        
    }
    return self;

}

-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        [self initSCXPlayer];
        
    }
    return self;
}
#pragma mark -初始化一些界面和基本配置
- (void)initSCXPlayer{
    
    // 配置界面
    [self configFrame];
    
    // 配置本界面基本属性
    [self configSelfInfo];
    
    // 添加手势
    [self addTapGesture];
    [self addDoubleTapGesture];
   
    //添加监听通知，监听程序处于前台或者后台状态
    [self addNotificationInView];
    
    
}

/**
 配置本界面一些基本属性
 */
- (void)configSelfInfo{

    // 默认没有记忆功能
    self.seekTime = 0.0;
    // 关闭按钮样式
    self.closeBtnType = 0;
    // 子试图是否根据父试图改变自己的大小
    self.autoresizesSubviews = NO;
    self.backgroundColor = [UIColor blackColor];
    

}

/**
 配置界面
 */
- (void)configFrame{
    
    // 菊花loading
    [self.loadingActivityIndicatorView startAnimating];
    [self bringSubviewToFront:self.loadingActivityIndicatorView];
    [self bringSubviewToFront:self.topToolBar];
    [self bringSubviewToFront:self.bottomToolBar];
    // 配置小视频界面frame
    [self configViewFrame];

}

/**
 给界面添加监听前后台通知
 */
- (void)addNotificationInView{

    // 添加程序进入前后台的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appwillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

/**
给界面添加单击手势
 */
- (void)addTapGesture{

    // 给当前view天机单击手势
    self.viewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTap:)];
    self.viewTap.numberOfTapsRequired = 1;
    self.viewTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:self.viewTap];
    
}

/**
 给界面添加双击手势
 */
- (void)addDoubleTapGesture{

    
    // 添加双击手势
    self.viewDoubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    self.viewDoubleTap.numberOfTapsRequired = 2;// 两次
    // 单击需要在双击之后
    [self.viewTap requireGestureRecognizerToFail:self.viewDoubleTap];
    [self addGestureRecognizer:self.viewDoubleTap];
    
}
#pragma mark - 配置viewFrame

/*************  配置位置frame ***************/
- (void)configViewFrame{

    // 菊花loading位置
    [self.loadingActivityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    
    // 头部toolBar位置
    [self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
        make.top.equalTo(self).with.offset(0);
    }];
    
    // 底部toolBar
    [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self).with.offset(0);
        
    }];
    
    // 开始暂停按钮
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomToolBar.mas_left).with.offset(0);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.bottomToolBar).with.offset(0);
        make.width.mas_equalTo(40);
    }];
    /*
    // 声音slider
    [self.volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(50);
        make.left.mas_equalTo(self.mas_left).offset(0);
        make.bottom.mas_equalTo(self).offset(-50);
        make.width.mas_equalTo(120);
        
    }];
    */
    // 进度slider
    [self.progresseSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomToolBar).with.offset(45);
        make.right.equalTo(self.bottomToolBar).with.offset(-45);
        make.center.equalTo(self.bottomToolBar);
    }];
    
    // 显示加载了多少的progressView
    [self.loadingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progresseSlider);
        make.right.equalTo(self.progresseSlider);
        make.center.equalTo(self.progresseSlider).with.offset(0.7);
    }];
    
    // 全屏按钮
    [self.fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomToolBar).with.offset(0);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.bottomToolBar).with.offset(0);
        make.width.mas_equalTo(40);
        
    }];
    
    // 左边显示时间label
    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomToolBar).with.offset(45);
        make.right.equalTo(self.bottomToolBar).with.offset(-45);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.bottomToolBar).with.offset(0);
    }];
    
    // 右边显示时间的label
    [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomToolBar).with.offset(45);
        make.right.equalTo(self.bottomToolBar).with.offset(-45);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.bottomToolBar).with.offset(0);
    }];
    
    // 关闭按钮
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topToolBar).with.offset(5);
        make.height.mas_equalTo(30);
        make.top.equalTo(self.topToolBar).with.offset(5);
        make.width.mas_equalTo(30);
        
    }];
    
    // 视频标题label
    [self.titleNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topToolBar).with.offset(45);
        make.right.equalTo(self.topToolBar).with.offset(-45);
        make.center.equalTo(self.topToolBar);
        make.top.equalTo(self.topToolBar).with.offset(0);
        
    }];
    
    
    [self.loadFailedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(@30);
        
    }];
}


#pragma mark ------------------ setter方法，逻辑处理 -------------------

/**
 通过传入URL来配置player，player需要配置playerLayer才可以展示出来

 @param urlString 视频URL地址，可以是网络或者本地URL
 */
-(void)setUrlString:(NSURL *)urlString{

    _urlString = urlString;
    self.currentItem = [AVPlayerItem playerItemWithURL:urlString];
    
    // 设置当前播放状态,初次默认为缓冲状态
    self.playingState = SCXPlayerStateBuffering;
    
    // 设置player
    self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    self.player.usesExternalPlaybackWhileExternalScreenIsActive=YES;
    
    // 设置player展示层
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    // 设置展示层的填充状态
    //AVLayerVideoGravityResize,       // 非均匀模式。两个维度完全填充至整个视图区域
    //AVLayerVideoGravityResizeAspect,  // 等比例填充，直到一个维度到达区域边界
    //AVLayerVideoGravityResizeAspectFill, // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    // 设置展示层的frame
    self.playerLayer.frame = self.frame;
    
    // 将视频展示层添加到当前view的layer上面
    [self.layer insertSublayer:self.playerLayer atIndex:0];
 
}

/**
 设置返回按钮样式

 */
-(void)setCloseBtnType:(SCXPlayerCloseBtnType)closeBtnType{

    switch (closeBtnType) {
        case SCXPlayerCloseBtnTypePop:
        {
            [_closeBtn setImage:[UIImage imageNamed:bundleImage(@"play_back.png")] ?: [UIImage imageNamed:frameBundleImage(@"play_back.png")] forState:UIControlStateNormal];
            [_closeBtn setImage:[UIImage imageNamed:bundleImage(@"play_back.png")] ?: [UIImage imageNamed:frameBundleImage(@"play_back.png")] forState:UIControlStateSelected];
        }
            break;
            
        default:
        {
            [_closeBtn setImage:[UIImage imageNamed:bundleImage(@"close")] ?: [UIImage imageNamed:frameBundleImage(@"close")] forState:UIControlStateNormal];
            [_closeBtn setImage:[UIImage imageNamed:bundleImage(@"close")] ?: [UIImage imageNamed:frameBundleImage(@"close")] forState:UIControlStateSelected];
        }
            break;
    }

}
- (NSURL *)customSchemeURL {
    // // NSURLComponents用来替代NSMutableURL，可以readwrite修改URL，这里通过更改请求策略，将容量巨大的连续媒体数据进行分段，分割为数量众多的小文件进行传递。采用了一个不断更新的轻量级索引文件来控制分割后小媒体文件的下载和播放，可同时支持直播和点播
    NSURLComponents * components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:_urlString] resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

/*************  当前playerItem-setter方法 ***************/
-(void)setCurrentItem:(AVPlayerItem *)currentItem{

    if (_currentItem == currentItem) {
        return;
    }
    if (_currentItem) {
        
        // 如果当前存在一个播放item了 ， 再进入一个的时候，需要将上次的一些监听移除
        // 移除播放完成状态监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        
        // 移除播放状态监听
        // 预播放状态，有三种情况AVPlayerItemStatusUnknown,AVPlayerItemStatusReadyToPlay,AVPlayerItemStatusFailed
        [_currentItem removeObserver:self forKeyPath:@"status"];
        
        // 移除播放进度监听
        [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];

        // 移除缓冲数据监听
        // seekTIme之后，如果缓冲数据为空，或者有效时间内缓冲无法补充到时间，那么播放失败,相当于在看视频的时候，使劲拉了一下进度条到很远，而视频并没有缓冲到那么多，那么就会出现一个菊花缓冲状态
        [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        
        // 移除是否可以正常播放监听，seekTime之后，拖动滑竿，菊花转，当到了这个状态之后，就会正常播放，菊花消失,相当于readyToPlay,和上面的配合使用，首先缓冲，如果缓冲为空货不够，则菊花出现，有缓冲数据了，那么就会播放
        [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        
        
    }
    _currentItem = currentItem;
    if (_currentItem) {
        // 给当前item添加一些监听
        [_currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:playerStatusObserContext];
        
        [_currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:playerStatusObserContext];
        
        [_currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:playerStatusObserContext];
        
        [_currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:playerStatusObserContext];
        
        [self.player replaceCurrentItemWithPlayerItem:_currentItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    }

}

/*************  当前播放状态-setter ***************/
-(void)setPlayingState:(SCXPlayerState)playingState{

    // 用来设置当前菊花是否需要显示
    if (playingState == SCXPlayerStateBuffering) {
        
        [self.loadingActivityIndicatorView startAnimating];
        
    }
    else {
        
        [self.loadingActivityIndicatorView stopAnimating];
    }
    

}


#pragma mark ---------------------- 事件处理 ------------------------

/*************  开始或暂停按钮点击事件 ***************/
- (void)playOrPauseVideo:(UIButton *)btn{
    if (self.player.rate != 1) {
        btn.selected = NO;
        // 播放到末尾从头播放
        if ([self currentTime] == [self duration]) {
            [self setCurrentTime:0];
        }
        
        [self.player play];
    }
    else{
        btn.selected = YES;
        [self.player pause];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(scxplayer:clickPlayOrPauseBtn:)]) {
        [self.delegate scxplayer:self clickPlayOrPauseBtn:btn];
    }
}
/*************  系统亮度slider调节 ***************/
- (void)systemLightUpdate:(UISlider *)lightSlider{

}
/*************  音量调节slider ***************/
- (void)volumeUpdateValue:(UISlider *)volumeSlider{

}
/*************  关闭按钮点击事件 ***************/
- (void)closeVideo:(UIButton *)btn{
    if (self.description && [self.delegate respondsToSelector:@selector(scxplayer:closeVideo:)]) {
        [self.delegate scxplayer:self closeVideo:btn];
    }
}
/*************  拖拽进度条点击方法 ***************/
- (void)progressDragUpdate:(UISlider *)progressSlider{
    
    self.isDragingSlider = YES;

}
/*************  点击进度条 ***************/
- (void)progressSliderTapUpdate:(UISlider *)slider{
    
    self.isDragingSlider = NO;
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, self.player.currentTime.timescale)];

}
/*************  进度条上面的单击手势 ***************/
- (void)progressSliderTap:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.progresseSlider];
    CGFloat value = (self.progresseSlider.maximumValue - self.progresseSlider.minimumValue) * (point.x / self.progresseSlider.frame.size.width);
    [self.progresseSlider setValue:value];
    [self.player seekToTime:CMTimeMakeWithSeconds(value, self.player.currentTime.timescale)];
    if (self.player.rate != 1) {
        if ([self currentTime] == [self duration]) {
            [self setCurrentTime:0];
        }
        self.playOrPauseBtn.selected = NO;
        [self.player play];
    }
}
/*************  点击当前界面的单击手势 ***************/
- (void)viewTap:(UITapGestureRecognizer *)tap{
    
    // 首先取消延迟函数，取消之前五秒后自动关闭的方法
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideTopViewAndBottomView) object:nil];
    
    // 用代理方法通知，用户点击view的单击手势了
    if (self.delegate && [self.delegate respondsToSelector:@selector(scxplayer:singleTapGestureAction:)]) {
        [self.delegate scxplayer:self singleTapGestureAction:tap];
    }
    [self.autoDissmissTimer invalidate];
    self.autoDissmissTimer = nil;
    // 重新执行五秒后自动关闭事件
    self.autoDissmissTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(autoHideTopViewAndBottomView) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.autoDissmissTimer forMode:NSDefaultRunLoopMode];
    
    // 头部和尾部试图显示或者隐藏
    [UIView animateWithDuration:0.6 animations:^{
        if (self.bottomToolBar.hidden == YES) {
            self.bottomToolBar.hidden = NO;
            self.topToolBar.hidden = NO;
            self.volumeSlider.hidden = NO;
            self.closeBtn.hidden = NO;
        }
        else{
            self.bottomToolBar.hidden = YES;
            self.topToolBar.hidden = YES;
            self.volumeSlider.hidden = YES;
            self.closeBtn.hidden = YES;
        }
    }];
}
/*************  双击事件 ***************/
- (void)doubleTap:(UITapGestureRecognizer *)tap{
    
    // 首先判断是否在播放中
    if (self.player.rate != 1.0) {
        if ([self currentTime] == [self duration]) {
            [self setCurrentTime:0];
        }
        self.playOrPauseBtn.selected = NO;
        [self.player play];
    }
    else{
        self.playOrPauseBtn.selected = YES;
        [self.player pause];
    }
    
    // 通过代理通知双击了
    if (self.delegate && [self.delegate respondsToSelector:@selector(scxplayer:doubleTapGestureAction:)]) {
        [self.delegate scxplayer:self doubleTapGestureAction:tap];
    }
    
    // 展示工具栏
    [UIView animateWithDuration:0.5 animations:^{
        self.topToolBar.hidden = NO;
        self.bottomToolBar.hidden = NO;
        self.closeBtn.hidden = NO;
        self.volumeSlider.hidden = NO;
    }];
}
/*************  全屏点击事件 ***************/
- (void)fullScreenAction:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(scxplayer:didFullScreen:)]) {
        [self.delegate scxplayer:self didFullScreen:btn];
    }
}
/*************  程序失活的时候 ***************/
- (void)appwillResignActive:(NSNotification *)note{


}
/*************  程序进入后台的时候 ***************/
- (void)appDidEnterBackground:(NSNotification *)note{

    // 进入后台判断用户是否设置了允许后台播放
    if (self.playOrPauseBtn.selected == NO) {
        if (self.isAllowVideoPlayBackground) {
            // 如果是播放中
            // AVMediaCharacteristicLegible字幕资源，AVMediaCharacteristicAudible 音轨资源，AVMediaCharacteristicVisual 视频资源。
            // 获取轨道数组
            // 此资源中包含的所有的AVAssetTrack , AVAsset 可以通过标识符,媒体类型或媒体特征等信息找到相应的track。
            NSArray *tracks = [self.currentItem tracks];
            for (AVPlayerItemTrack *track in tracks) {
                // 获取视频资源
                
                if ([track.assetTrack hasMediaCharacteristic:AVMediaCharacteristicVisual]) {
                    track.enabled = YES;
                }
            }
            // 必须设置为nil才能后台播放
            // 如果是画中画功能，那么这个地方不能设置为nil，如果是手机端，后台播放有声音的话，将这句话打开
            if (!Ipad) {
                
                 self.playerLayer.player = nil;
            }
            else{
            
                // 后台进行画中画功能
                if (self.delegate && [self.delegate respondsToSelector:@selector(scxplayerBegihPictureInPicture:)]) {
                    [self.delegate scxplayerBegihPictureInPicture:self];
                }
            }
           
            [self.player play];
            
            self.playingState = SCXPlayerStatePlaying;

        }
        else{
            self.playOrPauseBtn.selected = YES;
            self.playingState = SCXPlayerStateStoped;
        }
        
    }
    else{
        self.playOrPauseBtn.selected = YES;
        self.playingState = SCXPlayerStateStoped;
    }

}
/*************  程序将进入前台的时候 ***************/
- (void)appWillEnterForeground:(NSNotification *)note{
    if (self.playOrPauseBtn.selected == NO) {
        NSArray *arr = [self.currentItem tracks];
        for (AVPlayerItemTrack *itemTrack in arr) {
            if ([itemTrack.assetTrack hasMediaCharacteristic:AVMediaCharacteristicVisual]) {
                itemTrack.enabled = YES;
            }
        }
        self.playerLayer =[AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.frame;
        [self.player play];
        [self.layer insertSublayer:self.playerLayer atIndex:0];
        self.playerLayer.videoGravity = AVLayerVideoGravityResize;
        self.playingState = SCXPlayerStatePlaying;
        
    }
    else{
        self.playingState = SCXPlayerStateStoped;
    }

}
/*************  程序激活的时候 ***************/
- (void)appBecomeActive:(NSNotification *)note{

}

/*************  视频播放完成监听 ***************/
- (void)moviePlayDidEnd:(NSNotification *)note{

    // 通过代理通知播放完成了
    if (self.delegate && [self.delegate respondsToSelector:@selector(scxplayerDidFinishPlayVideo:)]) {
        [self.delegate scxplayerDidFinishPlayVideo:self];
    }
    
    // 设置播放状态
    self.playingState = SCXPlayerStateFinished;
    
    // 将时间定位到头部重新播放
    [self.player seekToTime:CMTimeMakeWithSeconds(0, self.player.currentTime.timescale)];
    [UIView animateWithDuration:0.5 animations:^{
        self.playOrPauseBtn.selected = YES;
        self.bottomToolBar.hidden = NO;
        self.topToolBar.hidden = NO;
        self.closeBtn.hidden = NO;
        self.volumeSlider.hidden = NO;
    }];
}

#pragma mark - 自动隐藏头部和尾部试图，如果说用户播放视频了，5秒钟没有点击界面的话吗，那么将功能菜单自动隐藏，进入观看模式
- (void)autoHideTopViewAndBottomView{

    // rate == 1.0 说明正在播放
    if (self.player.rate == 0.0f && self.currentTime != self.duration ){
        // 说明是暂停状态
    }
    else{
    
        [UIView animateWithDuration:0.5 animations:^{
            if (self.bottomToolBar.hidden == NO) {
                self.topToolBar.hidden = YES;
                self.bottomToolBar.hidden = YES;
                self.closeBtn.hidden = YES;
                self.volumeSlider.hidden = YES;
            }
            
        }];
    }
}
#pragma mark - 使用定时器，每隔一秒监听一下播放状态，改变滑块的进度
- (void)initTimerToObserPlayer{
    CMTime cmtime = [self playItemDuration];
    double time = CMTimeGetSeconds([self playItemDuration]);
    // 判断是否为无效值
    if (CMTIME_IS_INVALID(cmtime)) {
        return;
    }
    // 判断是否游街
    if (isfinite(time) ){
    
    }
    // 给AVPlayer 添加time Observer 有利于我们去检测播放进度
   // 但是添加以后一定要记得移除，其实不移除程序不会崩溃，但是这个线程是不会释放的，会占用你大量的内存资源
    __block typeof(self)weakSelf = self;
    self.monitorTimer =  [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
        [weakSelf  monitorProgress];
    }];
}
#pragma mark - 监听播放进度
- (void)monitorProgress{
    CMTime cmTime = [self playItemDuration];
    double time = CMTimeGetSeconds(cmTime);
    if (CMTIME_IS_INVALID(cmTime)) {
        [self.progresseSlider setValue:0 animated:YES];
        return;
    }
    if (isfinite(time)) {
        CGFloat min = [self.progresseSlider minimumValue];
        CGFloat max = [self.progresseSlider maximumValue];
        // 当前已经播放的时间
        double currentTime = CMTimeGetSeconds([self.player currentTime]);
        double otherTime = time - currentTime;
        if (!self.isDragingSlider) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 设置左边观看时间和右边未观看时间
                self.leftTimeLabel.text = [self convertTime:currentTime];
                self.rightTimeLabel.text = [self convertTime:otherTime];
                
                // 当前进度条的value
               [self.progresseSlider setValue:(currentTime) / time * (max - min) + min ];
            });
            
        }
    }
}
#pragma mark - 时间的转化
- (NSString *)convertTime:(CGFloat)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    if (time / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    }
    else{
        [formatter setDateFormat:@"mm:ss"];
    }
    return [formatter stringFromDate:date   ];
}


#pragma mark - 视频的一些事件处理

/*************  获取缓冲时间 ***************/
- (NSTimeInterval)getAvailableVideoTime{
    NSArray *arr = [_currentItem loadedTimeRanges];
    CMTimeRange range = [arr.firstObject CMTimeRangeValue];
    CGFloat start = CMTimeGetSeconds(range.start) ;
    CGFloat end = CMTimeGetSeconds(range.duration);
    return start + end;
    
}
/*************  设置当前播放时间 ***************/
- (void)setCurrentTime:(CGFloat)time{

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player seekToTime:CMTimeMakeWithSeconds(time, self.currentItem.currentTime.timescale)];
    });

}

/**
 获取当前播放的时间

 @return 当前播放的时间
 */
-(double)currentTime{
    if (self.player) {
        return CMTimeGetSeconds(self.player.currentTime);
    }
    else return 0;
}
-(double)duration{

    AVPlayerItem *item = self.player.currentItem;
    if (self.player && item.status == AVPlayerItemStatusReadyToPlay) {
        return CMTimeGetSeconds([[item asset] duration]);
    }
    else return 0;
}
- (CMTime)playItemDuration{

    AVPlayerItem *item = self.player.currentItem;
    if (self.player && item.status == AVPlayerItemStatusReadyToPlay) {
        return item.duration;
    }
    return kCMTimeZero;

}
- (void)seekToTimePlay:(double)time{
    if (self.player && self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if (time > [self duration]) {
            time = [self duration];
        }
        if (time <= 0 ) {
            time = 0;
        }
    }
    
    // 跳到指定时间播放
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
}
/*************  用五秒的时间来缓冲 ***************/
- (void)loadTimeRange{
    self.playingState = SCXPlayerStateBuffering;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self play];
        [self.loadingActivityIndicatorView stopAnimating];
    });
}
/*************  播放 ***************/
- (void)play{
    [self playOrPauseVideo:self.playOrPauseBtn];
}
/*************  暂停 ***************/
- (void)pause{
    [self playOrPauseVideo:self.playOrPauseBtn];
}

#pragma mark ------------------ KVO监听(非常重要！) ------------------
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{

    if (context == playerStatusObserContext) {
        
        // 监听播放状态
        if ([keyPath isEqualToString:@"status"]) {
            
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            
            switch (status) {
                case AVPlayerStatusUnknown:
                {
                    [self.loadingActivityIndicatorView startAnimating];
                    [self.loadingProgressView setProgress:0 animated:YES];
                    self.playingState = SCXPlayerStateBuffering;
                
                }
                    break;
                    case AVPlayerStatusReadyToPlay:
                {
                    // 设置滑块的值
                    if (CMTimeGetSeconds(_currentItem.duration)) {
                        double time = CMTimeGetSeconds(_currentItem.duration);
                        // 判断是否为合法值
                        if (!isnan(time)) {
                            self.progresseSlider.maximumValue =  CMTimeGetSeconds(self.player.currentItem.duration);
                        }
                    }
                    
                    // 每隔一秒监听一下播放状态,用来改变滑块的进度
                    [self initTimerToObserPlayer];
                    
                    //五秒后将功能菜单关闭
                    if (self.autoDissmissTimer == nil) {
                        self.autoDissmissTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(autoHideTopViewAndBottomView) userInfo:nil repeats:YES ];
                        [[NSRunLoop currentRunLoop] addTimer:self.autoDissmissTimer forMode:NSDefaultRunLoopMode];
                    }
                    
                    // 通过代理方法通知准备播放
                    if (self.delegate && [self.delegate respondsToSelector:@selector(scxplayerReadyToPlay:SCXPlayerState:)]) {
                        [self.delegate scxplayerReadyToPlay:self SCXPlayerState:SCXPlayerStateReadyToPlay];
                    }
                    
                    [self.loadingActivityIndicatorView stopAnimating];
                    
                    // 如果有存储播放时间，那么从指定位置开始i
                    if (self.seekTime) {
                        [self seekToTimePlay:self.seekTime];
                    }
                }
                    break;
                case AVPlayerStatusFailed:{
                    self.playingState = SCXPlayerStateFailed;
                    if (self.delegate && [self.delegate respondsToSelector:@selector(scxplayerFailedPlay:SCXPlayerState:)]) {
                        [self.delegate scxplayerFailedPlay:self SCXPlayerState:SCXPlayerStateFailed];
                    }
                    NSError *error = [self.player.currentItem error];
                    if (error) {
                        self.loadFailedLabel.hidden = NSNotFound;
                        [self.loadingActivityIndicatorView stopAnimating];
                        [self bringSubviewToFront:self.loadFailedLabel];
                    }
                }
                    break;
                default:
                    break;
            }
            
        }
        else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
            // 缓冲的时候，展现缓冲那个进度条
            NSTimeInterval timeInterval =[self getAvailableVideoTime];
            CGFloat totalTime = CMTimeGetSeconds(self.currentItem.duration) ;
            self.loadingProgressView.progress = timeInterval / totalTime;
            self.loadingProgressView.progressTintColor = [UIColor colorWithRed:0.7 green:0 blue:0 alpha:0.5];
            
          
        }
        else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
            [self.loadingActivityIndicatorView startAnimating];
            if (self.currentItem.playbackBufferEmpty) {
                self.playingState = SCXPlayerStateBuffering;
                [self loadTimeRange];
            }
        }
        else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
            // 缓冲好的时候
            [self.loadingActivityIndicatorView stopAnimating];
            if (self.currentItem.playbackLikelyToKeepUp && self.playingState == SCXPlayerStateBuffering) {
                self.playingState = SCXPlayerStatePlaying;
            }
        }
    }

}


#pragma mark - 手指触摸事件
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in event.allTouches) {
        self.firstPoint = [touch locationInView:self];
    }
    self.volumeSlider.value = self.systemSlider.value;
    // 用来判断是调节音量还是进度
    self.originPoint = self.firstPoint;
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in event.allTouches) {
        self.secondPoint= [touch locationInView:self];
    }
    
    // 垂直方向的偏移距离
    CGFloat herHeight = fabs(self.secondPoint.y - self.originPoint.y);
    
    // 水平方向的偏移距离
    CGFloat horFloat = fabs(self.secondPoint.x - self.originPoint.x);
    
    
    // 如果垂直方向偏移的距离大于水平方向偏移的距离，那么证明是上下滑动，那么调节的就是音量或者亮度，反之调节的是进度
    if (herHeight > horFloat) {
        
        // 调节音量或者亮度
        // 在飞全屏的情况下
        if (!self.isFullScreen) {
            
            // 如果在非全屏的情况下，那么声音的有效范围是屏幕宽度的前一半，亮度的有效值就是屏幕的后一半
            // 调节音量
            if (self.originPoint.x < kHalfWidth) {
               
                // 下面这样写的目的是，假如说我们把slider的总值看为1，那么同样我们同样也可以把总值看为500，600，甚至800，1000，那么就把他转化为在view上面移动的距离，手指移动了800个点，那么slider等于1，意思就是说吗，数值定义的越大，那么手指需要滑动的距离就越长达到1，自己定义.
                self.systemSlider.value += (self.firstPoint.y - self.secondPoint.y)/600.0;
                self.volumeSlider.value = self.systemSlider.value;
                
            }
            // 调节亮度
            else{
                self.lightSlider.value += (self.firstPoint.y - self.secondPoint.y) / 600.0;
                [[UIScreen mainScreen] setBrightness:self.lightSlider.value];
            }
            
        }
        else{
            
            // 调节音量
            if (self.originPoint.x < kHalfHeight) {
                
                // 下面这样写的目的是，假如说我们把slider的总值看为1，那么同样我们同样也可以把总值看为500，600，甚至800，1000，那么就把他转化为在view上面移动的距离，手指移动了800个点，那么slider等于1，意思就是说吗，数值定义的越大，那么手指需要滑动的距离就越长达到1，自己定义.
                self.systemSlider.value += (self.firstPoint.y - self.secondPoint.y)/600.0;
                self.volumeSlider.value = self.systemSlider.value;
                
            }
            // 调节亮度
            else{
            
                self.lightSlider.value += (self.firstPoint.y - self.secondPoint.y) / 600.0;
                [[UIScreen mainScreen] setBrightness:self.lightSlider.value];
                
            }
            
        }
    }
    // 调节的是进度
    else{
    
        // 进度不需要设置最大值，因为视频没有最大值，视频是根据视频的时长而设置的
        // 这里要注意，因为slider的最大值是根据视频的总时间设置的，所以说，视频的一秒就相当于slider的1；
        self.progresseSlider.value -= (self.firstPoint.x - self.secondPoint.x);
        [self.player seekToTime:CMTimeMakeWithSeconds(self.progresseSlider.value, self.player.currentTime.timescale)];
        
        // 如果视频暂停了或者滑动的快了，可能导致视频不播放，此时让视频播放
        if (self.player.rate != 1.0f) {
            if ([self currentTime] == [self duration]) {
                [self setCurrentTime:0];
            }
            self.playOrPauseBtn.selected = NO;
            [self.player play];
        }
    }

    self.firstPoint = self.secondPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.firstPoint = self.secondPoint = CGPointZero;
}

#pragma mark -----------------------懒加载----------------------------

/*************  菊花加载提示 ***************/
-(UIActivityIndicatorView *)loadingActivityIndicatorView{

    if (!_loadingActivityIndicatorView) {
        _loadingActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_loadingActivityIndicatorView];
    }
    return _loadingActivityIndicatorView;
}
/*************  顶部工具栏 ***************/
-(UIView *)topToolBar{

    if (!_topToolBar) {
        _topToolBar = [[UIView alloc]init];
        _topToolBar.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
        [self addSubview:_topToolBar];
    }
    return _topToolBar;
}
/*************  底部工具栏 ***************/
-(UIView *)bottomToolBar{
    if (!_bottomToolBar) {
        _bottomToolBar = [[UIView alloc]init];
        _bottomToolBar.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
        [self addSubview:_bottomToolBar];
    }
    return _bottomToolBar;
}
/*************  开始或暂停按钮 ***************/
-(UIButton *)playOrPauseBtn{

    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [[UIButton alloc]init];
        _playOrPauseBtn.showsTouchWhenHighlighted = YES;
        [_playOrPauseBtn setImage:[UIImage imageNamed:bundleImage(@"pause")]?:[UIImage imageNamed:frameBundleImage(@"pause")] forState:UIControlStateNormal];
        [_playOrPauseBtn setImage:[UIImage imageNamed:bundleImage(@"play")]?:[UIImage imageNamed:frameBundleImage(@"play")] forState:UIControlStateSelected];
        [_playOrPauseBtn addTarget:self action:@selector(playOrPauseVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomToolBar addSubview:_playOrPauseBtn];
    }
    return _playOrPauseBtn;
}
/*************  亮度slider ***************/
-(UISlider *)lightSlider{

    if (!_lightSlider) {
        _lightSlider = [[UISlider alloc]init];
        _lightSlider.tag = 1000;
        _lightSlider.hidden = NO;
        _lightSlider.minimumValue = 0;
        _lightSlider.maximumValue = 1;
        // 等于屏幕的亮度值
        _lightSlider.value = [UIScreen mainScreen].brightness;;
        [_lightSlider addTarget:self action:@selector(systemLightUpdate:) forControlEvents:UIControlEventValueChanged];
        // 按时不加这个
        //[self addSubview:_lightSlider];
    }
    return _lightSlider;
}
/*************  声音slider ***************/
-(UISlider *)volumeSlider{

    if (!_volumeSlider) {
        _volumeSlider = [[UISlider alloc] init];
        _volumeSlider.tag = 2000;
        _volumeSlider.minimumValue = 0;
        _volumeSlider.maximumValue = 1;
        
        // 先添加音量试图
        MPVolumeView *volumeView = [[MPVolumeView alloc]init];
        volumeView.frame = CGRectMake(-1000, -1000, 150, 100);
        [volumeView sizeToFit];
        UISlider *systemSlider = [[UISlider alloc] init];
        systemSlider.backgroundColor = [UIColor clearColor];
        // 获取音量那个控件,得到系统当前的音量
        for (UIControl *view in volumeView.subviews) {
            if ([view.superclass isSubclassOfClass:[UISlider  class]]) {
                systemSlider = (UISlider *)view;
                self.systemSlider = systemSlider;
            }
        }
        
        // 让音量调节控件默认的value等于系统的音量value
        _volumeSlider.value = systemSlider.value;
        _volumeSlider.minimumTrackTintColor = [UIColor greenColor];
        _volumeSlider.maximumTrackTintColor = [UIColor whiteColor];
        [_volumeSlider addTarget:self action:@selector(volumeUpdateValue:) forControlEvents:UIControlEventValueChanged];
        [_volumeSlider setThumbImage:[UIImage imageNamed:bundleImage(@"dot")] ?: [UIImage imageNamed:frameBundleImage(@"dot")]  forState:UIControlStateNormal];
        _volumeSlider.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
        // 暂时不加这个
        //[self addSubview:_volumeSlider];
    }
    return _volumeSlider;
}
/*************  进度条slider ***************/
-(UISlider *)progresseSlider{

    if (!_progresseSlider) {
        _progresseSlider = [[UISlider alloc]init];
        _progresseSlider.minimumValue = 0.0;
        [_progresseSlider setThumbImage:[UIImage imageNamed:bundleImage(@"dot")] ?: [UIImage imageNamed:frameBundleImage(@"dot")]  forState:UIControlStateNormal];
        _progresseSlider.minimumTrackTintColor = [UIColor greenColor];
        _progresseSlider.maximumTrackTintColor = [UIColor clearColor];
        _progresseSlider.value = 0.0;
        // 当拖拽滑块的时候 调用的方法
        [_progresseSlider addTarget:self action:@selector(progressDragUpdate:) forControlEvents:UIControlEventValueChanged];
        // 当点击slider的某一个位置的时候
        [_progresseSlider addTarget:self action:@selector(progressSliderTapUpdate:) forControlEvents:UIControlEventTouchUpInside];
        
        // 给progressSlider添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(progressSliderTap:)];
        self.pregressTap = tap;
        [_progresseSlider addGestureRecognizer:tap];
        [self.bottomToolBar addSubview:_progresseSlider];
        
    }
    return _progresseSlider;
}
/*************  已经缓存了的进度progressView ***************/
-(UIProgressView *)loadingProgressView{

    if (!_loadingProgressView) {
        _loadingProgressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _loadingProgressView.progressTintColor = [UIColor clearColor];
        _loadingProgressView.trackTintColor    = [UIColor lightGrayColor];
        [self.bottomToolBar addSubview:_loadingProgressView];
        [_loadingProgressView setProgress:0.0 animated:NO];
        [self.bottomToolBar sendSubviewToBack:_loadingProgressView];
        
    }
    return _loadingProgressView;

}
/*************  全屏按钮 ***************/
-(UIButton *)fullScreenButton{

    if (!_fullScreenButton) {
        _fullScreenButton = [[UIButton alloc]init];
        _fullScreenButton.showsTouchWhenHighlighted = YES;
        [_fullScreenButton addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
        [_fullScreenButton setImage:[UIImage imageNamed:bundleImage(@"fullscreen")] ?: [UIImage imageNamed:frameBundleImage(@"fullscreen")] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[UIImage imageNamed:bundleImage(@"nonfullscreen")] ?: [UIImage imageNamed:frameBundleImage(@"nonfullscreen")] forState:UIControlStateSelected];
        [self.bottomToolBar addSubview:_fullScreenButton];
    }
    return _fullScreenButton;
}
/*************  左边已经观看时间label ***************/
-(UILabel *)leftTimeLabel{

    if (!_leftTimeLabel) {
        _leftTimeLabel = [[UILabel alloc]init];
        _leftTimeLabel.textAlignment = NSTextAlignmentLeft;
        _leftTimeLabel.textColor = [UIColor whiteColor];
        _leftTimeLabel.backgroundColor = [UIColor clearColor];
        _leftTimeLabel.font = [UIFont systemFontOfSize:11];
        [self.bottomToolBar addSubview:self.leftTimeLabel];
    }
    return _leftTimeLabel;

}
/*************  右边剩余时间label ***************/
-(UILabel *)rightTimeLabel{

    if (!_rightTimeLabel) {
        _rightTimeLabel = [[UILabel alloc]init];
        _rightTimeLabel.textAlignment = NSTextAlignmentRight;
        _rightTimeLabel.textColor = [UIColor whiteColor];
        _rightTimeLabel.backgroundColor = [UIColor clearColor];
        _rightTimeLabel.font = [UIFont systemFontOfSize:11];
        [self.bottomToolBar addSubview:_rightTimeLabel];
    }
    return _rightTimeLabel;
}
/*************  关闭按钮 ***************/
-(UIButton *)closeBtn{

    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.showsTouchWhenHighlighted = YES;
        [_closeBtn addTarget:self action:@selector(closeVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self.topToolBar addSubview:_closeBtn];
    }
    return _closeBtn;
}
/*************  视频标题 ***************/
-(UILabel *)titleNameLabel{

    if (!_titleNameLabel) {
        _titleNameLabel = [[UILabel alloc]init];
        _titleNameLabel = [[UILabel alloc]init];
        _titleNameLabel.textAlignment = NSTextAlignmentCenter;
        _titleNameLabel.textColor = [UIColor whiteColor];
        _titleNameLabel.backgroundColor = [UIColor clearColor];
        _titleNameLabel.font = [UIFont systemFontOfSize:17.0];
        [self.topToolBar addSubview:_titleNameLabel];
    }
    return _titleNameLabel;
}
/*************  加载失败label   ***************/
-(UILabel *)loadFailedLabel{
    if (_loadFailedLabel==nil) {
        _loadFailedLabel = [[UILabel alloc]init];
        _loadFailedLabel.textColor = [UIColor whiteColor];
        _loadFailedLabel.textAlignment = NSTextAlignmentCenter;
        _loadFailedLabel.text = @"视频加载失败";
        _loadFailedLabel.hidden = YES;
        [self addSubview:_loadFailedLabel];
       
    }
    return _loadFailedLabel;
}

#pragma mark ------------------- 释放 -----------------------

- (void)resetPlayer{

    // 当前播放item置为nil
    self.currentItem = nil;
    
    //定位时间置为nil
    self.seekTime = 0;
    
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 关闭自动关闭头部和尾部试图定时器
    [self.autoDissmissTimer invalidate];
    self.autoDissmissTimer = nil;
    
    // 移除player
    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    
    // 移除playerLayer
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    

}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.player.currentItem cancelPendingSeeks];
    
    [self.player.currentItem.asset cancelLoading];
    
    [self.player pause];
    
    [self.player removeTimeObserver:self.monitorTimer];
    
    [_currentItem removeObserver:self forKeyPath:@"status"];
    
    [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    
    [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.playerLayer removeFromSuperlayer];
    
    [self.player replaceCurrentItemWithPlayerItem:nil];
    
    self.player = nil;
    
    self.currentItem = nil;
    
    self.playOrPauseBtn = nil;
    
    self.playerLayer = nil;
    
    self.autoDissmissTimer = nil;
    
    

}
@end
