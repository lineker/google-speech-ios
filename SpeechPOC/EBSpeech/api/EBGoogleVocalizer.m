//
//  EBGoogleVocalizer.m
//  EBSpeech
//
//  Created by Lineker_ on 2013-07-16.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import "EBGoogleVocalizer.h"
#import "EBAudioHandler.h"
#import "EBUtilities.h"

@interface EBGoogleVocalizer()
@property (strong, nonatomic) id <EBVocalizerDelegate> delegate;
@property (strong) EBAudioHandler *audioHandler;
@end

@implementation EBGoogleVocalizer
@synthesize delegate = _delegate;

/*!
 @abstract Returns a SKVocalizer initialized with a language.
 
 @param language The language tag in the format of the ISO 639 language code,
 followed by an underscore "_", followed by the ISO 3166-1 country code.  This
 language should correspond to the language of the text provided to the
 speakString: method.
 See http://dragonmobile.nuancemobiledeveloper.com/public/index.php?task=faq
 for a list of supported languages and voices.
 @param delegate The delegate receiver for status messages sent by the
 vocalizer.
 
 @discussion This initializer configures a vocalizer object for use as a
 text to speech service.  A default voice will be chosen by the server based on
 the language selection.  After initializing, the speak methods can be called
 repeatedly to enqueue sequences of spoken text.  Each spoken string will
 result in one or more delegate methods called to inform the receiver of
 speech progress.  At any point speech can be stopped with the cancel method.
 */
- (id)initWithLanguage:(NSString *)language delegate:(id <EBVocalizerDelegate>)delegate
{
    self = [super init];
    if (self){
        self.delegate = delegate;
        self.audioHandler = [EBAudioHandler sharedInstance];
    }
    return self;
}

/*!
 @abstract Returns a EBVocalizer initialized with a specific voice.
 
 @param voice The specific voice to use for speech.  The list of supported
 voices sorted by language can be found at
 http://dragonmobile.nuancemobiledeveloper.com/public/index.php?task=faq .
 @param delegate The delegate receiver for status messages sent by the
 vocalizer.
 
 @discussion This initializer provides more fine grained control than the
 initWithLanguage: method by allowing for the selection of a particular voice.
 For example, this allows for explicit choice between male and female voices in
 some languages.  The SKVocalizer object returned may be used exactly as
 initialized in the initWithLanguage: case.
 */
- (id)initWithVoice:(NSString *)voice delegate:(id <EBVocalizerDelegate>)delegate
{
    self = [super init];
    if (self){
        self.delegate = delegate;
        self.audioHandler = [EBAudioHandler sharedInstance];
    }
    return self;
}

/*!
 @abstract Speaks the provided string.
 
 @param text The string to be spoken.
 
 @discussion This method will send a request to the text to speech server and
 return immediately.  The text will be spoken as the server begins to stream
 audio and delegate methods will be synchronized to the audio to indicate
 speech progress.
 */
- (void)speakString:(NSString *)text {
    // Google Translate API cannot handle strings > 100 characters
    if (text.length > 100) {
        text = [text substringWithRange:NSMakeRange(0, 99)];
    }
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(concurrentQueue, ^{
         NSLog(@"Start downloading text2voice file");
        if([self downloadMp3VoiceForString:text]) {
            NSLog(@"done downloading text2voice file");
            [self.delegate ebvocalizer:self willBeginSpeakingString:text];

            [self.audioHandler playFilename:@"audio.mp3" fromResource:NO];
            //delete file?

            [self.delegate ebvocalizer:self didFinishSpeakingString:text withError:nil];
        }else {
            // TODO: add NSError
            [self.delegate ebvocalizer:self didFinishSpeakingString:text withError:nil];
        }
    });
    
}

- (BOOL) downloadMp3VoiceForString:(NSString *)text
{
    // TODO: put this in a configuration file, and fix language selection
    NSString *address = @"http://translate.google.com/translate_tts?tl=en&q=";
    address = [address stringByAppendingString:[EBUtilities escapeString:text]];
    NSLog(@"String escaped : %@", address);
    
    NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: address]];
    
    //[postRequest setValue:@"audio/x-flac; rate=16000" forHTTPHeaderField:@"Content-Type"];
    [getRequest setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7" forHTTPHeaderField:@"User-Agent"];
    
    // Designate the request a GET request
    [getRequest setHTTPMethod:@"GET"];
    //
    NSError *returnError = nil;
    NSHTTPURLResponse *returnResponse = nil;
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:getRequest returningResponse:&returnResponse error:&returnError];
    
    if([returnData length] > 0) {
        NSLog(@"req OK");
        NSError *error = nil;
        
        NSString *path= [[EBUtilities getURLforFilename:@"audio" extension:@"mp3"] path];
        [returnData writeToFile:path options:NSDataWritingAtomic error:&error];
        NSLog(@"Write returned error: %@", [error localizedDescription]);
        return YES;
    }
    else  {
        // TODO: Handle exception
        NSLog(@"Req NOT ok : %d",returnResponse.statusCode);
        return NO;
    }
    
}

/*!
 @abstract Speaks the SSML string.
 
 @param markup The SSML string to be spoken.
 
 @discussion This method will perform exactly as the speakString: method with
 the exception that the markup within the markup string will be processed by
 the server according to SSML standards.  This allows for more fine grained
 control over the speech.
 */
- (void)speakMarkupString:(NSString *)markup {
    
}

/*!
 @abstract Cancels all speech requests.
 
 @discussion This method will stop the current speech and cancel all pending
 speech requests.  If any speech is playing, it will be stopped.
 */
- (void)cancel {
   // TODO: implement cancel
}

@end
