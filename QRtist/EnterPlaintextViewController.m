/**
 *  EnterPlaintextViewController.h
 *  QRtist
 *
 *  View controller for entering plain text as a data source for the barcode.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *              Kevin Geisler <kgeisler@email.arizona.edu>
 *              Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "EnterPlaintextViewController.h"
#import "BarcodeDetailViewController.h"
#import "BlueprintNavController.h"
#import "QACode.h"

@implementation EnterPlaintextViewController
@synthesize contentScroll;
@synthesize textView;

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
    [textView release];
    [contentScroll release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)keyboardWillShow {
    [UIView beginAnimations:@"contentInset" context:nil];
    [contentScroll setContentInset:UIEdgeInsetsMake(0.0, 0.0, 60.0, 0.0)];
    [UIView commitAnimations];
}

- (void)keyboardWillHide {
    [UIView beginAnimations:@"contentInset" context:nil];
    [contentScroll setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [UIView commitAnimations];
}

- (void)done {
    NSString *text = [textView text];
    if ([text length] == 0) {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Text Field is Empty"
                                                        message:@"You must enter some data to be encoded!"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [error show];
        [error release];
    } else {
        [self.existingCode setEncodedData:[NSDictionary dictionaryWithObject:text forKey:kQADataAlphanumericStringKey]];
        [self.existingCode setDataType:QRCodeDataTypePlaintext];
        
        if ([self.delegate conformsToProtocol:@protocol(BarcodeDataEditing)])
            [self.delegate dataEditorDidFinishEditing];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blueprint-Blank.png"]]];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:done];
    [done release];
    
    self.title = @"Plain Text";
    
    [contentScroll setContentSize:self.view.frame.size];
    
    [textView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.existingCode != nil) {
        NSString *str = [[self.existingCode encodedData] objectForKey:kQADataAlphanumericStringKey];
        [textView setText:str];
    }
}

- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setContentScroll:nil];
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
