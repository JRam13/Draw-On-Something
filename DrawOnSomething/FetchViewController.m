//
//  ViewController.m
//  DrawOnSomething
//
//  Created by JRamos on 5/13/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "FetchViewController.h"
#import "FetchImage.h"
#import "ImageCell.h"
#import "EditImageController.h"

@interface FetchViewController ()

@end

@implementation FetchViewController
{
    FetchImage *flickr;
    NSTimer *timer;
    
    EditImageController *eic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _flickrImage = [[NSMutableArray alloc] init];
	
    flickr = [[FetchImage alloc]init];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.2f
                                              target:self
                                            selector:@selector(reload)
                                            userInfo:nil
                                             repeats:YES];
    
    
    
}

-(void)reload
{
    if([_flickrImage count] == 20){
        [timer invalidate];
        
        //[_image setImage:flickr.arrayOfImages[0]];

    }
    
    _flickrImage = flickr.arrayOfThumbs;
    [self.imageCollectionView reloadData];

}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //NSLog(@"count: %d" , [flickr.arrayOfImages count]);
    return [flickr.arrayOfThumbs count];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"appsLabel count: %d", [_appsLabels count]);
    //NSLog(@"ArrayofTitles count: %d", [appData.arrayOfTitles count]);
    
    
    static NSString *CellIndentifier = @"ImageCell";
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIndentifier forIndexPath:indexPath];
    [[cell image]setImage:[_flickrImage objectAtIndex:indexPath.item]];
    //[_image setImage:flickr.arrayOfImages[0]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected: %d" , indexPath.item);
    eic.thumbImage = [_flickrImage objectAtIndex:indexPath.item];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        eic.detailImage = [flickr getLargeImage:indexPath.item];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [eic fetchImage];
        });
    });
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueDetail"]){
        eic = (EditImageController*)segue.destinationViewController;
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)detailsViewDidDismiss:(EditImageController *)dvc
{
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchQuery = searchBar.text;
    flickr.passSearch = searchQuery;
    
    [searchBar resignFirstResponder];
    
    
    [_flickrImage removeAllObjects];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.2f
                                              target:self
                                            selector:@selector(reload)
                                            userInfo:nil
                                             repeats:YES];
    
    [flickr runQuery];
    [self reload];
    
    
}
@end
