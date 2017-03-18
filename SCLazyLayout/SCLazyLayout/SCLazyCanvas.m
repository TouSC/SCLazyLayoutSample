//
//  SCLazyCanvas.m
//  SCLazyLayout
//
//  Created by git on 2017/3/1.
//  Copyright © 2017年 git. All rights reserved.
//

#import "SCLazyCanvas.h"
#import "UIView+RectHelper.h"
#import "SCLayoutModel.h"

@interface SCLazyCanvas ()

@property (weak, nonatomic) IBOutlet UILabel *title_Label;
@property (weak, nonatomic) IBOutlet UIView *digitBgView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *verButton;
@property (weak, nonatomic) IBOutlet UIButton *horButton;


@end

@implementation SCLazyCanvas
{
    UIButton *dismiss_Button;
    void(^_complete)(BOOL isSave);
    void(^_okComplete)(CGFloat value, SCConstraintType type);
    SCConstraintType constraintType;
}

+ (SCLazyCanvas*)shareInstance
{
    static SCLazyCanvas *instance;
    if (!instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[SCLazyCanvas alloc] init];
        });
    }
    return instance;
}

- (id)init
{
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].firstObject;
    if (self)
    {
        constraintType = SCConstraintUnknow;
        self.title_Label.text = @"";
        for (int i=0; i<13; i++)
        {
            UIButton *digitButton = [[UIButton alloc] initWithFrame:CGRectMake(i * [UIScreen mainScreen].bounds.size.width/13, 0,  [UIScreen mainScreen].bounds.size.width/13, 30)];
            [self.digitBgView addSubview:digitButton];
            [digitButton setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
            if (i>=10)
            {
                [digitButton setTitle:i==10?@".":i==11?@"-":@"D" forState:UIControlStateNormal];
            }
            [digitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [digitButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [digitButton addTarget:self action:@selector(clickDigit:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = [UIColor whiteColor];
        self.hidden = YES;
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)reset
{
    self.digitBgView.hidden = YES;
    self.okButton.enabled = NO;
    self.verButton.hidden = self.horButton.hidden = YES;
    for (int tag=101; tag<=105; tag++)
    {
        UIButton *positionButton = [self.tabView viewWithTag:tag];
        positionButton.selected = NO;
    }
}

- (void)setDigitBoard:(BOOL)isActive
{
    self.digitBgView.hidden = NO;
    self.verButton.hidden = self.horButton.hidden = YES;
    self.okButton.enabled = YES;
}

- (void)addView:(SCLazyView*)lazyView Progress:(void(^)(void))progress Complete:(void(^)(BOOL isSave))complete
{
    _lazyView = lazyView;
    _complete = complete;
    self.hidden = NO;
    [[[UIApplication sharedApplication].delegate window] bringSubviewToFront:self];
    [self addSubview:lazyView];
    [self bringSubviewToFront:dismiss_Button];
    progress();
}
- (IBAction)clickCancel:(id)sender
{
    [self reset];
    _complete(NO);
    self.hidden = YES;
}

- (IBAction)clickDone:(id)sender
{
    if (_viewTitle==nil)
    {
        NSLog(@"error! Please set the uuid of this view");
        return;
    }
    [self reset];
    _complete(YES);
    self.hidden = YES;
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dirPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"SCLazyLayout/%@/",_viewControllerTitle]];
    NSString *savePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",_viewTitle]];
    [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:savePath];
    [fileHandle writeData:[@"[\n" dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary *layoutsInfo = [[NSMutableDictionary alloc] init];
    for (SCLayoutModel *m in _lazyView.layouts)
    {
        NSString *key =[NSString stringWithFormat:@"%d",(int)m.view.tag];
        NSMutableArray *layouts = [[NSMutableArray alloc] initWithArray:layoutsInfo[key]];
        [layouts addObject:m.layoutString];
        [layoutsInfo setObject:layouts forKey:key];
    }
    for (UIView *subview in _lazyView.subviews)
    {
        if (subview.tag==0)
        {
            continue;
        }
        NSDictionary *lazyInfo = @{
                                   @"x":@(subview.x),
                                   @"y":@(subview.y),
                                   @"width":@(subview.width),
                                   @"height":@(subview.height),
                                   @"layout":layoutsInfo[[NSString stringWithFormat:@"%d",(int)subview.tag]]?:@[],
                                   @"tag":@(subview.tag),
                                   };
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:lazyInfo options:NSJSONWritingPrettyPrinted error:&error];
        NSString *errorInfo = [NSString stringWithFormat:@"%@",error.userInfo];
        NSAssert(error==nil, errorInfo);
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:jsonData];
        [fileHandle writeData:[@",\n" dataUsingEncoding:NSUTF8StringEncoding]];
        NSAssert(error==nil, errorInfo);
    }
    [fileHandle writeData:[@"]" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
    self.viewControllerTitle = nil;
    self.viewTitle = nil;
}

- (void)clickDigit:(UIButton*)sender
{
    NSString *digit = _textField.text;
    NSString *operate = sender.titleLabel.text;
    if ([operate isEqualToString:@"-"])
    {
        if ([digit doubleValue]==0)
        {
            return;
        }
        else
        {
            digit = [NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:-[digit doubleValue]]];
            _textField.text = digit;
            return;
        }
    }
    if ([operate isEqualToString:@"D"])
    {
        if (digit.length > 0)
        {
            digit = [digit substringToIndex:digit.length-1];
            _textField.text = digit;
            return;
        }
        else
        {
            return;
        }
    }
    if ([digit rangeOfString:@"."].length && [operate isEqualToString:@"."])
    {
        return;
    }
    if ([digit isEqualToString:@"0"])
    {
        digit = @"";
        if ([operate isEqualToString:@"."])
        {
            digit = @"0";
        }
    }
    digit = [digit stringByAppendingString:operate];
    _textField.text = digit;
}

- (IBAction)clickOk:(id)sender
{
    [self reset];
    _okComplete([self.textField.text floatValue], constraintType);
    _textField.text = @"";
}

- (IBAction)clickVer:(id)sender
{
    constraintType = SCConstraintVertical;
    [self setDigitBoard:YES];
}

- (IBAction)clickHor:(id)sender
{
    constraintType = SCConstraintHorizontal;
    [self setDigitBoard:YES];
}

- (IBAction)clickPosition:(UIButton*)sender {
    SCConstraintPosition position = (SCConstraintPosition)sender.tag;
    if (_delegate && [_delegate respondsToSelector:@selector(SCLazyCanvas:didSelectButton:Position:)])
    {
        [_delegate SCLazyCanvas:self didSelectButton:sender Position:position];
    }
}


- (void)waitForInput:(BOOL)isInner Complete:(void(^)(CGFloat value, SCConstraintType type))complete
{
    _okComplete = complete;
    if (isInner)
    {
        self.digitBgView.hidden = NO;
        self.okButton.enabled = YES;
        constraintType = SCConstraintUnknow;
    }
    else
    {
        self.verButton.hidden = self.horButton.hidden = NO;
    }
}

@end
