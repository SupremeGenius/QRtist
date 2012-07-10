/**
 *  CreateSelectDesign.h
 *  QRtist
 *
 *  View controller for the screen that lets the user pick a data source
 *  for a newly created QRCode.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *              James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "ScrollViewWrapper.h"
#import "QACode.h"
#import "BarcodeDataEditing.h"
#import "BarcodeEditing.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface CreateSelectDesign : UIViewController<UINavigationControllerDelegate,
                                                    UIImagePickerControllerDelegate,
                                                    UIScrollViewDelegate,
                                                    ABPeoplePickerNavigationControllerDelegate,
                                                    BarcodeDataEditing> {
    NSMutableArray *choices;
    UIScrollView *scrollView;
    UILabel *selectedLabel;
    UITextView *descriptionView;
    ScrollViewWrapper *scrollViewWrapper;
    UIPageControl *pageControl;
    
    QACode *existingCode;
    
    ABPeoplePickerNavigationController *peoplePicker;
                                                        
    id<BarcodeDataEditing> delegate;
    id<BarcodeEditing> editingDelegate;
}

@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *selectedLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet ScrollViewWrapper *scrollViewWrapper;

@property (nonatomic, retain) QACode *existingCode;
@property (nonatomic, retain) id<BarcodeDataEditing> delegate;
@property (nonatomic, retain) id<BarcodeEditing> editingDelegate;

@end
