//
//  EBVocalizerFactory.m
//  EBSpeech
//
//  Created by Lineker_IBM on 2013-07-16.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import "EBVocalizerFactory.h"
#import "EBGoogleVocalizer.h"

@implementation EBVocalizerFactory

+(id <EBVocalizer>) initVocalizerWithService:(EBSpeechVocalizerService)service language:(NSString *)language delegate:(id <EBVocalizerDelegate>)delegate
{
    switch (service) {
        case EBGoogleVocalizerService:
            return [[EBGoogleVocalizer alloc] initWithLanguage:language delegate:delegate];
            break;
    
        default:
            return nil;
    }
}

+(id <EBVocalizer>) initVocalizerWithService:(EBSpeechVocalizerService)service voice:(NSString *)voice delegate:(id <EBVocalizerDelegate>)delegate
{
    switch (service) {
        case EBGoogleVocalizerService:
            return [[EBGoogleVocalizer alloc] initWithVoice:voice delegate:delegate];
            break;
        default:
            return nil;
    }
}

@end
