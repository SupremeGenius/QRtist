/**
 *  CustomizeViewController.h
 *  QRtist
 *
 *  View controller for QRCode customization options.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "QACode.h"
#import "CustomizePreviewView.h"

@interface CustomizeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate> {
    QACode *code;
    UITableView *customizeTableView;
    
    CustomizePreviewView *previewView;
    BOOL showingPreviewView;
    BOOL showingChangeColor;
}

@property (nonatomic, retain) QACode *code;
@property (nonatomic, retain) IBOutlet UITableView *customizeTableView;

@end
