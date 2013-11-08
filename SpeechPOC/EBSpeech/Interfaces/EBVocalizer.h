//
//  EBVocalizer.h
//  EBSpeech
//
//  Created by Lineker_IBM on 2013-07-15.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EBVocalizerDelegate;

@protocol EBVocalizer <NSObject>

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
- (id)initWithLanguage:(NSString *)language delegate:(id <EBVocalizerDelegate>)delegate;

/*!
 @abstract Returns a SKVocalizer initialized with a specific voice.
 
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
- (id)initWithVoice:(NSString *)voice delegate:(id <EBVocalizerDelegate>)delegate;

/*!
 @abstract Speaks the provided string.
 
 @param text The string to be spoken.
 
 @discussion This method will send a request to the text to speech server and
 return immediately.  The text will be spoken as the server begins to stream
 audio and delegate methods will be synchronized to the audio to indicate
 speech progress.
 */
- (void)speakString:(NSString *)text;

/*!
 @abstract Speaks the SSML string.
 
 @param markup The SSML string to be spoken.
 
 @discussion This method will perform exactly as the speakString: method with
 the exception that the markup within the markup string will be processed by
 the server according to SSML standards.  This allows for more fine grained
 control over the speech.
 */
- (void)speakMarkupString:(NSString *)markup;

/*!
 @abstract Cancels all speech requests.
 
 @discussion This method will stop the current speech and cancel all pending
 speech requests.  If any speech is playing, it will be stopped.
 */
- (void)cancel;

@end


/*!
 @discussion The SKVocalizerDelegate protocol defines the methods sent by the
 SKVocalizer class during the speech synthesis process.  These methods provide
 progress information regarding the speech process and are all optional.
 Since the vocalizer will automatically queue sequential speech reuqests, it is
 not even necessary to know when a speech request has finished.
 */
@protocol EBVocalizerDelegate <NSObject>

/*!
 @abstract Sent when the vocalizer starts speaking each string.
 
 @param vocalizer The vocalizer sending the message.
 @param text The text sent to the speakString: or speakMarkupString: methods.
 
 @discussion This message is sent to the delegate at most one time for each
 speech request.  In the case that there is valid speech to play, this method
 will be called when the audio begins playing.  If there is no valid audio for
 the string, or there is an error, this method will not be called.
 */
- (void)ebvocalizer:(id<EBVocalizer>)vocalizer willBeginSpeakingString:(NSString *)text;

/*!
 @abstract Sent when the vocalizer finishes speaking or ends with an error.
 
 @param vocalizer The vocalizer sending the message.
 @param text The text sent to one of the speakString: methods.
 @param error An error or nil in the case of no error.
 
 @discussion This message will always be sent one time for each speech request
 sent to the speakString: methods.  In the case that there are no errors, this
 method will be called when the speech playback finishes with error set to
 nil.  If there is an error at any stage of the speech request, this method
 will be called immediately with error set to indicate the failure.
 */
- (void)ebvocalizer:(id<EBVocalizer>)vocalizer didFinishSpeakingString:(NSString *)text withError:(NSError *)error;

@end
