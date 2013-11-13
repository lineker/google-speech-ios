//
//  EBGoogleRecognizer.m
//  EBSpeech
//
//  Created by Lineker_ on 2013-07-16.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import "EBGoogleRecognizer.h"
#import "EBAudioHandler.h"
#import "EBUtilities.h"

@interface EBGoogleRecognizer()

@property (strong, nonatomic) id <EBRecognizerDelegate> delegate;
@property (strong, nonatomic) EBAudioHandler *audioHandler;
//@property (strong, nonatomic) EBAudioHandler *audioHandler2;
@end

@implementation EBGoogleRecognizer
@synthesize delegate = _delegate, audioLevel = _audioLevel;

- (id)initWithType:(NSString *)type detection:(EBEndOfSpeechDetection)detection language:(NSString *)language delegate:(id <EBRecognizerDelegate>)delegate
{
    self = [super init];
    if (self){
        self.delegate = delegate;
        //self.audioHandler2 = [[EBAudioHandler alloc] init];
        //self.audioHandler2.delegate = self;
        
        self.audioHandler = [[EBAudioHandler alloc] init]; //[EBAudioHandler sharedInstance];
        self.audioHandler.delegate = self;
         // TODO: bip earcon //jbl_begin.caf
        [self.audioHandler playFilename:@"jbl_begin.caf" fromResource:YES];
        [self.audioHandler startRecord];
    }
    return self;
}

/*!
 @abstract Stops recording and streaming audio to the speech server.
 
 @discussion This method is used to stop recording audio and continue with the
 recognition process.  Thi
 s method must be used when the end of speech detection
 is disabled and may be used with a end-of-speech detection model in order to
 allow a user to manually end a recording before the end-of-speech detctor has
 activated.
 */
- (void)stopRecording
{
    //[self.audioHandler stopRecord];
    // TODO: bip earcon //jbl_confirm.caf
    //[self.audioHandler playFilename:@"jbl_confirm.caf" fromResource:YES];
    [self processRequest];
}

- (void)playRecording {
    [self.audioHandler playFilename:@"recordedFile.wav" fromResource:NO];
}

/*!
 @abstract Cancels the recognition request.
 
 @discussion This method will terminate the recognition request, stopping any
 ongoing recording and terminating the recognition process.  This will result
 in the delegate receiving an error message via the
 recognizer:didFinishWithError:suggestion method unless a recognition result
 has been or is already being sent to the delegate.
 */
- (void)cancel {
      // TODO: bip earcon  //
    [self.audioHandler playFilename:@"jbl_cancel.caf" fromResource:YES];
    [self processRequest];
}

- (void)recognizer:(id<EBRecognizer>)recognizer didFinishWithSilence:(BOOL)results
{
    [self processRequest];
}

- (void)processRequest
{
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(concurrentQueue, ^{
        [self.audioHandler stopRecord];
        [self.audioHandler playFilename:@"jbl_confirm.caf" fromResource:YES];

        NSData *result = [self getVoiceToText];
        
        if(result) {
            
            //convert json to dictionary
            NSDictionary *dicResult = [EBUtilities parseJson:result];
            
            NSLog(@"GOOGLE Result : %@", dicResult[@"hypotheses"]);
            
            EBRecognition *regResult = [[EBRecognition alloc] init];
            NSArray *hypotheses = dicResult[@"hypotheses"];
            for (NSDictionary *possibleAnswer in hypotheses) {
                NSString *confidence = possibleAnswer[@"confidence"];
                if(confidence) {
                    [regResult.scores addObject: confidence];
                }
                NSString *utterance = possibleAnswer[@"utterance"];
                if(utterance) {
                    [regResult.results addObject:utterance];
                }
            }
            // TODO: populate and parse results better
            regResult.data = [[NSString alloc] initWithData:result
                                                   encoding:NSUTF8StringEncoding];;
            [self.delegate ebrecognizer:self didFinishWithResults:regResult];
        } else {
            // TODO: need to finish implementing
            [self.delegate ebrecognizer:self didFinishWithError:nil suggestion:@"error when converting flac"];
        }
    });    
}

- (NSData *) getVoiceToText
{
    
    if([self.audioHandler convertToFlac])
    {
        NSLog(@"start getting voice2text");
       
        // TODO: put this in a configuration file
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&pfilter=0&maxresults=3&lang=en-US"]];
        
        // Set the request's content type to application/x-www-form-urlencoded
        [postRequest setValue:@"audio/x-flac; rate=16000" forHTTPHeaderField:@"Content-Type"];
        [postRequest setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7" forHTTPHeaderField:@"User-Agent"];
        
        // Designate the request a POST request and specify its body data
        [postRequest setHTTPMethod:@"POST"];
        
        NSString *filePathWithExtension = [[EBUtilities getURLforFilename:@"flacfile" extension:@"flac"] path];
        NSLog(@"will read file : %@", filePathWithExtension);
        //NSInputStream *audio = [NSInputStream inputStreamWithFileAtPath:filePathWithExtension];
        
        //if(audio == nil) NSLog(@"problem read file 1");
        
        NSData *myData = [NSData dataWithContentsOfFile:filePathWithExtension];
        
        if ([myData length] > 0) NSLog(@"bytes are available");
        else NSLog(@"problem reading file");
        
        //[postRequest setHTTPBodyStream:audio];
        [postRequest setHTTPBody:myData];
        
        NSError *returnError = nil;
        NSHTTPURLResponse *returnResponse = nil;
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
         NSLog(@"ended getting voice2text");
        if([returnData length] > 0) NSLog(@"req OK");
        else NSLog(@"Req NOT ok");
        
        return returnData;
    } else {
        return nil;
    }
}



@end
