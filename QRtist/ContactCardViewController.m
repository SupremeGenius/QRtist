/**
 *  ContactCardViewController.m
 *  QRtist
 *
 *  View controller for selecting a contact card as a data source for the barcode.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *              Kevin Geisler <kgeisler@email.arizona.edu>
 *              Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "ContactCardViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ContactCardViewController
@synthesize contentScroll;
@synthesize firstName;
@synthesize lastName;
@synthesize emailAddress;
@synthesize companyName;
@synthesize contactRecord;
@synthesize contactPhoto;

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
    [firstName release];
    [lastName release];
    [emailAddress release];
    [companyName release];
    [contentScroll release];
    [contactPhoto release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)scrollToFirstResponder {
    UITextField *firstResponder = nil;
    for (UIView *subview in [contentScroll subviews]) {
        if ([[subview class] isSubclassOfClass:[UITextField class]]) {
            if ([subview isFirstResponder]) {
                firstResponder = (UITextField*)subview;
                
                break;
            }
        }
    }
    
    [contentScroll scrollRectToVisible:firstResponder.frame animated:YES];
}

- (void)keyboardWillShow {
    //[contentScroll setContentInset:UIEdgeInsetsMake(0, 0, -150, 0)];
    [UIView beginAnimations:@"contentInset" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(scrollToFirstResponder)];
    [contentScroll setFrame:CGRectMake(0, 0, 320, 200)];
    
    [UIView commitAnimations];
}

- (void)restoreContentScroll {
    [contentScroll setFrame:self.view.frame];
}

- (void)keyboardWillHide {
    [UIView beginAnimations:@"contentInset" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(restoreContentScroll)];
    [contentScroll setContentOffset:CGPointMake(0, 0)];
    [UIView commitAnimations];
}

- (void)done {
    NSString *contactString = @"";
    
    if ([[firstName text] length] > 0 && [[lastName text] length] > 0)
        contactString = [contactString stringByAppendingFormat:@"%@ %@\n", [firstName text], [lastName text]];
    if ([[emailAddress text] length] > 0)
        contactString = [contactString stringByAppendingFormat:@"%@\n", [emailAddress text]];
    if ([[companyName text] length] > 0)
        contactString = [contactString stringByAppendingFormat:@"%@\n", [companyName text]];
        
    [self.existingCode setEncodedData:[NSDictionary dictionaryWithObject:contactString forKey:kQADataAlphanumericStringKey]];
    [self.existingCode setContactCardID:ABRecordGetRecordID(contactRecord)];
    [self.existingCode setDataType:QRCodeDataTypeContactCard];
    
    if ([self.delegate conformsToProtocol:@protocol(BarcodeDataEditing)])
        [self.delegate dataEditorDidFinishEditing];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"contact";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blueprint-Blank.png"]]];
    [contentScroll setContentSize:self.view.frame.size];
    [contentScroll setClipsToBounds:NO];
    
    if (existingCode != nil && [existingCode contactCardID] != 0) {
        self.contactRecord = ABAddressBookGetPersonWithRecordID(ABAddressBookCreate(), [existingCode contactCardID]);
    }
    
    NSString *firstNameN = @"";
    NSString *lastNameN = @"";
    NSString *emailAddressN = @"";
    NSString *companyNameN = @"";
    
    firstNameN = (NSString*) ABRecordCopyValue(contactRecord, kABPersonFirstNameProperty);
    lastNameN = (NSString*) ABRecordCopyValue(contactRecord, kABPersonLastNameProperty);
    ABMultiValueRef emails = ABRecordCopyValue(contactRecord, kABPersonEmailProperty);
    
    if (ABMultiValueGetCount(emails) > 0)
        emailAddressN = (NSString*) ABMultiValueCopyValueAtIndex(emails, 0);
    
    companyNameN = (NSString*) ABRecordCopyValue(contactRecord, kABPersonOrganizationProperty);
    
    
    [firstName setText:firstNameN];
    [lastName setText:lastNameN];
    [emailAddress setText:emailAddressN];
    [companyName setText:companyNameN];
    
    CFDataRef contactPhotoData = ABPersonCopyImageData(contactRecord);
    if (contactPhotoData != nil) {
        UIImage *contactImage = [UIImage imageWithData:(NSData*)contactPhotoData];
        [contactPhoto setImage:contactImage];
        CFRelease(contactPhotoData);
    }
    
    [contactPhoto.layer setMasksToBounds:YES];
    [contactPhoto.layer setCornerRadius:5.0f];
    [contactPhoto.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [contactPhoto.layer setShadowRadius:3.0f];
    [contactPhoto.layer setShadowOffset:CGSizeMake(0, 2.0)];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardDidShowNotification object:nil];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:done];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string compare:@"\n"] == 0) {
        [textField resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (void)viewDidUnload
{
    [self setFirstName:nil];
    [self setLastName:nil];
    [self setEmailAddress:nil];
    [self setCompanyName:nil];
    [self setContentScroll:nil];
    [self setContactPhoto:nil];
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
