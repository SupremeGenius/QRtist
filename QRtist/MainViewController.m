/**
 *  MainViewController.m
 *  QRtist
 *
 *  View controller for the main screen of the app. This is the first screen
 *  that the user sees when the application launches. It displays all of the
 *  barcodes loaded from the StorageCenter, and allows the user to flick between
 *  them. It is also a launching off point for editing, exporting, sending, and
 *  deleting barcodes.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *              James Magahern <jamesmag@arizona.edu>
 *              Kevin Geisler <kgeisler@email.arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "MainViewController.h"
#import "BarcodeDetailViewController.h"
#import "QACode.h"
#import "CreateSelectDesign.h"
#import "BlueprintNavController.h"
#import "QRCodeStorageCenter.h"
#import "QRCodePresenter.h"
#import "ExportBarcodeViewController.h"
#import "SHK.h"

#import <QuartzCore/QuartzCore.h>

@interface MainViewController ()

- (void)updatePageControl;
- (void)movePage:(UIPageControl *)sender;

- (UIButton *)buttonForBarcode:(QACode *)code;
- (void)showQRCodeWithButton:(UIButton *)sender;
- (QACode *)getSelectedQRCode;

- (void)setNoBarcodesViewVisible:(BOOL)visible;
- (void)repositionQRCodesAfterDeletion:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)deleteQRCodeAtIndex:(int)index;
- (void)qrCodeAdded:(NSNotification *)notification;

- (void)newBarcode;

@end

@implementation MainViewController
@synthesize scrollView, pageControl, barcodeTitleLabel;
@synthesize noBarcodesView;
@synthesize editButton, sendButton, exportButton, deleteButton;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        qrCodeButtons = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.title = @"QRtist Beta";
    
    UIImage *patternImage = [UIImage imageNamed:@"blueprint-bg.png"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:patternImage]];
    
    UIBarButtonItem *addNew = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newBarcode)];
    [self.navigationItem setRightBarButtonItem:addNew];
    [addNew release];
    
    UIFont *nbTitleFont = [UIFont fontWithName:@"Andrew Ward" size:24.0f];
    UIFont *nbDescFont = [UIFont fontWithName:@"BlessingsthroughRaindrops" size:14.0f];
    [(UILabel *)[noBarcodesView viewWithTag:10] setFont:nbTitleFont];
    [(UILabel *)[noBarcodesView viewWithTag:11] setFont:nbDescFont];
    
    NSArray *qrCodes = [[QRCodeStorageCenter sharedStorageCenter] barcodes];
    
    [self setNoBarcodesViewVisible:([qrCodes count] == 0)];
	[barcodeTitleLabel setFont:[UIFont fontWithName:@"Andrew Ward" size:24.0f]];
    
    
    // Add the QRCode Button Widgets to the Scroll View
    for (QACode *code in qrCodes) {
        UIButton *barcodeButton = [self buttonForBarcode:code];
        barcodeButton.tag = code.storageID;
        [qrCodeButtons addObject:barcodeButton];
        [scrollView addSubview:barcodeButton];
    }
    
    CGSize scrollViewSize = scrollView.bounds.size;
    scrollView.contentSize = CGSizeMake(scrollViewSize.width * [qrCodeButtons count],
                                        scrollView.contentSize.height);
    
    if ([qrCodeButtons count] <= 1) {
        [pageControl setHidden:YES];
    } else {
        [pageControl setNumberOfPages:[qrCodeButtons count]];
        [pageControl setCurrentPage:0];
        [pageControl addTarget:self action:@selector(movePage:) forControlEvents:UIControlEventValueChanged];
    }
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(qrCodeAdded:) name:kQRCodeAddedNotification object:nil];
}

- (void)viewDidUnload
{
    self.pageControl = nil;
    self.scrollView = nil;
    self.barcodeTitleLabel = nil;
    self.noBarcodesView = nil;
    self.editButton = nil;
    self.sendButton = nil;
    self.exportButton = nil;
    self.deleteButton = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Page Control and Management

- (void)updatePageControl
{
	CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    NSArray *qrCodes = [[QRCodeStorageCenter sharedStorageCenter] barcodes];
    if ([qrCodes count] != 0 && page < [qrCodes count])
        [barcodeTitleLabel setText:[[qrCodes objectAtIndex:page] title]];
}

- (void)movePage:(UIPageControl *)sender
{
	int currentPage = [sender currentPage];
    float imageWidth;
    if ([qrCodeButtons count] > 0)
        imageWidth = [[qrCodeButtons objectAtIndex:0] frame].size.width;
    else
        imageWidth = 0;
	float pagePadding = (self.scrollView.frame.size.width / 2.0) - (imageWidth / 2.0f);
	
	[scrollView setContentOffset:CGPointMake((imageWidth + (pagePadding * 2)) * currentPage, 0) animated:YES];
}


#pragma mark - Page Button Methods

- (UIButton *)buttonForBarcode:(QACode *)code
{
    CGSize imgSize = CGSizeMake(200, 200); // This needs to be a constant
    CGSize scrollViewSize = self.scrollView.frame.size;
    float pagePadding = (scrollViewSize.width / 2.0) - (imgSize.width / 2.0f);
    int idx = [qrCodeButtons count];
    
    UIImage *curImg = [code imageRepresentation];
    
    UIButton *imgButton = [[UIButton alloc] init];
    [imgButton setImage:curImg forState:UIControlStateNormal];
    
    [imgButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [imgButton.layer setShadowOffset:CGSizeMake(0, 3)];
    [imgButton.layer setShadowRadius:5.5f];
    [imgButton.layer setShadowOpacity:0.75f];
    [imgButton.layer setShouldRasterize:YES];
    
    [[imgButton imageView] setContentMode:UIViewContentModeScaleToFill];
    [imgButton setContentMode:UIViewContentModeScaleToFill];
    [imgButton setFrame:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    
    [imgButton addTarget:self action:@selector(showQRCodeWithButton:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect imgFrame = imgButton.frame;
    
    imgFrame.origin.x = (scrollViewSize.width * idx) + pagePadding;
    imgFrame.origin.y = (scrollViewSize.height / 2.0f) - (imgSize.height / 2.0f);
    [imgButton setFrame:imgFrame];
    
    return [imgButton autorelease];
}

- (void)showQRCodeWithButton:(UIButton *)sender
{
    QRCodePresenter *presenter = [[QRCodePresenter alloc] initWithQRCodeImage:[[sender imageView] image]];
    [presenter showFromView:sender];
}


#pragma mark - Action Methods

static int selectedIndex = -1;
- (void)didSelectQRCodeButton:(UIButton *)sender
{
    int cnt = 0;
    for (QACode *barcode in [[QRCodeStorageCenter sharedStorageCenter] barcodes]) {
        if (barcode.storageID == sender.tag) {
            selectedIndex = cnt;
            break;
        }
        cnt++;
    }
    
    CGRect origFrame = [self.view convertRect:[sender frame] fromView:scrollView];
    
    UIImageView *animationTempImage = [[UIImageView alloc] initWithImage:[[sender imageView] image]];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:animationTempImage];
    CGRect newFrame = [[[UIApplication sharedApplication] keyWindow] convertRect:origFrame fromView:self.view];
    [animationTempImage setFrame:newFrame];
    
    [UIView beginAnimations:@"growAnimST1" context:animationTempImage];
    [UIView setAnimationDuration:0.25f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(stage1AnimationComplete:finished:context:)];
    [animationTempImage setTransform:CGAffineTransformMakeScale(1.2f, 1.2f)];
    [UIView commitAnimations];
}

- (void)newBarcode
{
    QACode *newCode = [[QACode alloc] init];
    CreateSelectDesign *createSelect = [[CreateSelectDesign alloc] initWithNibName:@"CreateSelectDesign" bundle:nil];
    [createSelect setExistingCode:newCode];
    [createSelect setEditingDelegate:self];
    [newCode release];
    
    BlueprintNavController *barcodeDesigner = [[BlueprintNavController alloc] initWithRootViewController:createSelect];
    [createSelect release];
    [self presentModalViewController:barcodeDesigner animated:YES];
}

- (IBAction)editButtonAction:(id)sender
{
	CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	UIButton *selectedButton = [qrCodeButtons objectAtIndex:page];
	[self didSelectQRCodeButton:selectedButton];
}

- (IBAction)sendButtonAction:(id)sender
{
    QACode *selectedCode = [self getSelectedQRCode];
    UIImage *codeImage = [selectedCode imageRepresentation];
    NSString *title = [NSString stringWithFormat:@"My QRtist Creation: %@", selectedCode.title];
    
    SHKItem *shareItem = [SHKItem image:codeImage title:title];
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:shareItem];
    [actionSheet showInView:self.view];
}

- (IBAction)exportButtonAction:(id)sender
{
    QACode *selectedCode = [self getSelectedQRCode];
    ExportBarcodeViewController *expvc = [[ExportBarcodeViewController alloc] initWithNibName:@"ExportBarcodeViewController"
                                                                                       bundle:[NSBundle mainBundle]];
    [expvc setBarcode:selectedCode];
    
    [self presentModalViewController:expvc animated:YES];
    [expvc release];
}

- (IBAction)deleteButtonAction:(id)sender
{
	UIActionSheet *deleteSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this QRCode?"
															 delegate:self
													cancelButtonTitle:@"No"
											   destructiveButtonTitle:@"Yes"
													otherButtonTitles:nil];
    [deleteSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	[deleteSheet showInView:self.view];
    [deleteSheet release];
}


#pragma mark - Helper Methods

- (void)setNoBarcodesViewVisible:(BOOL)visible
{
    [barcodeTitleLabel setHidden:visible];
    [noBarcodesView setHidden:!visible];
    [editButton setEnabled:!visible];
    [sendButton setEnabled:!visible];
    [exportButton setEnabled:!visible];
    [deleteButton setEnabled:!visible];
    
    if (!visible && [[QRCodeStorageCenter sharedStorageCenter] barcodesCount] > 1)
        [pageControl setHidden:NO];
    
    NSArray *qrCodes = [[QRCodeStorageCenter sharedStorageCenter] barcodes];
    if (!visible && [qrCodes count] > 0)
        [barcodeTitleLabel setText:[[qrCodes objectAtIndex:0] title]];
}

- (void)repositionQRCodesAfterDeletion:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    int idx = [(NSNumber *)context intValue];
    
    float buttonWidth;
    if ([qrCodeButtons count] > 0)
        buttonWidth = [[qrCodeButtons objectAtIndex:0] frame].size.width;
    else
        buttonWidth = 0;
	float pagePadding = (scrollView.frame.size.width / 2.0) - (buttonWidth / 2.0f);
	
	CGRect buttonFrame;
	for (int i = idx + 1; i < [qrCodeButtons count]; i++) {
		[UIView beginAnimations:@"reposition" context:nil];
		buttonFrame = [[qrCodeButtons objectAtIndex:i] frame];
		buttonFrame.origin.x = buttonFrame.origin.x - buttonWidth - (pagePadding * 2);
		[[qrCodeButtons objectAtIndex:i] setFrame:buttonFrame];
		[UIView commitAnimations];
	}
	
	[scrollView setContentSize:CGSizeMake(scrollView.contentSize.width - (buttonWidth + (pagePadding * 2)), scrollView.contentSize.height)];
	[pageControl setNumberOfPages:[pageControl numberOfPages] - 1];
	
	[qrCodeButtons removeObjectAtIndex:idx];
    
    if ([qrCodeButtons count] == 0)
        [self setNoBarcodesViewVisible:YES];
    if ([qrCodeButtons count] <= 1 && ![pageControl isHidden])
        [pageControl setHidden:YES];

	[self updatePageControl];
}

- (void)deleteQRCodeAtIndex:(int)index
{
    [[QRCodeStorageCenter sharedStorageCenter] deleteBarcodeAtIndex:index];
    
	UIButton *selectedButton = [qrCodeButtons objectAtIndex:index];
	
	[UIView beginAnimations:@"shrinkButton" context:[NSNumber numberWithInt:index]];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(repositionQRCodesAfterDeletion:finished:context:)];
	[selectedButton setTransform:CGAffineTransformMakeScale(0.0001, 0.0001)];
	[UIView commitAnimations];
}

- (void)qrCodeAdded:(NSNotification *)notification
{
    if ([noBarcodesView isHidden])
        [self setNoBarcodesViewVisible:NO];
    
	
    QACode *code = (QACode *) notification.object;
    
    if (![noBarcodesView isHidden])
        [self setNoBarcodesViewVisible:NO];
    
    UIButton *barcodeButton = [self buttonForBarcode:code];
    barcodeButton.tag = code.storageID;
    [qrCodeButtons addObject:barcodeButton];
    [scrollView addSubview:barcodeButton];
    
    CGSize scrollViewSize = scrollView.bounds.size;
    scrollView.contentSize = CGSizeMake(scrollViewSize.width * [qrCodeButtons count],
                                        scrollView.contentSize.height);
    
    if ([qrCodeButtons count] > 1 && [pageControl isHidden]) {
        [pageControl setHidden:NO];
    } else {
        [pageControl setNumberOfPages:[qrCodeButtons count]];
        [pageControl setCurrentPage:[qrCodeButtons count] - 1];
    }
    
    [self movePage:pageControl];
}

- (QACode *)getSelectedQRCode
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page < [qrCodeButtons count]) {
        int storageID = [[qrCodeButtons objectAtIndex:page] tag];
        for (QACode *code in [[QRCodeStorageCenter sharedStorageCenter] barcodes]) {
            if (code.storageID == storageID) {
                return code;
            }
        }
    }
    
    return nil;
}


#pragma mark - Animation Callbacks

- (void)stage1AnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if (selectedIndex < 0)
        return;
    
    NSArray *qrCodes = [[QRCodeStorageCenter sharedStorageCenter] barcodes];
    QACode *code = [qrCodes objectAtIndex:selectedIndex];
    
    BarcodeDetailViewController *barcodeDetail = [[BarcodeDetailViewController alloc] initWithNibName:@"BarcodeDetailViewController" bundle:nil];
    [barcodeDetail setHidePreviewImage:YES];
    [barcodeDetail setBarcode:code];
    [barcodeDetail setEditingDelegate:self];
    
    BlueprintNavController *navController = [[BlueprintNavController alloc] initWithRootViewController:barcodeDetail];
    [barcodeDetail release];
    
    [self presentModalViewController:navController animated:YES];
    [navController release];
    
    [[barcodeDetail scrollView] setUserInteractionEnabled:NO];
    
    UIImageView *prevImage = (UIImageView*)context;
    [[barcodeDetail previewImage] setImage:[prevImage image]];
    
    [UIView beginAnimations:@"shrinkPrev" context:barcodeDetail];
    [UIView setAnimationDelay:0.5f];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(stage2AnimationComplete:finished:context:)];
    [prevImage setTransform:CGAffineTransformIdentity];
    [prevImage setFrame:[[[UIApplication sharedApplication] keyWindow] convertRect:[[barcodeDetail previewImage] frame] fromView:barcodeDetail.view]];
    [UIView commitAnimations];
    
    [prevImage performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.8f];
}

- (void)stage2AnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    BarcodeDetailViewController *bcv = (BarcodeDetailViewController *) context;
    [[bcv scrollView] setUserInteractionEnabled:YES];
    
    [[bcv previewImage] setHidden:NO];
}


#pragma mark - BarcodeEditing Methods

- (void)barcodeFinishedEditing:(QACode *)barcode
{
    [[QRCodeStorageCenter sharedStorageCenter] saveBarcodeChangesToDisk:barcode];
    
    UIButton *button = nil;
    for (int i = 0; i < [qrCodeButtons count]; i++) {
        UIButton *btn = [qrCodeButtons objectAtIndex:i];
        if (btn.tag == barcode.storageID) {
            button = btn;
            break;
        }
    }
    
    if (button != nil)
        [button setImage:[barcode imageRepresentation] forState:UIControlStateNormal];
    
    [self updatePageControl];
}


#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		CGFloat pageWidth = self.scrollView.frame.size.width;
		int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		
		[self deleteQRCodeAtIndex:page];
	}
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    [self updatePageControl];
}


#pragma mark - Memory Management

- (void)dealloc
{
	[qrCodeButtons release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
