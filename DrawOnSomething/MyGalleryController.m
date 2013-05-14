//
//  MyGalleryController.m
//  DrawOnSomething
//
//  Created by JRamos on 5/14/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "MyGalleryController.h"
#import "GalleryCell.h"

@interface MyGalleryController ()

@end

@implementation MyGalleryController
{
    int imageCount;
    NSArray *filelist;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _arrayOfImages = [[NSMutableArray alloc] init];
    
    [self updateImageCount];
    
    [self loadImages];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadImages];
    [self.galleryCollectionView reloadData];
}

-(void)updateImageCount
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filelist= [fm contentsOfDirectoryAtPath:[docPaths objectAtIndex:0] error:nil];
    imageCount = [filelist count];
}

- (void)loadImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSArray *documentArray;
    if([paths count] > 0)
    {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSError *error = nil;
        documentArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
        if(error)
        {
            NSLog(@"Could not get list of documents in directory, error = %@",error);
        }
    }
    
    for (NSString *doc in documentArray ) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",doc]];
        UIImage* image = [UIImage imageWithContentsOfFile:path];
        [_arrayOfImages insertObject:image atIndex:0];
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"Image count: %d" , imageCount);
    [self updateImageCount];
    NSLog(@"Image count: %d" , imageCount);
    return imageCount;
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"appsLabel count: %d", [_appsLabels count]);
    //NSLog(@"ArrayofTitles count: %d", [appData.arrayOfTitles count]);
    
    
    static NSString *CellIndentifier = @"GalleryCell";
    GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIndentifier forIndexPath:indexPath];
    [[cell galleryImage]setImage:[_arrayOfImages objectAtIndex:indexPath.item]];
    NSLog(@"%d" , indexPath.item);
    //[_image setImage:flickr.arrayOfImages[0]];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
