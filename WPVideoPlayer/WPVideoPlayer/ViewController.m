//
//  ViewController.m
//  WPVideoPlayer
//
//  Created by 吴鹏 on 16/8/16.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define TOOLVIEWHEIGTH 40

@interface ViewController ()
{
    /**是否全屏*/
    BOOL isHalfScreen;
    
    /**是否隐藏toolview*/
    BOOL isHiddenToolView;
    

    float y;
    
}

@property (nonatomic , strong) AVPlayer * player;
@property (nonatomic , strong) UIView * contentView;
@property (nonatomic , strong) AVPlayerLayer * playerLayer;
@property (nonatomic , strong) NSArray * dataArray;
//**工具view*/
@property (nonatomic , strong) UIView * toolView;
@property (nonatomic , strong) UIButton * paseAndPlayBtn;
@property (nonatomic , strong) UIButton * fullScreenBtn;
@property (nonatomic , strong) UIView * xuanJiView;
@property (nonatomic , strong) NSMutableArray * btnArray;
@property (nonatomic , strong) UISlider * slider;

@property (nonatomic , strong) UILabel * startLable;
@property (nonatomic , strong) UILabel * endLable;
@property (nonatomic , strong) UIProgressView * progressView;

@property (nonatomic , strong) id timeObserver;



@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.btnArray = [NSMutableArray array];
    self.dataArray = @[@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4",
                       @"http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                       @"http://baobab.wdjcdn.com/14525705791193.mp4",
                       @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                       @"http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                       @"http://baobab.wdjcdn.com/1455782903700jy.mp4",
                       @"http://baobab.wdjcdn.com/14564977406580.mp4",
                       @"http://baobab.wdjcdn.com/1456316686552The.mp4",
                       @"http://baobab.wdjcdn.com/1456480115661mtl.mp4",
                       @"http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
                       @"http://baobab.wdjcdn.com/1455614108256t(2).mp4",
                       @"http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
                       @"http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
                       @"http://baobab.wdjcdn.com/1456734464766B(13).mp4",
                       @"http://baobab.wdjcdn.com/1456653443902B.mp4",
                       @"http://baobab.wdjcdn.com/1456231710844S(24).mp4"];
    
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.toolView];
    [self.view addSubview:self.fullScreenBtn];
    [self setFrame];
    [self setUI];
    [self refreshCurrentTime];
    
}

#pragma mark - property

- (UIView *)contentView
{
    if(!_contentView)
    {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame)/16*9)];
        _contentView.backgroundColor = [UIColor blackColor];
    }
    return _contentView;
}

-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem=[self getPlayItem:self.dataArray[0]];
        _player=[AVPlayer playerWithPlayerItem:playerItem];
        [self addObserverToPlayerItem:playerItem];
       
    }
    return _player;
}

- (AVPlayerLayer *)playerLayer
{
    if(!_playerLayer)
    {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self.contentView.layer addSublayer:_playerLayer];
         _playerLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}

- (UIView *)toolView
{
    if(!_toolView)
    {
        _toolView = [[UIView alloc]init];
        _toolView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [_toolView addSubview:self.paseAndPlayBtn];
        [_toolView addSubview:self.progressView];
        [_toolView addSubview:self.slider];
        [_toolView addSubview:self.startLable];
        [_toolView addSubview:self.endLable];
        
    }
    return _toolView;
}

- (UIButton *)paseAndPlayBtn
{
    if(!_paseAndPlayBtn)
    {
        _paseAndPlayBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 0, 30, TOOLVIEWHEIGTH)];
        [_paseAndPlayBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [_paseAndPlayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _paseAndPlayBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_paseAndPlayBtn addTarget:self action:@selector(paseAndPlayBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _paseAndPlayBtn;
}

- (UIButton *)fullScreenBtn
{
    if(!_fullScreenBtn)
    {
        _fullScreenBtn = [[UIButton alloc]init];
        [_fullScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
        [_fullScreenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _fullScreenBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _fullScreenBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _fullScreenBtn.layer.cornerRadius = 20;
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

- (UILabel *)startLable
{
    if(!_startLable)
    {
        _startLable = [[UILabel alloc]initWithFrame:CGRectMake(32, 0, 50, TOOLVIEWHEIGTH)];
        _startLable.textColor = [UIColor whiteColor];
        _startLable.font = [UIFont systemFontOfSize:14];
        _startLable.textAlignment = NSTextAlignmentCenter;
        _startLable.text = @"0:00";
    }
    return _startLable;
}

- (UILabel *)endLable
{
    if(!_endLable)
    {
        _endLable = [[UILabel alloc]init];
        _endLable.textColor = [UIColor whiteColor];
        _endLable.font = [UIFont systemFontOfSize:14];
        _endLable.textAlignment = NSTextAlignmentCenter;
        _endLable.text = @"0:00";
    }
    return _endLable;
}

- (UISlider *)slider
{
    if(!_slider)
    {
        _slider = [[UISlider alloc]init];
        [_slider addTarget:self action:@selector(slider:) forControlEvents:UIControlEventValueChanged];
        _slider.continuous = YES;
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.minimumTrackTintColor = [UIColor clearColor];
    }
    return _slider;
}

- (UIProgressView *)progressView
{
    if(!_progressView)
    {
        _progressView = [[UIProgressView alloc]init];
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
    }
    return _progressView;
}

#pragma mark - private

- (void)setUI
{
    NSInteger LINESPACE = 10;
    NSInteger LINECOUNT = 4;
    NSInteger HSPACE = 10;
    
    self.xuanJiView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetWidth(self.view.frame)/16*9, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) -CGRectGetWidth(self.view.frame)/16*9)];
    [self.view addSubview:self.xuanJiView];
    
    for(NSInteger i = 0 ; i< self.dataArray.count ; i++)
    {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(LINESPACE +(LINESPACE + (CGRectGetWidth(self.view.frame) - LINESPACE * (LINECOUNT +1))/LINECOUNT) * (i%LINECOUNT),20 + i/LINECOUNT*(HSPACE + (CGRectGetWidth(self.view.frame) - LINESPACE * (LINECOUNT +1))/LINECOUNT * 0.618), (CGRectGetWidth(self.view.frame) - LINESPACE * (LINECOUNT +1))/LINECOUNT, (CGRectGetWidth(self.view.frame) - LINESPACE * (LINECOUNT +1))/LINECOUNT * 0.618)];
        [btn setTitle:[NSString stringWithFormat:@"第%ld集",i+1] forState:UIControlStateNormal];
        
        if(i == 0)
        {
            [btn setBackgroundColor:[UIColor blueColor]];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else
        {
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.layer.cornerRadius = 4;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.tag = i;
        [btn addTarget:self action:@selector(dianBoClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.xuanJiView addSubview: btn];
        [self.btnArray addObject:btn];
    }
}

- (void)setFrame
{
    self.playerLayer.frame=self.contentView.frame;
    
    self.toolView.frame = CGRectMake(0, CGRectGetHeight(self.contentView.frame)-TOOLVIEWHEIGTH, CGRectGetWidth(self.contentView.frame), TOOLVIEWHEIGTH);
    self.fullScreenBtn.frame = CGRectMake(CGRectGetWidth(self.toolView.frame)-50, 20, 40, 40);
    self.endLable.frame = CGRectMake(CGRectGetWidth(self.toolView.frame) - 50, 0, 50, TOOLVIEWHEIGTH);
    self.slider.frame = CGRectMake(80, (TOOLVIEWHEIGTH - 20)/2, CGRectGetWidth(self.contentView.frame) - 130, 20);
    self.progressView.frame = CGRectMake(80, (TOOLVIEWHEIGTH - 20)/2+10, CGRectGetWidth(self.contentView.frame) - 130, 20);
}

-(AVPlayerItem *)getPlayItem:(NSString *)str{
   
    NSString *urlStr=[NSString stringWithFormat:@"%@",str];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
    
    return playerItem;
}

- (void)slider:(UISlider *)slider
{
    
    float total = CMTimeGetSeconds([[self.player.currentItem asset] duration]);
    if(total <= 0)
    {
        return;
    }
    [self.player pause];
    
    NSLog(@"===================== %f ---- %f ",total*slider.value , slider.value);
    
    CMTime time = CMTimeMakeWithSeconds(total*slider.value, self.player.currentItem.duration.timescale);
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        
        if(finished)
            [self.player play];
    }];
}

- (void)refreshCurrentTime
{
    [self.player play];
    AVPlayerItem *playerItem=self.player.currentItem;
    
    __weak __typeof(&*self)weakSelf = self;
    
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        
        
        float total=CMTimeGetSeconds([playerItem duration]);
        if (current)
        {
            weakSelf.startLable.text = [NSString stringWithFormat:@"%@",[weakSelf convertTime:current]];
            
            NSLog(@"current is %f -- %f --- %f",current,current/total,total);
            
            [weakSelf.slider setValue:current/total animated:NO];
        }
    }];
}

-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem
{
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            
            self.startLable.text = @"00:00";
            float total = CMTimeGetSeconds([[playerItem asset] duration]);
            self.endLable.text = [NSString stringWithFormat:@"%@",[self convertTime:total]];
            [self.slider setValue:0 animated:NO];
            [self.progressView setProgress:0 animated:NO];
            
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        
        float total = CMTimeGetSeconds([[playerItem asset] duration]);
        [self.progressView setProgress:totalBuffer/total animated:NO];
    }
}

- (void)paseAndPlayBtnClick
{
    if(self.player.rate == 0)
    {
        [self.paseAndPlayBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [self.player play];
    }else
    {
        [self.paseAndPlayBtn setTitle:@"播放" forState:UIControlStateNormal];
        [self.player pause];
    }
}

- (void)fullScreenBtnClick
{
    if(isHalfScreen)
    {
        [[UIDevice currentDevice]setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft]  forKey:@"orientation"];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        [UIView animateWithDuration:0.0 animations:^{
            self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200);
            [self setFrame];
        } completion:^(BOOL finished) {
        }];
        [_fullScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
        self.xuanJiView.hidden = NO;
        
    }else
    {
        [[UIDevice currentDevice]setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait]  forKey:@"orientation"];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        [UIView animateWithDuration:0.0 animations:^{
            self.contentView.frame = self.view.bounds;
            [self setFrame];
        } completion:^(BOOL finished) {
        }];
        [_fullScreenBtn setTitle:@"半屏" forState:UIControlStateNormal];
        self.xuanJiView.hidden = YES;
    }
    
    isHalfScreen = !isHalfScreen;
}

- (void)dianBoClick:(UIButton *)sender
{
    [self.player pause];
    
    for(NSInteger i = 0 ; i < self.btnArray.count ; i++)
    {
        UIButton * btn = self.btnArray[i];
        if(i == sender.tag)
        {
            [btn setBackgroundColor:[UIColor blueColor]];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else
        {
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.player removeTimeObserver:self.timeObserver];
        [self removeObserverFromPlayerItem:self.player.currentItem];
        AVPlayerItem *playerItem=[self getPlayItem:self.dataArray[sender.tag]];
        [self addObserverToPlayerItem:playerItem];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        [self refreshCurrentTime];
    });
}

#pragma mark - touchEvent

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.contentView];
    
    if([touches anyObject].view == self.toolView)
    {
        return;
    }
    
    y = point.y;
    
    if(CGRectContainsPoint(self.contentView.frame, point))
    {
        if(!isHiddenToolView)
        {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.toolView.alpha = 0;
                self.fullScreenBtn.alpha = 0;
            } completion:^(BOOL finished) {
                
            }];
        }else
        {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.toolView.alpha = 1;
                self.fullScreenBtn.alpha = 1;
            } completion:^(BOOL finished) {
                
            }];
        }
        
        isHiddenToolView = !isHiddenToolView;
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft)
    {
    
        
        CGPoint point = [[touches anyObject] locationInView:self.contentView];
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame));
        if(fabs(point.y - y) <= 10)
            return;
        
        if(CGRectContainsPoint(frame, point))
        {
            float brightness = [UIScreen mainScreen].brightness;
            float value ;

           if(point.y - y > 0)
           {
               value = brightness - (point.y - y)*brightness/200;
                if(value < 0 )
                {
                    value = 0;
                }
           }else
           {
               value = brightness + (y - point.y)* (1 - brightness)/200;
               if(value > 1)
               {
                   value = 1;
               }
           }
            [[UIScreen mainScreen] setBrightness:value];
        }else
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
           float volume = [MPMusicPlayerController applicationMusicPlayer].volume;
#pragma clang diagnostic pop
            float value;
    
            if(point.y - y > 0)
            {
                value = volume - (point.y - y)*volume/200;
                if(value < 0 )
                {
                    value = 0;
                }
            }else
            {
                value = volume + (y - point.y)* (1 - volume)/200;
                if(value > 1)
                {
                    value = 1;
                }
            }
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:value];
#pragma clang diagnostic pop
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

@end
