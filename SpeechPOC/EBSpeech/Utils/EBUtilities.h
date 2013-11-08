//
//  EBUtilities.h
//  EBSpeech
//
//  Created by Lineker_IBM on 2013-07-15.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBUtilities : NSObject

+ (NSDictionary *)parseJson:(NSData *)returnedData;
+ (NSString *) escapeString:(NSString *)string;
+ (NSURL *) getURLforFilename:(NSString *)name extension:(NSString *)ext;
@end
