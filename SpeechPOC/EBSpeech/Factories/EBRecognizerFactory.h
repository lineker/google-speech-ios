//
//  EBRecognizerFactory.h
//  EBSpeech
//
//  Created by Lineker_IBM on 2013-07-16.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBRecognizer.h"

/*!
 @abstract Type for recognizer.
 */
typedef NSUInteger EBSpeechRecognizerService;

/*!
 @enum Recognizer Service
 @abstract These constants define the various speech recognizer services (voice to text)
 @constant EBGoogleService
 @constant EBVaniService
 */
enum {
    EBGoogleRecognizerService = 1,
};

@interface EBRecognizerFactory : NSObject

+ (id <EBRecognizer>)initRecognizerWithService:(EBSpeechRecognizerService)service type:(NSString *)type detection:(EBEndOfSpeechDetection)detection language:(NSString *)language delegate:(id <EBRecognizerDelegate>)delegate;

@end
