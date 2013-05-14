//
//  FetchImage.m
//  DrawOnSomething
//
//  Created by JRamos on 5/13/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "FetchImage.h"
#import <Foundation/NSJSONSerialization.h>

#define kFlickrAPIKey @"226867bac90e19db7611636a8cf11b6a"

@implementation FetchImage
{
    NSMutableData *webData;
    NSURLConnection *connection;
    
    NSDictionary *photos;
    
}

@synthesize passSearch;


static FetchImage *sharedInstance = nil;

+ (FetchImage *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        //NSLog(@"init");
        
        
    }
    
    return self;
}

-(void)runQuery
{
    NSString *replaceSpace = [passSearch stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    replaceSpace = [NSString stringWithFormat:@"%@" , passSearch];
    
    NSString *currentQuery = [NSString stringWithFormat: @"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&per_page=40&format=json&nojsoncallback=1", kFlickrAPIKey, replaceSpace];
    
    NSURL *url1 = [NSURL URLWithString:currentQuery];
    NSURLRequest *request = [NSURLRequest requestWithURL:url1];
    
    connection = [NSURLConnection connectionWithRequest:request delegate:self];

    
    if(connection){
        webData = [[NSMutableData alloc] init];
        _arrayOfIDs = [[NSMutableArray alloc] init];
        _arrayOfThumbs = [[NSMutableArray alloc] init];
        _arrayOfLargeImages = [[NSMutableArray alloc] init];
        _arrayOfServers = [[NSMutableArray alloc] init];
        _arrayOfSecrets = [[NSMutableArray alloc] init];
        _arrayOfFarms = [[NSMutableArray alloc] init];
        
    }
}



-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
    NSLog(@"Did recieve App Data!");
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection did fail with error");
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Fetch Image
        NSDictionary *allAppDataDictionary = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
        photos = [allAppDataDictionary objectForKey:@"photos"];
        NSArray *arrayOfEntry = [photos objectForKey:@"photo"];
        
        for (NSDictionary *diction in arrayOfEntry) {
            NSDictionary *pid = [diction objectForKey:@"id"];
            NSDictionary *farm = [diction objectForKey:@"farm"];
            NSDictionary *server = [diction objectForKey:@"server"];
            NSDictionary *secret = [diction objectForKey:@"secret"];
            
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_arrayOfIDs addObject:pid];
                [_arrayOfFarms addObject:farm];
                [_arrayOfSecrets addObject:secret];
                [_arrayOfServers addObject:server];
                
                //NSLog(@"IDs: %@", [_arrayOfServers lastObject]);
            });
        }
        
        //This code runs once after fethching is done
        //Process photos
        [self loadThumbnailsIntoArray];
        
    });
    
    //[avc.AppsCollectionView reloadData];
    //avc = [[AppsViewController alloc] init];
    
    
    
}

-(void)loadThumbnailsIntoArray
{
    
    for (int i=0; i<[_arrayOfIDs count]; i++) {
        
         NSString *imageURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg",_arrayOfFarms[i], _arrayOfServers[i],_arrayOfIDs[i],_arrayOfSecrets[i],@"q"];
        
        NSError *error = nil;
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]
                                                  options:0
                                                    error:&error];
        
        UIImage *image = [UIImage imageWithData:imageData];
        
        [_arrayOfThumbs addObject:image];

    }
   
}

-(UIImage*)getLargeImage:(int)index
{
    NSString *imageURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg",_arrayOfFarms[index], _arrayOfServers[index],_arrayOfIDs[index],_arrayOfSecrets[index],@"b"];
    
    NSError *error = nil;
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]
                                              options:0
                                                error:&error];
    
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    // No explicit autorelease pool needed here.
//    // The code runs in background, not strangling
//    // the main run loop.
//    [self doSomeLongOperation];
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        // This will be called on the main thread, so that
//        // you can update the UI, for example.
//        [self longOperationDone];
//    });
//});



@end
