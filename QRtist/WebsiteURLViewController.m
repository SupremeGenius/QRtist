/**
 *  WebsiteURLViewController.m
 *  QRtist
 *
 *  View controller for entering a website URL as a data source for the barcode.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *              Kevin Geisler <kgeisler@email.arizona.edu>
 *              Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "WebsiteURLViewController.h"


@implementation WebsiteURLViewController
@synthesize contentScroll;
@synthesize urlField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [contentScroll release];
    [urlField release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)done {
    NSString *urlText = [urlField text];
    if ([urlText length] == 0) {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"URL Field is Empty"
                                                        message:@"You must enter some data to be encoded!"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [error show];
        [error release];
    } else {
        [self.existingCode setEncodedData:[NSDictionary dictionaryWithObject:urlText forKey:kQADataAlphanumericStringKey]];
        [self.existingCode setDataType:QRCodeDataTypeURL];
        
        if ([self.delegate conformsToProtocol:@protocol(BarcodeDataEditing)])
            [self.delegate dataEditorDidFinishEditing];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blueprint-Blank.png"]]];
    
    self.title = @"website URL";
    
    [contentScroll setContentSize:self.view.frame.size];
    
    [urlField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:done];
    [done release];
    
    if (existingCode != nil)
        [urlField setText:[[existingCode encodedData] objectForKey:kQADataAlphanumericStringKey]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string compare:@"\n"] == 0) {
        [self done];
        return NO;
    }
    
    return YES;
}

- (void)viewDidUnload
{
    [self setContentScroll:nil];
    [self setUrlField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
