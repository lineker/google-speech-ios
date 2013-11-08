//
//  ViewController.m
//  SpeechPOC
//
//  Created by Lineker Tomazeli on 11/8/2013.
//  Copyright (c) 2013 Lineker Tomazeli. All rights reserved.
//

#import "ViewController.h"

#import "EBRecognizerFactory.h"
#import "EBVocalizerFactory.h"

@interface ViewController ()
@property (strong,nonatomic) id <EBVocalizer> _vocalizer;
@property (strong,nonatomic) id <EBRecognizer> _recognizer;
@end

@implementation ViewController
@synthesize _recognizer=recognizer, _vocalizer=vocalizer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startRecord:(id)sender {
    recognizer = [EBRecognizerFactory initRecognizerWithService:EBGoogleRecognizerService type:nil detection:EBShortEndOfSpeechDetection language:@"en-US" delegate:self];
}

#pragma EBRecognizerDelegate
- (void)ebrecognizerDidBeginRecording:(id<EBRecognizer>)recognizer {
    
}
- (void)ebrecognizerDidFinishRecording:(id<EBRecognizer>)recognizer {
    
}
- (void)ebrecognizer:(id<EBRecognizer>)recognizer didFinishWithResults:(EBRecognition *)results{
    NSLog(@"%@",results.results);
}
- (void)ebrecognizer:(id<EBRecognizer>)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion {
    NSLog(@"something went wrong");
}

#pragma EBVocalizerDelegate
- (void)ebvocalizer:(id<EBVocalizer>)vocalizer willBeginSpeakingString:(NSString *)text {
    
}
- (void)ebvocalizer:(id<EBVocalizer>)vocalizer didFinishSpeakingString:(NSString *)text withError:(NSError *)error {
    
}

@end
