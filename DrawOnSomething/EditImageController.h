//
//  EditImageController.h
//  DrawOnSomething
//
//  Created by JRamos on 5/13/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintView.h"

@class EditImageController;

@protocol ModalDelegate <NSObject>

- (void)detailsViewDidDismiss: (EditImageController*)dvc;

@end

@interface EditImageController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PaintViewDelegate, UIAlertViewDelegate>
- (IBAction)uploadBTN:(UIButton *)sender;
- (IBAction)saveImageBTN:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *filterCollectionView;

- (void)paintView:(PaintView*)paintView finishedTrackingPath:(CGPathRef)path inRect:(CGRect)painted;

- (IBAction)dismissBTN:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *largeImage;
@property (weak, nonatomic) UIImage *detailImage;
@property (weak, nonatomic) UIImage *thumbImage;
@property (strong, nonatomic) NSMutableArray *filteredThumbs;
@property (strong, nonatomic) NSMutableArray *filterNames;

-(void)fetchImage;

@end
