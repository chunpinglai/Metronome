//
//  ViewController.m
//  Metronome_obj
//
//  Created by AbbyLai on 2016/10/27.
//  Copyright © 2016年 AbbyLai. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayButton.h"
#import "MuteButton.h"
#import "MetronomeConstant.h"
#import "SwingAnimation.h"

@interface ViewController ()<UIPickerViewDelegate, UIPickerViewDataSource> {
    AVAudioPlayer *audioPlayer;
    NSTimer *playSoundTimer;
    UIView *ALPickerView;
    UIPickerView *ALPicker;
    NSArray *arrayTempo; //4/4
    NSArray *arrayNote; //八分音符
    NSArray *arraySpeed; //60
    NSArray *arraySpeedType; //Larghetto
    NSArray *arraySpeedTypeInterval; //60-65
    float userTimeInterval;
    float previousPendulumY;
}
@property (weak, nonatomic) IBOutlet MuteButton *btnMute;
@property (weak, nonatomic) IBOutlet PlayButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnTempo;
@property (weak, nonatomic) IBOutlet UIButton *btnSpeed;
@property (weak, nonatomic) IBOutlet UIButton *btnSpeedType;
@property (weak, nonatomic) IBOutlet UIButton *btnNote;
@property (weak, nonatomic) IBOutlet UIButton *btnPendulum;
@property (weak, nonatomic) IBOutlet UIButton *btnUp;
@property (weak, nonatomic) IBOutlet UIButton *btnDown;
@property (weak, nonatomic) IBOutlet UIImageView *imgPendulum;
@property (weak, nonatomic) IBOutlet UIView *metronomeControlView;
@property (weak, nonatomic) IBOutlet UIView *metronomeView;
@property (weak, nonatomic) IBOutlet UIView *pendulumView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initALPickerView];
    [self setUpButtonFirstValue];
    
    //pandulum gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragPendulum:)];
    [_btnPendulum addGestureRecognizer:panGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if (playSoundTimer) {
        [playSoundTimer invalidate];
    }
    if (audioPlayer) {
        audioPlayer = nil;
    }
}

//MARK:- Btn action

- (IBAction)playBtnAction:(PlayButton *)sender {
    if (_btnPlay.playStatus == PlayBtnStatus_Play) {
        [playSoundTimer invalidate];
        [self stopSwing];
    }
    else {
        [self startCount];
        float realTimeInterval = 2*[self getRealTimeInterval];
        [self startSwing:realTimeInterval];
    }
    [_btnPlay changeUI];
}

- (IBAction)showSpeedPicker:(id)sender {
    ALPicker.tag = 0;
    [ALPicker reloadAllComponents];
    int row = (int)userTimeInterval - 1;
    [ALPicker selectRow:row inComponent:0 animated:YES];
    [self.view addSubview:ALPickerView];
}

- (IBAction)muteBtnAction:(id)sender {
    [_btnMute changeUI];
}

- (IBAction)noteBtnAction:(id)sender {
    ALPicker.tag = 1;
    [ALPicker reloadAllComponents];
    [self.view addSubview:ALPickerView];
}

- (IBAction)tempoBtnAction:(id)sender {
    ALPicker.tag = 2;
    [ALPicker reloadAllComponents];
    [self.view addSubview:ALPickerView];
}

- (IBAction)downBtnAction:(id)sender {
    if (userTimeInterval <= speed_min) {
        return;
    }
    
    int speedResult = (int)userTimeInterval - 1;
    [self changeSpeed:speedResult];
    [self setSpeedTypeWithSpeed:speedResult];
}

- (IBAction)upBtnAction:(id)sender {
    if (userTimeInterval >= speed_max) {
        return;
    }
    
    int speedResult = (int)userTimeInterval + 1;
    [self changeSpeed:speedResult];
    [self setSpeedTypeWithSpeed:speedResult];
}

- (IBAction)speedTypeBtnAction:(id)sender {
    ALPicker.tag = 3;
    [ALPicker reloadAllComponents];
    int row = [self getCurrentSpeedTypeRow:_btnSpeedType.titleLabel.text];
    [ALPicker selectRow:row inComponent:0 animated:YES];
    [self.view addSubview:ALPickerView];
}

//MARK:- init

- (void)initUI {
    userTimeInterval = 60.0;
    previousPendulumY = 60.0;
    arraySpeed = [self getTempoArray];
    arrayTempo = @[@"1/4",@"2/4",@"3/4",@"4/4",@"3/8",@"6/8",@"9/8",@"12/8"];
    arrayNote = @[@"♩",@"♬",@"3"];
    arraySpeedType = @[@"Largo",@"Larghetto",@"Adagio",@"Andante",@"Moderato",@"Allegro",@"Presto ",@"Prestissimo"];
    arraySpeedTypeInterval = @[@"40-59",@"60-65",@"66-75",@"76-108",@"108-119",@"120-167",@"168-199",@"200-208"];
    _btnPlay.layer.cornerRadius = 10;
    _btnMute.layer.cornerRadius = 17.5;
    _btnSpeedType.layer.cornerRadius = 5;
    _btnSpeed.layer.cornerRadius = 5;
    _btnDown.layer.cornerRadius = 5;
    _btnUp.layer.cornerRadius = 5;
    _metronomeControlView.layer.cornerRadius = 10;
}

- (void)setUpButtonFirstValue {
    //init speed btn UI
    [self setBtnSpeedTitileWithTime:userTimeInterval];
    
    //init note btn UI
    NSString *note = [arrayNote firstObject];
    [_btnNote setTitle:note forState:UIControlStateNormal];
    [_btnNote setTitle:note forState:UIControlStateHighlighted];
    
    //init tempo btn UI
    NSString *tempo = [arrayTempo firstObject];
    [_btnTempo setTitle:tempo forState:UIControlStateNormal];
    [_btnTempo setTitle:tempo forState:UIControlStateHighlighted];
    
    //init speedType btn UI
    [self setSpeedTypeWithSpeed:userTimeInterval];
}

- (NSArray *)getTempoArray {
    NSMutableArray *tempo = [[NSMutableArray alloc]init];
    for (int i=1; i<281; i++) {
        [tempo addObject:[NSString stringWithFormat:@"%d",i]];
    }
    return [[NSArray alloc]initWithArray:tempo];
}

- (void)initALPickerView {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    ALPickerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    ALPickerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.09939];
    
    //gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideTempoPicker)];
    [ALPickerView addGestureRecognizer:tap];
    
    //picker view
    ALPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ALPickerView.frame.size.height - 216, screenSize.width, 216)];
    ALPicker.showsSelectionIndicator = true;
    ALPicker.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    ALPicker.dataSource = self;
    ALPicker.delegate = self;
    [ALPickerView addSubview:ALPicker];
}

//MARK:-

- (NSString *)getCurrentSpeedTypeValueString:(NSString *)currentSpeedType {
    int selectedIndex = [self getCurrentSpeedTypeRow:currentSpeedType];
    NSString *speedTypeInterval = @"";
    if (selectedIndex < arraySpeedTypeInterval.count) {
        speedTypeInterval = [arraySpeedTypeInterval objectAtIndex:selectedIndex];
    }
    else {
        speedTypeInterval = [arraySpeedTypeInterval lastObject];
    }
    NSArray *result = [speedTypeInterval componentsSeparatedByString:@"-"];
    return [result objectAtIndex:0];
}

- (int)getCurrentSpeedTypeRow:(NSString *)currentSpeedType {
    int selectedIndex = 0;
    for (int x=0; x<arraySpeedType.count; x++) {
        NSString *speedTypeTitle = [arraySpeedType objectAtIndex:x];
        if ([currentSpeedType isEqualToString:speedTypeTitle]) {
            selectedIndex = x;
        }
    }
    return selectedIndex;
}

- (void)setSpeedTypeWithSpeed:(int)speed {
    NSString *previousSpeedTypeValue = @"0";
    int selectedIndex = 0;
    
    //>final?
    NSArray *result = [[arraySpeedTypeInterval lastObject] componentsSeparatedByString:@"-"];
    NSString *speedTypeIntervalValue = [result objectAtIndex:0];
    if (speed > (int)[speedTypeIntervalValue integerValue]) {
        selectedIndex = (int)arraySpeedTypeInterval.count - 1;
    }
    else {
        for (int i=0; i<arraySpeedTypeInterval.count; i++) {
            NSString *speedTypeInterval = [arraySpeedTypeInterval objectAtIndex:i];
            NSArray *result = [speedTypeInterval componentsSeparatedByString:@"-"];
            NSString *speedTypeIntervalValue = [result objectAtIndex:0];
            
            if ((speed < (int)[speedTypeIntervalValue integerValue])&&(speed >= (int)[previousSpeedTypeValue integerValue])) {
                selectedIndex = i-1;
                break;
            }
            previousSpeedTypeValue = speedTypeIntervalValue;
        }
    }
    
    if (selectedIndex < arraySpeedType.count) {
        NSString *currentSpeedType = [arraySpeedType objectAtIndex:selectedIndex];
        [_btnSpeedType setTitle:currentSpeedType forState:UIControlStateNormal];
        [_btnSpeedType setTitle:currentSpeedType forState:UIControlStateHighlighted];
    }
}

- (void)changeSpeed:(int)speed {
    userTimeInterval = speed;
    [self setBtnSpeedTitileWithTime:userTimeInterval];
    
    if (_btnPlay.playStatus == PlayBtnStatus_Play) {
        //animation
        [self stopSwing];
        float realTimeInterval = 2*[self getRealTimeInterval];
        [self startSwing:realTimeInterval];
    }
    
    if (userTimeInterval >= 40) {
        [_btnPendulum setCenter:CGPointMake(_btnPendulum.center.x, userTimeInterval)];
    }
}

- (float)getRealTimeInterval {
    float realTimeInterval = 60.0 / userTimeInterval;
    return realTimeInterval;
}

- (void)hideTempoPicker {
    [ALPickerView removeFromSuperview];
}

//MARK:- Pendulum Animation
- (void)dragPendulum:(UIPanGestureRecognizer *)sender {
    if (_btnPlay.playStatus == PlayBtnStatus_Stop) {
        float currentY = [sender locationInView:_metronomeView].y;
        if (currentY < 60 ) {
            userTimeInterval = 60.0;
            [self setBtnSpeedTitileWithTime:userTimeInterval];
            [_btnPendulum setCenter:CGPointMake(_btnPendulum.center.x, 60.0)];
            return;
        }
        
        if (currentY > 280) {
            userTimeInterval = 280.0;
            [self setBtnSpeedTitileWithTime:userTimeInterval];
            [_btnPendulum setCenter:CGPointMake(_btnPendulum.center.x, 280.0)];
            return;
        }
//        NSLog(@"currentY:%f, userTimeInterval:%f", currentY, userTimeInterval);
        [_btnPendulum setCenter:CGPointMake(_btnPendulum.center.x, currentY)];
        int add = trunc(currentY - previousPendulumY);
        
//        [self changeSpeed:(add + userTimeInterval)];
        //change speed
        userTimeInterval = add + userTimeInterval;
        [self setBtnSpeedTitileWithTime:userTimeInterval];
        [self setSpeedTypeWithSpeed:userTimeInterval];
        
        if (_btnPlay.playStatus == PlayBtnStatus_Play) {
            //animation
            [self stopSwing];
            float realTimeInterval = 2*[self getRealTimeInterval];
            [self startSwing:realTimeInterval];
        }
        
        previousPendulumY = currentY;
    }
}

- (void)setBtnSpeedTitileWithTime:(float)time {
    [_btnSpeed setTitle:[NSString stringWithFormat:@"%.0f",time]  forState:UIControlStateNormal];
    [_btnSpeed setTitle:[NSString stringWithFormat:@"%.0f",time]  forState:UIControlStateHighlighted];
}

- (void)startSwing:(float)time {
    [SwingAnimation startSwing:time view:_pendulumView];
}

- (void)stopSwing {
    [SwingAnimation stopSwingWithView:_pendulumView];
}

//MARK:- PlaySound
- (void)playSound:(NSURL *)soundUrl {
    audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:soundUrl error:nil];
    BOOL isPrepared = audioPlayer.prepareToPlay;
    if (isPrepared) {
        if (_btnMute.status == MuteBtnStatus_PlaySound) {
           BOOL play = [audioPlayer play];
            if (!play) {
                NSLog(@"ERROR:play error");
            }
        }
    }
    else {
        NSLog(@"ERROR:can't prepareToPlay");
    }
    
}

- (void)startCount {
    float realTimeInterval = [self getRealTimeInterval];
    playSoundTimer = [NSTimer scheduledTimerWithTimeInterval:realTimeInterval target:self selector:@selector(prepareToPlaySound:) userInfo:nil repeats:true];
}

- (void)prepareToPlaySound:(NSTimer *)timer {
    NSString *soundFileName = @"click1";
    NSString *soundFilePath = [[NSBundle mainBundle]pathForResource:soundFileName ofType:@"mp3"];
    NSURL *soundUrl = [NSURL fileURLWithPath:soundFilePath];
    [self playSound:soundUrl];
    
    float realTimeInterval = [self getRealTimeInterval];
    NSDate *fire = [NSDate dateWithTimeIntervalSinceNow:realTimeInterval];
    [playSoundTimer setFireDate:fire];
}

//MARK:- UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case 0:
        {
            return arraySpeed.count;
        }
            break;
        case 1:
        {
            return arrayNote.count;
        }
            break;
        case 2:
        default:
        {
            return arrayTempo.count;
        }
            break;
        case 3:
        {
            return arraySpeedType.count;
        }
            break;
    }
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case 0:
        {
            return arraySpeed[row];
        }
            break;
        case 1:
        {
            return arrayNote[row];
        }
            break;
        case 2:
        default:
        {
            return arrayTempo[row];
        }
            break;
        case 3:
        {
            return arraySpeedType[row];
        }
            break;
    }
}

//MARK: UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case 0:
        {
            NSString *selectedSpeed = arraySpeed[row];
            int speed = (int)[selectedSpeed integerValue];
            [self changeSpeed:speed];
            [self setSpeedTypeWithSpeed:speed];
        }
            break;
        case 1:
        {
            [_btnNote setTitle:arrayNote[row]  forState:UIControlStateNormal];
            [_btnNote setTitle:arrayNote[row]  forState:UIControlStateHighlighted];
        }
            break;
        case 2:
        default:
        {
            [_btnTempo setTitle:arrayTempo[row]  forState:UIControlStateNormal];
            [_btnTempo setTitle:arrayTempo[row]  forState:UIControlStateHighlighted];
        }
            break;
        case 3:
        {
            [_btnSpeedType setTitle:arraySpeedType[row]  forState:UIControlStateNormal];
            [_btnSpeedType setTitle:arraySpeedType[row]  forState:UIControlStateHighlighted];
            NSString *currentSpeedTypeValue = [self getCurrentSpeedTypeValueString:arraySpeedType[row]];
            [self changeSpeed:(int)[currentSpeedTypeValue integerValue]];
        }
            break;
    }
}

@end
