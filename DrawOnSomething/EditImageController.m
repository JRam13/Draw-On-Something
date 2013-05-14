//
//  EditImageController.m
//  DrawOnSomething
//
//  Created by JRamos on 5/13/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "EditImageController.h"
#import "FetchImage.h"
#import "PaintView.h"
#import "FilterCell.h"
#import "MyGalleryController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface EditImageController ()
@property BOOL shouldMerge;
@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) PaintView *paintView;
@property (strong, nonatomic) UIImage *originalThumb;
@property (strong, nonatomic) UIImage *originalLarge;

@end

@implementation EditImageController
{
    NSTimer *timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _filteredThumbs = [[NSMutableArray alloc] init];
    _filterNames = [[NSMutableArray alloc] initWithObjects:@"Original", @"Sepia", @"Color Invert", @"Blur", @"Hue Adjustment", nil];
    
    
    self.shouldMerge = YES;

}

-(void)setFilteredThumbs
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        //put each filtered thumb in an array
        
        //original
        _originalThumb = _thumbImage;
        [_filteredThumbs addObject:_originalThumb];
        
        //sepia
        [_filteredThumbs addObject:[self filerSepia:_originalThumb]];
        
        //black/white
        [_filteredThumbs addObject:[self filterColorInvert:_originalThumb]];
        
        //blur
        [_filteredThumbs addObject:[self filterBlur:_originalThumb]];
        
        //hue
        [_filteredThumbs addObject:[self filterHueAdjust:_originalThumb]];
        
    });
}

-(void)reload
{
    if([_filteredThumbs count] == 5){
        [timer invalidate];
    }

    [self.filterCollectionView reloadData];
}

#pragma mark - Paint View Delegagte Protocol Methods
/*******************************************************************************
 * @method          paintView:
 * @abstract
 * @description
 *******************************************************************************/
- (void)paintView:(PaintView*)paintView finishedTrackingPath:(CGPathRef)path inRect:(CGRect)painted
{
    if (self.shouldMerge) {
        [self mergePaintToImageView:painted];
    }
}

/*******************************************************************************
 * @method          mergePaintToBackgroundView
 * @abstract        Combine the last painted image into the current background image
 * @description
 *******************************************************************************/
- (void)mergePaintToImageView:(CGRect)painted
{
    // Create a new offscreen buffer that will be the UIImageView's image
    CGRect bounds = self.largeImage.bounds;
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, self.largeImage.contentScaleFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Copy the previous background into that buffer.  Calling CALayer's renderInContext: will redraw the view if necessary
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    [self.largeImage.layer renderInContext:context];
    
    // Now copy the painted contect from the paint view into our background image
    // and clear the paint view.  as an optimization we set the clip area so that we only copy the area of paint view
    // that was actually painted
    CGContextClipToRect(context, painted);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [self.paintView.layer renderInContext:context];
    [self.paintView erase];
    
    // Create UIImage from the context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [_largeImage setImage:image];
    //_detailImage = image;
    
    UIGraphicsEndImageContext();
    
}



-(void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchImage
{
    [_largeImage setImage:_detailImage];
    
    // Create a painting view
    _paintView = [[PaintView alloc] initWithFrame:self.largeImage.bounds];
    self.paintView.lineColor = [UIColor grayColor];
    self.paintView.delegate = self;
    [self.view addSubview:self.paintView];
    
    //allow touches on imageView
    self.largeImage.userInteractionEnabled = YES;
    
    [self setFilteredThumbs];
    
    _originalLarge = _detailImage;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.2f
                                             target:self
                                           selector:@selector(reload)
                                           userInfo:nil
                                            repeats:YES];
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //NSLog(@"count: %d" , [flickr.arrayOfImages count]);
    return [_filteredThumbs count];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"appsLabel count: %d", [_appsLabels count]);
    //NSLog(@"ArrayofTitles count: %d", [appData.arrayOfTitles count]);
    
    
    static NSString *CellIndentifier = @"FilterCell";
    FilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIndentifier forIndexPath:indexPath];
    [[cell filterImage]setImage:[_filteredThumbs objectAtIndex:indexPath.item]];
    [[cell filterLabel]setText:[_filterNames objectAtIndex:indexPath.item]];
    //[_image setImage:flickr.arrayOfImages[0]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Thumb selected: %d" , indexPath.item);
    //Apply filter to large image here
    _detailImage = self.largeImage.image;
    if(indexPath.item == 0){
        [_largeImage setImage:_originalLarge];
    }
    else if(indexPath.item == 1){
        [_largeImage setImage:[self filerSepia:_detailImage]];
    }
    else if(indexPath.item == 2){
        [_largeImage setImage:[self filterColorInvert:_detailImage]];
    }
    else if(indexPath.item == 3){
        [_largeImage setImage:[self filterBlur:_detailImage]];
    }
    else if(indexPath.item == 4){
        [_largeImage setImage:[self filterHueAdjust:_detailImage]];
    }
    
}

- (IBAction)dismissBTN:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)uploadBTN:(UIButton *)sender {
    
    UIAlertView *upload;
    
    upload = [[UIAlertView alloc] initWithTitle:nil message:@"Upload to Facebook?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    
    [upload show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [self promptUserWithAccountNameForUploadPhoto];
        
    }
    
}

-(void)promptUserWithAccountNameForUploadPhoto {
    
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://facebook.com"]];
}

- (IBAction)saveImageBTN:(UIButton *)sender {

    //UIImageWriteToSavedPhotosAlbum(self.largeImage.image, nil, nil, nil);
    
    UIAlertView *saved;
    
    saved = [[UIAlertView alloc] initWithTitle:nil message:@"Image Saved To Photo Library" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    
    [saved show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@.jpg" , timeStampObj] ];
    NSData* data = UIImagePNGRepresentation(self.largeImage.image);
    [data writeToFile:path atomically:YES];
    
    // Let's check to see if files were successfully written...
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // Write out the contents of home directory to console
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    

}


/*
 -------------------------------------------------------
 ------------------------FILTERS------------------------
 -------------------------------------------------------
 */

- (UIImage*)filerSepia:(UIImage *)original
{
    
    CIImage *beginImage = [CIImage imageWithCGImage:original.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"
                                  keysAndValues: kCIInputImageKey, beginImage,
                        @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
    
    return newImg;
}

- (UIImage*)filterColorInvert:(UIImage *)original
{
    
    CIImage *beginImage = [CIImage imageWithCGImage:original.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    //invert
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setDefaults];
    [filter setValue: beginImage forKey: kCIInputImageKey];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
    
    return newImg;
}

- (UIImage*)filterBlur:(UIImage *)original
{
    //blur
    CIImage *beginImage = [CIImage imageWithCGImage:original.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *bFilter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:kCIInputImageKey, beginImage, @"inputRadius", @1.0, nil];
    
    CIVector *point0 =[CIVector vectorWithX:0.0 Y:(0.75 * 4.0)];
    CIVector *point1 =[CIVector vectorWithX:0.0 Y:(0.5*4.0)];
    CIColor *color0 = [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    CIColor *color1 = [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.0];
    CIFilter *gradient1 = [CIFilter filterWithName:@"CILinearGradient" keysAndValues:@"inputPoint0", point0, @"inputColor0", color0, @"inputPoint1", point1, @"inputColor1", color1, nil];
    
    point0 =[CIVector vectorWithX:0.0 Y:(0.25 * 4.0)];
    CIFilter *gradient2 = [CIFilter filterWithName:@"CILinearGradient" keysAndValues:@"inputPoint0", point0, @"inputColor0", color0, @"inputPoint1", point1, @"inputColor1", color1, nil];
    
    CIFilter *mask = [CIFilter filterWithName:@"CIAdditionCompositing" keysAndValues:kCIInputImageKey, gradient1.outputImage, kCIInputBackgroundImageKey, gradient2.outputImage, nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIBlendWithMask" keysAndValues:kCIInputImageKey, bFilter.outputImage, kCIInputBackgroundImageKey, beginImage, @"inputMaskImage", mask.outputImage, nil];

    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
    
    return newImg;
}

- (UIImage*)filterHueAdjust:(UIImage *)original
{
    
    //hue adjustment
    CIImage *beginImage = [CIImage imageWithCGImage:original.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIHueAdjust"];
    [filter setDefaults];
    [filter setValue: beginImage forKey: kCIInputImageKey];
    [filter setValue: [NSNumber numberWithFloat: 3.0f] forKey: @"inputAngle"];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
    
    return newImg;
}
@end
