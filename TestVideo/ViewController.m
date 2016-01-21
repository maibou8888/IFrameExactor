//
//  ViewController.m
//  TestVideo
//
//  Created by Admin on 12/21/14.
//  Copyright (c) 2014 Sutan. All rights reserved.
//

#import "ViewController.h"
#import "VideoFrameExtractor.h"
#import "Utilities.h"

@interface ViewController ()
{
    float lastFrameTime;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) VideoFrameExtractor *video;

-(IBAction)playButtonAction:(id)sender;
- (IBAction)showTime:(id)sender;

@end

@implementation ViewController
@synthesize imageView, label, playButton, video;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.video = [[VideoFrameExtractor alloc] initWithVideo:[Utilities bundlePath:@"sophie.mov"]];
    
    // set output image size
    video.outputWidth = 426;
    video.outputHeight = 320;
    
    // print some info about the video
    NSLog(@"video duration: %f",video.duration);
    NSLog(@"video size: %d x %d", video.sourceWidth, video.sourceHeight);
    
    // video images are landscape, so rotate image view 90 degrees
    [imageView setTransform:CGAffineTransformMakeRotation(M_PI/2)];
}

-(IBAction)playButtonAction:(id)sender {
    [playButton setEnabled:NO];
    lastFrameTime = -1;
    
    // seek to 0.0 seconds
    [video seekTime:0.0];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                     target:self
                                   selector:@selector(displayNextFrame:)
                                   userInfo:nil
                                    repeats:YES];
}

- (IBAction)showTime:(id)sender {
    NSLog(@"current time: %f s",video.currentTime);
}

#define LERP(A,B,C) ((A)*(1.0-C)+(B)*C)

-(void)displayNextFrame:(NSTimer *)timer {
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    if (![video stepFrame]) {
        [timer invalidate];
        [playButton setEnabled:YES];
        return;
    }
    imageView.image = video.currentImage;
    float frameTime = 1.0/([NSDate timeIntervalSinceReferenceDate]-startTime);
    if (lastFrameTime<0) {
        lastFrameTime = frameTime;
    } else {
        lastFrameTime = LERP(frameTime, lastFrameTime, 0.8);
    }
    [label setText:[NSString stringWithFormat:@"%.0f",lastFrameTime]];
}


@end
