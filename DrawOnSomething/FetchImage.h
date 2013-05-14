//
//  FetchImage.h
//  DrawOnSomething
//
//  Created by JRamos on 5/13/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FetchImage : NSObject <NSURLConnectionDataDelegate>


@property (strong, nonatomic) NSMutableArray *arrayOfIDs;
@property (strong, nonatomic) NSMutableArray *arrayOfThumbs;
@property (strong, nonatomic) NSMutableArray *arrayOfLargeImages;
@property (strong, nonatomic) NSMutableArray *arrayOfFarms;
@property (strong, nonatomic) NSMutableArray *arrayOfServers;
@property (strong, nonatomic) NSMutableArray *arrayOfSecrets;

@property (strong, nonatomic) NSString *passSearch;

+ (id)sharedInstance;

- (void)runQuery;
- (UIImage*)getLargeImage:(int)index;


@end
