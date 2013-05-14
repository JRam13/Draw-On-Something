//
//  MyGalleryController.h
//  DrawOnSomething
//
//  Created by JRamos on 5/14/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyGalleryController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *galleryCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *savedImage;

@property (strong, nonatomic) NSMutableArray *arrayOfImages;

@end
