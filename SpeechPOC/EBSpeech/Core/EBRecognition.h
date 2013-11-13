//
//  EBRecognition.h
//  EBSpeech
//
//  Created by Lineker_ on 2013-07-16.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBRecognition : NSObject
/*!
 @abstract An NSArray containing NSStrings corresponding to what may have been
 said, in order of likelihood.
 
 @discussion The speech recognition server returns an array of recognition
 results by order of confidence.  The first result in the array is what was
 most likely said.  The remaining list of alternatives is ranked from most
 likely to least likely.
 */
@property (nonatomic, strong) NSMutableArray *results;

/*!
 @abstract An NSArray of NSNumbers containing the confidence scores
 corresponding to each recognition result in the results array.
 */
@property (nonatomic, strong) NSMutableArray *scores;

/*!
 @abstract A server-generated suggestion suitable for presentation to the user.
 
 @discussion This is a suggestion to the user about how he or she can improve
 recognition performance and is based on the audio received.  Examples include
 moving to a less noisy location if the environment is extremely noisy, or
 waiting a bit longer to start speaking if the beeginning of the recording seems
 truncated.  Results are often still present and may still be of useful quality.
 */
@property (nonatomic, strong) NSString *suggestion;

/*!
 @abstract Additional service-specific data.
 */
@property (nonatomic, strong) NSObject *data;

/*!
 @abstract Returns the first NSString result in the results array.
 @result The first NSString result in the results array or nil.
 
 @discussion This is a convenience method to simply return the best result in the
 list of results returned from the recognition server.  It returns nil if the list
 of results is empty.
 */
- (NSString *)firstResult;

@end
