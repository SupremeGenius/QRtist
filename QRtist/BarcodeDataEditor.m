/**
 *  BarcodeDataEditor.m
 *  QRtist
 *
 *  View controller superclass for all controllers that modify barcode data.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "BarcodeDataEditor.h"
#import "BarcodeDetailViewController.h"
#import "BlueprintNavController.h"


@implementation BarcodeDataEditor
@synthesize existingCode;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.existingCode = nil;
        self.delegate = nil;
    }
    return self;
}

- (void)close
{
    [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Memory Management

- (void)dealloc
{
    if (existingCode)
        [existingCode release];
    if (delegate)
        [delegate release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
