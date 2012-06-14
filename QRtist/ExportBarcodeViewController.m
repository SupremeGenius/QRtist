/**
 *  ExportBarcodeViewController.h
 *  QRtist
 *
 *  View Controller that manages the barcode export screen.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "ExportBarcodeViewController.h"
#import <QuartzCore/QuartzCore.h>

enum QAExportFormat {
    EXPORT_JPEG,
    EXPORT_PNG,
    EXPORT_PDF
};

@interface ExportBarcodeViewController ()

- (void)showLoadingView;
- (void)exportBarcodeAsFormat:(NSNumber *)format;
- (void)exportDidFinish;

@end


@implementation ExportBarcodeViewController
@synthesize barcode;
@synthesize navigationBar, exportFormatLabel, exportFormatSelectorView, helpLabel, loadingView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.barcode = nil;
    }
    return self;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [(BlueprintNavBar *)self.navigationBar setBgImage:[UIImage imageNamed:@"createNavBar.png"]];
    [navigationBar setNeedsDisplay];
    
    [exportFormatLabel setFont:[UIFont fontWithName:@"Andrew Ward" size:17.0f]];
    
    exportFormatSelectorView.layer.cornerRadius = 10.0f;
    exportFormatSelectorView.layer.borderColor = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3] CGColor];
    exportFormatSelectorView.layer.borderWidth = 0.5f;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Export";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"BlessingsthroughRaindrops" size:19.0f];
    [titleLabel sizeToFit];
    [titleLabel setCenter:CGPointMake(navigationBar.bounds.size.width / 2.0, navigationBar.bounds.size.height / 2.0)];

    self.navigationBar.topItem.titleView = titleLabel;
    [titleLabel release];
}

- (void)viewDidUnload
{
    self.navigationBar = nil;
    self.exportFormatLabel = nil;
    self.exportFormatSelectorView = nil;
    self.helpLabel = nil;
    self.loadingView = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Helper Methods

- (void)showLoadingView
{
    [loadingView setAlpha:0.0f];
    [loadingView setHidden:NO];
    
    [UIView beginAnimations:@"loadingViewFade" context:NULL];
    [UIView setAnimationDuration:0.5f];
    [loadingView setAlpha:1.0f];
    [UIView commitAnimations];
}

- (void)exportBarcodeAsFormat:(NSNumber *)format
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    
    unsigned iformat = [format intValue];
    
    NSString *docspath = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    NSString *filename = [NSString stringWithFormat:@"%@_%d", barcode.title, barcode.storageID];
    NSString *pathSansExtension = [docspath stringByAppendingPathComponent:filename];
    
    UIImage *barcodeImage = [barcode imageRepresentation];
    NSData *imgData = nil;
    NSString *path = nil;
    switch (iformat) {
        case EXPORT_JPEG:
            imgData = UIImageJPEGRepresentation(barcodeImage, 1.0f);
            path = [pathSansExtension stringByAppendingPathExtension:@"jpeg"];
            break;
        case EXPORT_PNG:
            imgData = UIImagePNGRepresentation(barcodeImage);
            path = [pathSansExtension stringByAppendingPathExtension:@"png"];
            break;
        case EXPORT_PDF:
        {
            NSMutableData *pdfData = [[NSMutableData alloc] init];
            CGRect pdfRect = CGRectMake(0, 0, barcodeImage.size.width, barcodeImage.size.height);
            CGContextRef pdfContext;
            
            path = [pathSansExtension stringByAppendingPathExtension:@"pdf"];
            UIGraphicsBeginPDFContextToData(pdfData, pdfRect, nil);
            UIGraphicsBeginPDFPage();
            pdfContext = UIGraphicsGetCurrentContext();
            
            CGContextDrawImage(pdfContext, pdfRect, [barcodeImage CGImage]);
            
            UIGraphicsEndPDFContext();
            
            imgData = [NSData dataWithData:pdfData];
            [pdfData release];
            
            break;
        }
        default:
            break;
    }
    
    if (imgData != nil) {        
        [imgData writeToFile:path options:NSDataWritingAtomic error:nil];
    }
    
    [self exportDidFinish];
    
    
    [pool release];
}

- (void)exportDidFinish
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Action Methods

- (IBAction)cancelButtonAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)jpegButtonAction:(id)sender
{
    [self showLoadingView];
    [NSThread detachNewThreadSelector:@selector(exportBarcodeAsFormat:) toTarget:self withObject:[NSNumber numberWithInt:EXPORT_JPEG]];
}

- (IBAction)pngButtonAction:(id)sender
{
    [self showLoadingView];
    [NSThread detachNewThreadSelector:@selector(exportBarcodeAsFormat:) toTarget:self withObject:[NSNumber numberWithInt:EXPORT_PNG]];
}

- (IBAction)pdfButtonAction:(id)sender
{
    [self showLoadingView];
    [NSThread detachNewThreadSelector:@selector(exportBarcodeAsFormat:) toTarget:self withObject:[NSNumber numberWithInt:EXPORT_PDF]];
}


#pragma mark - Memory Management

- (void)dealloc
{
    if (barcode != nil)
        [barcode release];
    [exportFormatLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
