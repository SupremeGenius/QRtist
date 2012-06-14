/**
 *  EditCustomGraphicViewController.m
 *  QRtist
 *
 *  View Controller that manages the screen that allows for placement and
 *  scaling of custom graphics within a barcode.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "EditCustomGraphicViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface EditCustomGraphicViewController ()

- (void)commitBarcodeChanges;

@end

@implementation EditCustomGraphicViewController
@synthesize customGraphic, graphicScale;
@synthesize _barcodeImageView, _scaleLabel;
@synthesize _scaleSlider;

BOOL _deleting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.customGraphic = nil;
        graphicScale = 1.0;
        _graphicImageView = nil;
        _deleting = NO;
    }
    return self;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Edit Custom Graphic";
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blueprint-Blank.png"]]];
    
    UIFont *labelFont = [UIFont fontWithName:@"BlessingsthroughRaindrops" size:16.0f];
    [_scaleLabel setFont:labelFont];
    
    UIImage *barcodeImg = [self.existingCode imageRepresentation];
    [_barcodeImageView setImage:barcodeImg];
    _barcodeImageView.layer.masksToBounds = NO;
    _barcodeImageView.layer.shadowOffset = CGSizeZero;
    _barcodeImageView.layer.shadowRadius = 5;
    _barcodeImageView.layer.shadowOpacity = 0.7;
    _barcodeImageView.layer.shouldRasterize = YES;
    
    if (customGraphic != nil) {
        CGSize barcode_sz = _barcodeImageView.bounds.size;
        CGSize target_sz = [self.existingCode sizeForCustomGraphic:customGraphic];
        _graphicImageView = [[UIImageView alloc] initWithImage:customGraphic];
        [_graphicImageView setFrame:CGRectMake(barcode_sz.width / 2 - target_sz.width / 2, barcode_sz.height / 2 - target_sz.height / 2,
                                               target_sz.width, target_sz.height)];
        [_barcodeImageView addSubview:_graphicImageView];
    }
    
    [_scaleSlider setValue:graphicScale];
    _graphicImageView.layer.transform = CATransform3DMakeScale(graphicScale, graphicScale, 0);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self commitBarcodeChanges];
}

- (void)viewDidUnload
{
    self._scaleLabel = nil;
    self._scaleSlider = nil;
    self._barcodeImageView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Action Methods

- (IBAction)scaleSliderAction:(UISlider *)slider
{
    float scale = [slider value];
    graphicScale = scale;
    _graphicImageView.layer.transform = CATransform3DMakeScale(scale, scale, 0);
}

- (IBAction)deleteAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Custom Graphic" 
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}


#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.existingCode setCustomImage:nil];
        [self.existingCode setImageOffset:CGPointZero];
        [self.existingCode setImageScale:1.0];
        
        _deleting = YES;
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Data Management

- (void)commitBarcodeChanges
{
    if (!_deleting) {
        CGSize graphic_sz = [self.existingCode sizeForCustomGraphic:_graphicImageView.image];
        [self.existingCode setCustomImage:_graphicImageView.image];
        
        CGSize barcode_sz = [[self.existingCode imageRepresentation] size];
        CGPoint offset = CGPointMake(barcode_sz.width / 2 - (graphic_sz.width * graphicScale) / 2, barcode_sz.height / 2 - (graphic_sz.height * graphicScale) / 2);
        [self.existingCode setImageOffset:offset];
        [self.existingCode setImageScale:graphicScale];
    }
}


#pragma mark - Memory Management

- (void)dealloc
{
    [customGraphic release];
    [_barcodeImageView release];
    [_scaleLabel release];
    [_scaleSlider release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
