//
//  EBVocalizerFactory.h
//  EBSpeech
//
//  Created by Lineker_IBM on 2013-07-16.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBVocalizer.h"
/*!
 @abstract Type for recognizer.
 */
typedef NSUInteger EBSpeechVocalizerService;

/*!
 @enum Vocalizer Service
 @abstract These constants define the various speech recognizer services (voice to text)
 @constant EBGoogleService
 @constant EBVaniService
 */

enum {
    EBGoogleVocalizerService = 1,
    EBVaniVocalizerService = 2,
};

@interface EBVocalizerFactory : NSObject

+(id <EBVocalizer>) initVocalizerWithService:(EBSpeechVocalizerService)service voice:(NSString *)voice delegate:(id <EBVocalizerDelegate>)delegate;


+(id <EBVocalizer>) initVocalizerWithService:(EBSpeechVocalizerService)service language:(NSString *)language delegate:(id <EBVocalizerDelegate>)delegate;

@end
