/**
 *  ContactCardViewController.h
 *  QRtist
 *
 *  View controller for selecting a contact card as a data source for the barcode.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *              Charles Magahern <charles.magahern@arizona.edu>
 *              Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "BarcodeDataEditor.h"
#import <AddressBook/AddressBook.h>

@interface ContactCardViewController : BarcodeDataEditor<UITextFieldDelegate> {
    
    UITextField *firstName;
    UITextField *lastName;
    UITextField *emailAddress;
    UITextField *companyName;
    
    ABRecordRef contactRecord;
    UIImageView *contactPhoto;
    UIScrollView *contentScroll;
}

@property (assign) ABRecordRef contactRecord;

@property (nonatomic, retain) IBOutlet UIImageView *contactPhoto;
@property (nonatomic, retain) IBOutlet UIScrollView *contentScroll;
@property (nonatomic, retain) IBOutlet UITextField *firstName;
@property (nonatomic, retain) IBOutlet UITextField *lastName;
@property (nonatomic, retain) IBOutlet UITextField *emailAddress;
@property (nonatomic, retain) IBOutlet UITextField *companyName;

@end
