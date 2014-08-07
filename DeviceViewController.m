//
//  SwipeableCellTableViewCell.m
//  MyStore
//
//  Created by hala on 8/4/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "SwipeableCellTableViewCell.h"



#pragma mark - Private Declarations
static CGFloat const kBounceValue = 10.0f;


@interface SwipeableCellTableViewCell() <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *button1;
@property (nonatomic, weak) IBOutlet UIButton *button2;
@property (nonatomic, weak) IBOutlet UIView *myContentView;
@property (nonatomic, weak) IBOutlet UILabel *myTextLabel;
- (IBAction)buttonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button3;

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic, assign) CGFloat startingLeftLayoutContstraintConstant;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;
@end

@implementation SwipeableCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
    self.panRecognizer=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panningThisCellLeft:)];
    self.panRecognizer.delegate=self;
    [self.myContentView addGestureRecognizer:self.panRecognizer];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - Buttons Clicked
- (IBAction)buttonClicked:(id)sender {
    if (sender == self.button1) {
        [self.delegate buttonOneActionForItemText:self.itemText];
    } else if (sender == self.button2) {
        [self.delegate buttonTwoActionForItemText:self.itemText];
    } else {
        NSLog(@"Clicked unknown button!");
    }
}
- (void)setItemText:(NSString *)itemText {
    //Update the instance variable
    _itemText = itemText;
    
    //Set the text to the custom label.
    self.myTextLabel.text = _itemText;
}

#pragma mark - Pan Gesture Recoginizer

-(void) panThisCell:(UIPanGestureRecognizer *) recognizer
{
    switch (recognizer.state)
    {
            case UIGestureRecognizerStateBegan:
            {
                self.panStartPoint=[recognizer translationInView:self.myContentView];
                self.startingRightLayoutConstraintConstant=self.contentViewRightConstraint.constant;
                self.startingLeftLayoutContstraintConstant=self.contentViewLeftConstraint.constant;
            }
            break;
            
            case UIGestureRecognizerStateChanged:
            {
                CGPoint currentPoint=[recognizer translationInView:self.myContentView];
                CGFloat deltaX=currentPoint.x - self.panStartPoint.x;
                BOOL panningLeft=NO;
                // determine panning left or right?
                if(currentPoint.x < self.panStartPoint.x){
                    panningLeft=YES;
                }
               
                if(self.startingRightLayoutConstraintConstant == 0){
                    if(!panningLeft){
                        CGFloat constant=MAX(-deltaX,0);
                     // if constant is zero, close the cell completely
                        if(constant == 0){
                           // [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                            // opening the cell from the right;
                            CGFloat leftConstant=MIN(-deltaX, [self leftButtonwidth]);
                            if(leftConstant == [self leftButtonwidth]){
                                [self setConstrainsToShowLeftButton:YES notifyDelegateDidOpen:NO];
                                } else
                                {
                                    self.contentViewLeftConstraint.constant=leftConstant;

                                }
                        }   else{
                            // if not zero, set it to right-hand side constraint.
                            self.contentViewRightConstraint.constant=constant;
                        }
                    }   else{
                       //  if you’re panning right to left, the user is attempting to open the cell. In this case, the constant           will be the lesser of either the negative value of deltaX or the total width of both buttons.
                        CGFloat constant=MIN(-deltaX, [self totalButtonWidth]);
                        //If the target constant is the total width of both buttons, the cell is being opened to the catch point and you should fire the method that handles opening.
                        if(constant == [self totalButtonWidth]){
                            [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                        }   else{
                            //  If the constant is not the total width of both buttons, then set the constant to the right constraint’s constant.
                            self.contentViewRightConstraint.constant=constant;
                        }
                    }
                }
                else {
                    //The cell was at least partially open.
                    CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX; //1
                    if (!panningLeft) {
                        CGFloat constant = MAX(adjustment, 0); //2
                        if (constant == 0) { //3
                            [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO withLeftConstraint:NO];
                            [self setConstrainsToShowLeftButton:YES notifyDelegateDidOpen:NO];
                        } else { //4
                            self.contentViewRightConstraint.constant = constant;
                            self.contentViewLeftConstraint.constant=constant;
                        }
                    } else {
                        CGFloat constant = MIN(adjustment, [self totalButtonWidth]); //5
                        if (constant == [self totalButtonWidth]) { //6
                            [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                        } else { //7
                            self.contentViewRightConstraint.constant = constant;
                        }
                    }
                }
                
                self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant; //8
            

            }
            break;
            
            case UIGestureRecognizerStateEnded:
            if (self.startingRightLayoutConstraintConstant == 0)
            {
                //Cell was opening
                CGFloat halfOfButtonOne = CGRectGetWidth(self.button1.frame) / 2; //2
                if (self.contentViewRightConstraint.constant >= halfOfButtonOne)
                { //3
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                }
                else
                {   //Re-close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES withLeftConstraint:NO];
                }
            }
            else
            {
                //Cell was closing
                CGFloat buttonOnePlusHalfOfButton2 = CGRectGetWidth(self.button1.frame) + (CGRectGetWidth(self.button2.frame) / 2); //4
                if (self.contentViewRightConstraint.constant >= buttonOnePlusHalfOfButton2)
                { //5
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                }
                else
                {
                    //Close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES withLeftConstraint:NO];
                }
            }
                break;
            
            case UIGestureRecognizerStateCancelled:
            if (self.startingRightLayoutConstraintConstant == 0) {
                //Cell was closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES withLeftConstraint:NO];
            } else {
                //Cell was open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
                break;
            
            default:
                break;
    }
}

-(void) panningThisCellLeft:(UIPanGestureRecognizer *) recognizer
{
    switch(recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"Panning began");
            self.panStartPoint=[recognizer translationInView:self.myContentView];
            self.startingLeftLayoutContstraintConstant=self.contentViewLeftConstraint.constant;
 
        }
        break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint currentPoint=[recognizer translationInView:self.myContentView];
            CGFloat deltaX=currentPoint.x - self.panStartPoint.x;
            BOOL panningRight=NO;
            if(currentPoint.x > self.panStartPoint.x){
                panningRight=YES;
            }
            // if the cell is already closed
             if(self.startingLeftLayoutContstraintConstant == 0)
             {
                 // PANNING LEFT
                 if(!panningRight)
                 {
                     CGFloat constant=MIN(-deltaX,[self leftButtonwidth]);
                     if(constant == [self leftButtonwidth])
                     {
                         // close cell completely
                         [self resetLeftConstraintsToZero:YES notifyDelegateDidClose:NO];
                     }
                     else
                     {
                         self.contentViewLeftConstraint.constant=constant;
                         
                     }
                 }
                 //PANNING RIGHT
                 else
                 {
                     CGFloat constant=MAX(-deltaX, 0);
                     if(constant == 0)
                     {
                         //show buttons
                        [self setConstrainsToShowLeftButton:YES notifyDelegateDidOpen:NO];

                     }
                     else
                     {
                         self.contentViewLeftConstraint.constant=constant;
                     }
                 }
             }
            // if the cell initially opened
            else
            {
                CGFloat adjustment = self.startingLeftLayoutContstraintConstant + deltaX;
                // PANNING LEFT
                if(!panningRight)
                {
                    CGFloat constant = MIN(adjustment, [self leftButtonwidth]);
                    if (constant == [self leftButtonwidth]) {
                        //close cell
                        [self resetLeftConstraintsToZero:YES notifyDelegateDidClose:NO];

                    } else {
                        self.contentViewLeftConstraint.constant=constant;
                    }

                }
                //PANNING RIGHT
                else
                {
                    CGFloat constant = MAX(adjustment, 0); //5
                    if (constant == [self leftButtonwidth])
                    {
                        // show buttoon
                        [self setConstrainsToShowLeftButton:YES notifyDelegateDidOpen:NO];
                    }
                    else{
                        self.contentViewLeftConstraint.constant=constant;
                    }
                }
            }
            self.contentViewRightConstraint.constant = -self.contentViewLeftConstraint.constant;

        }
            break;
            
        case UIGestureRecognizerStateEnded:
            
        {  if (self.startingLeftLayoutContstraintConstant == 0)
            {
                //Cell was opening
                CGFloat halfOfButtonOne = CGRectGetWidth(self.button3.frame)/4;
                if (self.contentViewLeftConstraint.constant > halfOfButtonOne)
                {
                  //  [self resetLeftConstraintsToZero:YES notifyDelegateDidClose:YES];
                    [self setConstrainsToShowLeftButton:YES notifyDelegateDidOpen:YES];
                    NSLog(@"You're opening the cell, open all the way");

                }
                else
                {
                    //[self setConstrainsToShowLeftButton:YES notifyDelegateDidOpen:YES];
                    [self resetLeftConstraintsToZero:YES notifyDelegateDidClose:YES];
                }
            }
            else
            {
                //Cell was closing
                CGFloat buttonOnePlusHalfOfButton2 = CGRectGetWidth(self.button3.frame) ;// (CGRectGetWidth(self.button2.frame) / 2);
                if (self.contentViewLeftConstraint.constant >= buttonOnePlusHalfOfButton2)
                {
                    //[self resetLeftConstraintsToZero:YES notifyDelegateDidClose:YES];
                    [self setConstrainsToShowLeftButton:YES notifyDelegateDidOpen:YES];


                }
                else
                {
                   //  [self setConstrainsToShowLeftButton:YES notifyDelegateDidOpen:YES];
                    [self resetLeftConstraintsToZero:YES notifyDelegateDidClose:YES];
                }
            }
        
        }
        
            break;
            
        case UIGestureRecognizerStateCancelled:
            NSLog(@"panning Cancelled");
            
        default:
            break;
    }
}
#pragma mark - Buttons' Width

-(CGFloat) totalButtonWidth
{
    return CGRectGetWidth(self.frame)- CGRectGetMinX(self.button2.frame);
}
-(CGFloat) leftButtonwidth
{
    return CGRectGetMaxX(self.button3.frame);
}
#pragma mark - Constraints
- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing withLeftConstraint:(BOOL) leftConstraint
{
	if(!leftConstraint)
    {
        if (endEditing) {
        [self.delegate cellDidClose:self];
        }
    
    if (self.startingRightLayoutConstraintConstant == 0 &&
        self.contentViewRightConstraint.constant == 0)
        {
        //Already all the way closed, no bounce necessary
        return;
        }
    
        self.contentViewRightConstraint.constant = -kBounceValue;
        self.contentViewLeftConstraint.constant = kBounceValue;
    
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.contentViewRightConstraint.constant = 0;
            self.contentViewLeftConstraint.constant = 0;
        
            [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
                self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            }];
        }];
        }
    
    
}
-(void) resetLeftConstraintsToZero:(BOOL) animated notifyDelegateDidClose:(BOOL)endEditing
{
    if (endEditing) {
        [self.delegate cellDidClose:self];
    }
    
    if(self.startingLeftLayoutContstraintConstant ==0 && self.contentViewLeftConstraint.constant==0)
    {
        NSLog(@"Cell is already closed");
        return;
    }
    
    self.contentViewRightConstraint.constant = kBounceValue;
    self.contentViewLeftConstraint.constant = -kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finshied){
        self.contentViewLeftConstraint.constant=0;
        self.contentViewRightConstraint.constant=0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished)
         {
             self.startingLeftLayoutContstraintConstant=self.contentViewLeftConstraint.constant;
             
         }];
    }];

}

- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    //TODO: Notify delegate.
    if (notifyDelegate) {
        [self.delegate cellDidOpen:self];
    }
    if (self.startingRightLayoutConstraintConstant == [self totalButtonWidth] &&
        self.contentViewRightConstraint.constant == [self totalButtonWidth]) {
        return;
    }
    
    self.contentViewLeftConstraint.constant = -[self totalButtonWidth] - kBounceValue;
    self.contentViewRightConstraint.constant = [self totalButtonWidth] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        
        self.contentViewLeftConstraint.constant = -[self totalButtonWidth];
        self.contentViewRightConstraint.constant = [self totalButtonWidth];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}
-(void) setConstrainsToShowLeftButton:(BOOL) animated notifyDelegateDidOpen:(BOOL) notifyDelegate
{
    if (notifyDelegate) {
        [self.delegate cellDidOpen:self];
    }
    if((self.startingLeftLayoutContstraintConstant == [self leftButtonwidth] &&
        self.contentViewLeftConstraint.constant == [self leftButtonwidth]))
    {
        NSLog(@"Button Alreay Opened");
        return;
        
    }

    // show left button
    NSLog(@"show left button");
    self.contentViewLeftConstraint.constant = [self leftButtonwidth];
    self.contentViewRightConstraint.constant = -[self leftButtonwidth];
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished){
        self.contentViewLeftConstraint.constant = [self leftButtonwidth];
        self.contentViewRightConstraint.constant = -[self leftButtonwidth];
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished){
            self.startingLeftLayoutContstraintConstant=self.contentViewLeftConstraint.constant;

        }];
    }];
}
- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.05;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        //layoutIfNeeded forces the receiver to layout its subviews immediately if required.
        [self layoutIfNeeded];
    } completion:completion];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    //[self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO withLeftConstraint:NO];
    [self resetLeftConstraintsToZero:NO notifyDelegateDidClose:NO];
}

-(void) openCell
{
    //[self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
    [self setConstrainsToShowLeftButton:NO notifyDelegateDidOpen:NO];
}

@end
