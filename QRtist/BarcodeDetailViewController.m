/**
 *  BarcodeDetailViewController.m
 *  QRtist
 *
 *  View controller for barcode detail screen. This is the main screen for editing
 *  barcodes.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "BarcodeDetailViewController.h"
#import "UIViewController+Animation.h"
#import "CreateSelectDesign.h"
#import "EnterPlaintextViewController.h"
#import "BlueprintNavController.h"
#import "WebsiteURLViewController.h"
#import "ContactCardViewController.h"
#import "EditCustomGraphicViewController.h"
#import "QRCodeStorageCenter.h"

#import "CustomizeViewController.h"
#import "CustomizePreviewView.h"

#import <QuartzCore/QuartzCore.h>

#define kAddImageActionSheet 1
#define kEditContentsActionSheet 2

@implementation BarcodeDetailViewController
@synthesize changeContentsButton;
@synthesize custoOptionsButton;
@synthesize barcode;
@synthesize qrCodeLabel;
@synthesize innerView;
@synthesize previewImage;
@synthesize guideLine1, guideLine2, guideLine3, guideLine4;
@synthesize changeGraphic, scrollView;
@synthesize hidePreviewImage;
@synthesize editingDelegate;
@synthesize labelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.barcode = nil;
        self.hidePreviewImage = NO;
        self.editingDelegate = nil;
    }
    return self;
}

- (void)animateGuidelines {
	[UIView beginAnimations:@"animateGuidelines" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.55];
	[guideLine1 setTransform:CGAffineTransformIdentity];
	[guideLine2 setTransform:CGAffineTransformIdentity];
	[guideLine3 setTransform:CGAffineTransformMakeRotation(M_PI_2)];
	[guideLine4 setTransform:CGAffineTransformMakeRotation(M_PI_2)];
	
	[guideLine1 setAlpha:1.0f];
	[guideLine2 setAlpha:1.0f];
	[guideLine3 setAlpha:1.0f];
	[guideLine4 setAlpha:1.0f];
	[UIView commitAnimations];
}

- (void)setBarcode:(QACode *)_barcode {
    barcode = [_barcode retain];
    
    [self.previewImage setImage:[barcode imageRepresentation]];
}

- (void)detailViewWillDismiss:(id)sender
{
    NSArray *barcodes = [[QRCodeStorageCenter sharedStorageCenter] barcodes];
    if (![barcodes containsObject:barcode]) {
        [[QRCodeStorageCenter sharedStorageCenter] addBarcode:barcode];
    }
    
    if (self.editingDelegate != nil) {
        if ([self.editingDelegate conformsToProtocol:@protocol(BarcodeEditing)]) {
            [self.editingDelegate barcodeFinishedEditing:barcode];
        }
    }
}

- (IBAction)changeName:(id)sender {
    UIAlertView *changeNameAlert = [[UIAlertView alloc] initWithTitle:@"Rename Barcode"
                                                              message:@"Please enter the new name for the barcode."
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"OK", nil];
    
    [changeNameAlert addTextFieldWithValue:@"" label:@"Name"];
    [changeNameAlert show];
    [changeNameAlert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *newName = [[alertView textFieldAtIndex:0] text];
        
        [qrCodeLabel setText:newName];
        [barcode setTitle:newName];
    }
}

- (void)close {
    [self detailViewWillDismiss:self];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Edit Barcode";
    
    // If I just change the UIButton's titleLabel properties, the text inside
    // the label gets clipped. This has been confirmed to be a bug in Apple's 
    // implementation of UIButton's title label.
    // http://stackoverflow.com/questions/3484788/uilabel-sizewithfont-problem-clipping-italic-text
    qrCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelButton.frame.size.width, labelButton.frame.size.height)];
    [qrCodeLabel setTextAlignment:UITextAlignmentCenter];
    [qrCodeLabel setBackgroundColor:[UIColor clearColor]];
    [qrCodeLabel setShadowColor:[UIColor blackColor]];
    [qrCodeLabel setShadowOffset:CGSizeMake(0, 1)];
    [qrCodeLabel setTextColor:[UIColor whiteColor]];
    [labelButton addSubview:qrCodeLabel];
    
    [innerView setBackgroundColor:[UIColor clearColor]];
    [scrollView setContentSize:innerView.frame.size];
    [scrollView addSubview:innerView];
    [scrollView setFrame:self.view.frame];
    
    if (barcode != nil)
        [qrCodeLabel setText:[barcode title]];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    [self.navigationItem setLeftBarButtonItem:closeButton];
    [closeButton release];
    
    if (hidePreviewImage)
        [previewImage setHidden:YES];
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blueprint-Blank.png"]]];
	
	
    UIFont *buttonFont = [UIFont fontWithName:@"BlessingsthroughRaindrops" size:16.0f];
    
	[[changeGraphic titleLabel] setFont:buttonFont];
    [[changeContentsButton titleLabel] setFont:buttonFont];
    [[custoOptionsButton titleLabel] setFont:buttonFont];
    
	[qrCodeLabel setFont:[UIFont fontWithName:@"Andrew Ward" size:20.0f]];
	
	[guideLine3 setTransform:CGAffineTransformMakeRotation(M_PI_2)];
	[guideLine4 setTransform:CGAffineTransformMakeRotation(M_PI_2)];
	
	[guideLine1 setAlpha:0.0f];
	[guideLine2 setAlpha:0.0f];
	[guideLine3 setAlpha:0.0f];
	[guideLine4 setAlpha:0.0f];
	
	[guideLine1 setTransform:CGAffineTransformMakeTranslation(0, 300)];
	[guideLine2 setTransform:CGAffineTransformMakeTranslation(0, -300)];
	[guideLine3 setTransform:CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI_2), CGAffineTransformMakeTranslation(-300, 0))];
	[guideLine4 setTransform:CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI_2), CGAffineTransformMakeTranslation(300, 0))];
	
	[self performSelector:@selector(animateGuidelines) withObject:nil afterDelay:0.65];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popViewControllerAnimated:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [(BlueprintNavBar*)self.navigationController.navigationBar setBgImage:nil];
    [(BlueprintNavBar*)self.navigationController.navigationBar setNeedsDisplay];
    [(BlueprintNavBar*)self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.2588 green:0.486 blue:0.8588 alpha:1.0]];
    
    if (self.barcode != nil) {
        [self.previewImage setImage:[self.barcode imageRepresentation]];
        
        if (self.barcode.customImage == nil) {
            [changeGraphic setTitle:@"Add Custom Graphic" forState:UIControlStateNormal];
        } else {
            [changeGraphic setTitle:@"Edit Custom Graphic" forState:UIControlStateNormal];
        }
    }
}

- (void)viewDidUnload
{
    [self setPreviewImage:nil];
    [self setChangeContentsButton:nil];
    [self setInnerView:nil];
    [self setCustoOptionsButton:nil];
    [self setLabelButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Action Methods

- (IBAction)addImageButtonAction:(id)sender {
    if (self.barcode.customImage != nil) {
        UIImage *img = self.barcode.customImage;
        float scale = self.barcode.imageScale;
        
        EditCustomGraphicViewController *vc = [[EditCustomGraphicViewController alloc] initWithNibName:@"EditCustomGraphicViewController" bundle:[NSBundle mainBundle]];
        [self.barcode setCustomImage:nil];
        [vc setCustomGraphic:img];
        [vc setExistingCode:self.barcode];
        [vc setGraphicScale:scale];
        
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select Media Source"
                                                           delegate:self 
                                                  cancelButtonTitle:@"Cancel" 
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Camera", @"Photo Library", nil];
        sheet.tag = kAddImageActionSheet;
        [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        [sheet showInView:self.view];
        [sheet release];
    }
}

- (IBAction)changeBarcodeContents:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Edit Existing Data", @"Select New Data Source", nil];
    [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    sheet.tag = kEditContentsActionSheet;
    [sheet showInView:self.view];
    [sheet release];
}

- (IBAction)changeCustoOptions:(id)sender {
    CustomizeViewController *custo = [[CustomizeViewController alloc] initWithNibName:@"CustomizeViewController" bundle:nil];
    [custo setCode:self.barcode];
    [self.navigationController pushViewController:custo animated:YES];
    [custo release];
}

#pragma mark - Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kAddImageActionSheet) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setAllowsEditing:YES];
        [imagePicker setDelegate:self];
        if (buttonIndex == 0) {
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
        } else if (buttonIndex == 1) {
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        } else {
            return;
        }
        
        [self presentModalViewController:imagePicker animated:YES];
    }
    
    if (actionSheet.tag == kEditContentsActionSheet) {
        if (buttonIndex == 0) {
            QRCodeDataType dataType = [barcode dataType];
            BarcodeDataEditor *editor;
            
            if (dataType == QRCodeDataTypePlaintext) {
                editor = [[EnterPlaintextViewController alloc] initWithNibName:@"EnterPlaintextViewController" bundle:nil];
            } else if (dataType == QRCodeDataTypeURL) {
                editor = [[WebsiteURLViewController alloc] initWithNibName:@"WebsiteURLViewController" bundle:nil];
            } else if (dataType == QRCodeDataTypeContactCard) {
                editor = [[ContactCardViewController alloc] initWithNibName:@"ContactCardViewController" bundle:nil];
            }
            
            [editor setExistingCode:barcode];
            [editor setDelegate:self];
            
            [self.navigationController pushViewController:editor animated:YES];
            [editor release];
        } else if (buttonIndex == 1) {
            CreateSelectDesign *csd = [[CreateSelectDesign alloc] initWithNibName:@"CreateSelectDesign" bundle:nil];
            [csd setExistingCode:barcode];
            [csd setDelegate:self];
            [csd.navigationItem setLeftBarButtonItem:csd.navigationItem.backBarButtonItem];
            [csd.navigationItem setTitle:@"select data source"];
            
            
            [self.navigationController pushViewController:csd animated:YES];
            
            [csd viewWillAppear:YES];
            [csd release];
        } else {
            return;
        }
    }
}


- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    BOOL camera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!camera) {
        for (UIView *view in [actionSheet subviews]) {
            if ([[[view class] description] isEqualToString:@"UIThreePartButton"]) {
                if ([view respondsToSelector:@selector(title)]) {
                    NSString *title = [view performSelector:@selector(title)];
                    if ([title isEqualToString:@"Camera"] && [view respondsToSelector:@selector(setEnabled:)]) {
                        [view performSelector:@selector(setEnabled:) withObject:NO];
                    }
                }
            }
        }
    }
}


#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    EditCustomGraphicViewController *vc = [[EditCustomGraphicViewController alloc] initWithNibName:@"EditCustomGraphicViewController" bundle:[NSBundle mainBundle]];
    [vc setExistingCode:self.barcode];
    [vc setCustomGraphic:selectedImage];
    [self.navigationController pushViewController:vc animated:NO];
    [vc release];
}


#pragma mark - Delegate Methods

- (void)dataEditorDidFinishEditing
{
    [self.navigationController popToViewController:self animated:YES];
}


#pragma mark - Memory Management

- (void)dealloc
{
	[guideLine1 release];
	[guideLine2 release];
	[guideLine3 release];
	[guideLine4 release];
	
	[changeGraphic release];
	
	[scrollView release];
    //[barcode release];
    [previewImage release];
    [changeContentsButton release];
    [innerView release];
    [custoOptionsButton release];
    
    [editingDelegate release];
    
    [labelButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
