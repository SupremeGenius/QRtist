/**
 *  CustomizeChoicesTableViewCell.h
 *  QRtist
 *
 *  Custom chioce table view cell.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *              Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>


@interface CustomizeChoicesTableViewCell : UITableViewCell {
    UIView *leftView;
    
    UIImageView *backgroundImage;
}

@property (nonatomic, retain) UIView *leftView;

@end
