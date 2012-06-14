/**
 *  CustomizeChoicesTableViewCell.m
 *  QRtist
 *
 *  Custom chioce table view cell.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *              Kevin Geisler <kgeisler@email.arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "CustomizeChoicesTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomizeChoicesTableViewCell
@synthesize leftView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 293, 52);
        
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custoCell-large.png"]];
        [backgroundImage setBackgroundColor:[UIColor clearColor]];
        
        
        [self setBackgroundView:[[UIView alloc] init]];
        [self.contentView addSubview:backgroundImage];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        leftView = [[UIView alloc] init];
        [leftView setBackgroundColor:[UIColor redColor]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected)
        [backgroundImage setImage:[UIImage imageNamed:@"custoCell-large-selected.png"]];
    else
        [backgroundImage setImage:[UIImage imageNamed:@"custoCell-large.png"]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [[self textLabel] setFrame:CGRectMake(50, self.textLabel.frame.origin.y - 3.0f, self.textLabel.frame.size.width, self.textLabel.frame.size.height)];
    [[self textLabel] setFont:[UIFont fontWithName:@"BlessingsthroughRaindrops" size:18.0f]];
    [[self textLabel] setTextColor:[UIColor whiteColor]];
    [[self textLabel] setShadowColor:[UIColor whiteColor]];
    [[self textLabel] setShadowOffset:CGSizeMake(1.0f, 0.0f)];
    
    
    [leftView setFrame:CGRectMake(10.0f, (self.frame.size.height / 2) - 23.0f, 35.0f, 35.0f)];
    [leftView.layer setMasksToBounds:YES];
    [leftView.layer setCornerRadius:4.0f];
    
    [leftView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [leftView.layer setShadowOffset:CGSizeMake(0, 2.0f)];
    [leftView.layer setShadowOpacity:0.7f];
    [leftView.layer setShadowRadius:1.0f];
    [leftView.layer setRasterizationScale:3.0f];
    [leftView.layer setShouldRasterize:YES];
    
    [self.contentView addSubview:leftView];
    
    
    
    [[self accessoryView] setFrame:CGRectMake(self.accessoryView.frame.origin.x - 3.0f, self.accessoryView.frame.origin.y - 4.0f, self.accessoryView.frame.size.width, self.accessoryView.frame.size.height)];
}

- (void)dealloc
{
    [super dealloc];
}

@end
