//
//  ViewController.h
//  DrawOnSomething
//
//  Created by JRamos on 5/13/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditImageController.h"

@interface FetchViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ModalDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;

@property (strong, nonatomic) NSMutableArray *flickrImage;
@property (strong, nonatomic) NSMutableArray *appsButtonImages;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
