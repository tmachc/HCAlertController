//
//  HCAlertController.m
//  F2Pool
//
//  Created by 韩冲 on 2018/6/13.
//  Copyright © 2018年 f2pool. All rights reserved.
//

#import "HCAlertController.h"
#import "Masonry.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define WINDOW_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define WINDOW_WIDTH [UIScreen mainScreen].bounds.size.width
#define RGBCOLOR(r,g,b)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]       //RGBA进制颜色值

@interface HCAlertAction ()

@property (nullable, nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) HCAlertActionStyle style;
@property (nonatomic, copy) void (^actionBlock)(HCAlertAction *);

@end

@implementation HCAlertAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)actionWithTitle:(NSString *)title style:(HCAlertActionStyle)style handler:(void (^)(HCAlertAction *))handler
{
    HCAlertAction *aa = [[HCAlertAction alloc] init];
    aa.title = title;
    aa.style = style;
    aa.actionBlock = handler;
    aa.enabled = true;
    return aa;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", [self class]);
}

@end

typedef NS_ENUM(NSInteger, HCAlertDetailStyle) {
    HCAlertDetailStyleDefault = 0,
    HCAlertDetailStyleTextField,
    HCAlertDetailStyleSelect
};

@interface HCAlertController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UILabel *labText;
@property (nonatomic, readwrite) NSArray<HCAlertAction *> *actions;
@property (nonatomic, readwrite) NSArray<UITextField *> *textFields;
@property (nonatomic, assign) HCAlertDetailStyle detailStyle;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation HCAlertController

- (instancetype)init
{
    self = [super init];
    if (self) {
        WS(ws);
        self.view.backgroundColor = [UIColor clearColor];
        self.providesPresentationContextTransitionStyle = true;
        self.definesPresentationContext = true;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.actions = @[];
        self.textFields = @[];
        self.detailStyle = HCAlertDetailStyleDefault;
        self.bgView = ({
            UIView *bg = [[UIView alloc] initWithFrame:self.view.bounds];
            bg.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
            bg.alpha = 0;
            bg;
        });
        self.contentView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 272, 152)];
            view.backgroundColor = [UIColor whiteColor];
            view.center = self.view.center;
            view.alpha = 0;
            view.clipsToBounds = true;
            view.layer.cornerRadius = 5;
            view;
        });
        self.labTitle = ({
            UILabel *lab = [[UILabel alloc] init];
            lab.textColor = RGBCOLOR(53, 116, 250);
            lab.textAlignment = NSTextAlignmentCenter;
            lab.font = [UIFont boldSystemFontOfSize:16];
            lab.numberOfLines = 100;
            lab;
        });
        self.labText = ({
            UILabel *lab = [[UILabel alloc] init];
            lab.textColor = RGBCOLOR(51, 51, 51);
            lab.textAlignment = NSTextAlignmentCenter;
            lab.font = [UIFont systemFontOfSize:14];
            lab.numberOfLines = 100;
            lab;
        });
        [self.view addSubview:self.bgView];
        [self.view addSubview:self.contentView];
        [self.contentView addSubview:self.labTitle];
        [self.contentView addSubview:self.labText];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.mas_equalTo(ws.view);
            make.width.mas_equalTo(272);
            make.height.mas_equalTo(152);
        }];
        [self.labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(16 + 20);
        }];
        [self.labText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.labTitle.mas_bottom);
            make.left.right.mas_equalTo(ws.labTitle);
            make.height.mas_equalTo(16 + 20);
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(HCAlertControllerStyle)preferredStyle
{
    HCAlertController *ac = [[HCAlertController alloc] init];
    ac.labTitle.text = title;
    ac.labText.text = message;
    
    return ac;
}

- (void)addAction:(HCAlertAction *)action
{
    NSMutableArray *marr = [NSMutableArray arrayWithArray:self.actions];
    if (action.style == HCAlertActionStyleCancel) {
//        if (((HCAlertAction *)[marr firstObject]).style == HCAlertActionStyleCancel) {
//            NSLog(@"两个取消了");
//        }
        [marr insertObject:action atIndex:0];
    }
    else {
        [marr addObject:action];
    }
    self.actions = [marr copy];
    for (id obj in self.contentView.subviews) {
        if ([obj isKindOfClass:[UIButton class]]) {
            [obj removeFromSuperview];
        }
    }
    WS(ws);
    if (self.actions.count == 1) {
        UIButton *btn = [self actionButtonWithAction:action];
        btn.tag = 6200;
        [self.contentView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(-0.5);
            make.bottom.mas_equalTo(0.5);
            make.right.mas_equalTo(0.5);
            make.height.mas_equalTo(42);
        }];
    }
    else if (self.actions.count == 2) {
        UIButton *btnL = [self actionButtonWithAction:[self.actions firstObject]];
        UIButton *btnR = [self actionButtonWithAction:[self.actions lastObject]];
        btnL.tag = 6200;
        btnR.tag = 6201;
        [self.contentView addSubview:btnL];
        [self.contentView addSubview:btnR];
        [btnL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(-0.5);
            make.bottom.mas_equalTo(0.5);
            make.width.mas_equalTo(ws.contentView.mas_width).multipliedBy(0.5).mas_offset(1);
            make.height.mas_equalTo(42);
        }];
        [btnR mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0.5);
            make.bottom.mas_equalTo(0.5);
            make.width.mas_equalTo(btnL);
            make.height.mas_equalTo(42);
        }];
    }
    else {
        for (int i = 0; i < self.actions.count; i ++) {
            HCAlertAction *action = self.actions[i];
            UIButton *btn = [self actionButtonWithAction:action];
            btn.tag = 6200 + i;
            [self.contentView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(-0.5);
                make.right.mas_equalTo(0.5);
                make.height.mas_equalTo(42);
                make.bottom.mas_equalTo(0.5 - 41 * i);
            }];
        }
        [self calculateHeight];
    }
}

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler
{
    self.detailStyle = HCAlertDetailStyleTextField;
    UITextField *tf = [self addTextField];
    configurationHandler(tf);
}

// 只调用一次
- (void)addSelectItems:(NSArray *)items defaultIndex:(NSInteger)index
{
    self.items = items;
    self.detailStyle = HCAlertDetailStyleSelect;
    UITextField *tf = [self addTextField];
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miner_coin_arrow"]];
    UIView *tfBg = tf.superview;
    [tfBg addSubview:arrow];
    [self.view addSubview:self.table];
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(tfBg);
        make.width.height.mas_equalTo(7);
        make.right.mas_equalTo(-15);
    }];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tfBg.mas_bottom).mas_offset(0);
        make.left.mas_equalTo(tfBg.mas_left).mas_offset(5);
        make.right.mas_equalTo(tfBg.mas_right).mas_offset(-5);
        make.height.mas_equalTo(0);
    }];
    self.currentIndex = index;
}

#pragma mark - function

//- (UIView *)tfBg
//{
//    if (!_tfBg) {
//        _tfBg = [self tfBgWithFrame:CGRectMake(0, 0, WINDOW_WIDTH - 40 - 30, 34)];
//    }
//    return _tfBg;
//}

//- (UITextField *)tf
//{
//    if (!_tf) {
//        _tf = [[UITextField alloc] init];
//        _tf.font = [UIFont systemFontOfSize:12];
//        _tf.textColor = RGBCOLOR(153, 153, 153);
//        _tf.delegate = self;
//    }
//    return _tf;
//}

- (UIView *)tfBgWithFrame:(CGRect)frame
{
    UIView *blueBg = [[UIView alloc] initWithFrame:frame];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)RGBCOLOR(0, 211, 230).CGColor, (__bridge id)RGBCOLOR(64, 125, 255).CGColor];
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.frame = blueBg.bounds;
    [blueBg.layer addSublayer:gradientLayer];
    blueBg.layer.cornerRadius = 6;
    blueBg.clipsToBounds = true;
    // 白背景
    UIView *whiteBg = [[UIView alloc] initWithFrame:CGRectMake(0.5, 0.5, frame.size.width - 1, frame.size.height - 1)];
    whiteBg.backgroundColor = [UIColor whiteColor];
    whiteBg.layer.cornerRadius = 6;
    [blueBg addSubview:whiteBg];
    return blueBg;
}

- (UITableView *)table
{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _table.dataSource = self;
        _table.delegate = self;
        _table.backgroundColor = [UIColor whiteColor];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.scrollEnabled = false;
        _table.rowHeight = [HCAlertSelectCell cellHeight];
        [_table registerClass:[HCAlertSelectCell class] forCellReuseIdentifier:HCAlertSelectCellID];
    }
    return _table;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    self.textFields.firstObject.text = self.items[self.currentIndex];
    [self.table reloadData];
    [self hideTable];
}

- (UITextField *)addTextField
{
    UIView *tfBg = [self tfBgWithFrame:CGRectMake(0, 0, WINDOW_WIDTH - 40 - 30, 34)];
    UITextField *tf = [[UITextField alloc] init];
    tf.font = [UIFont systemFontOfSize:12];
    tf.textColor = RGBCOLOR(153, 153, 153);
    tf.delegate = self;
    
    NSMutableArray *marr = [NSMutableArray arrayWithArray:self.textFields];
    [marr addObject:tf];
    self.textFields = [marr copy];
    
    [tfBg addSubview:tf];
    [self.contentView addSubview:tfBg];
    WS(ws);
    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.mas_equalTo(tfBg);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
    }];
    [tfBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.labText.mas_bottom).mas_offset(10 + (self.textFields.count - 1) * 44);
        make.left.mas_equalTo(ws.labText);
        make.width.mas_equalTo(WINDOW_WIDTH - 40 - 30);
        make.height.mas_equalTo(34);
    }];
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(WINDOW_WIDTH - 30);
    }];
    [self calculateHeight];
    return tf;
}

- (void)calculateHeight
{
    CGSize size;
    CGSize sizeline = CGSizeMake(self.labText.bounds.size.width, CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:self.labText.font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    size = [self.labText.text boundingRectWithSize:sizeline options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    CGRect rect = self.contentView.frame;
    if (self.detailStyle == HCAlertDetailStyleDefault) {
        [self.labText mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(size.height + 40);
        }];
        rect.size.height = 10 + 36 + (40 + size.height) + 20 + 41;
    }
    else {
        self.labText.textAlignment = NSTextAlignmentLeft;
        [self.labText mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(size.height + 10);
        }];
        rect.size.height = 10 + 36 + (10 + size.height) + 44 * self.textFields.count + 10 + 20 + 41;
    }
    
    if (self.actions.count > 2) {
        rect.size.height += 41 * (self.actions.count - 1);
    }
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(rect.size.height);
    }];
    self.contentView.frame = rect;
}

- (UIButton *)actionButtonWithAction:(HCAlertAction *)action
{
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitle:action.title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.layer.borderColor = RGBCOLOR(217, 217, 217).CGColor;
    btn.layer.borderWidth = 0.5;
    [btn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    if (action.style == HCAlertActionStyleDefault) {
        [btn setTitleColor:RGBCOLOR(53, 116, 250) forState:UIControlStateNormal];
    }
    else if (action.style == HCAlertActionStyleCancel) {
        [btn setTitleColor:RGBCOLOR(102, 102, 102) forState:UIControlStateNormal];
    }
    else {
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    return btn;
}

- (IBAction)clickAction:(UIButton *)sender
{
    HCAlertAction *action = self.actions[sender.tag - 6200];
    if (!action.isEnabled) {
        return;
    }
    if (action.actionBlock) {
        action.actionBlock(action);
    }
    [self dismiss];
}

- (void)showTable
{
    CGRect rect = self.table.frame;
    CGFloat height = (self.items.count > 5 ? 5 : self.items.count) * [HCAlertSelectCell cellHeight];
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.3 animations:^{
            self.table.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height * 0.1);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.4 animations:^{
            self.table.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height * 0.9);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.3 animations:^{
            self.table.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height * 1);
        }];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideTable
{
    CGRect rect = self.table.frame;
    CGFloat height = self.table.frame.size.height;
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.3 animations:^{
            self.table.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height * 0.9);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.4 animations:^{
            self.table.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height * 0.1);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.3 animations:^{
            self.table.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height * 0);
        }];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.detailStyle == HCAlertDetailStyleTextField) {
        return true;
    }
    if (self.detailStyle == HCAlertDetailStyleSelect) {
        [self showTable];
    }
    return false;
}

#pragma mark - 键盘

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(-frame.size.height/2 + 20);
        }];
        [self.view layoutSubviews];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
        }];
        [self.view layoutSubviews];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:true];
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCAlertSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:HCAlertSelectCellID forIndexPath:indexPath];
    [cell setItem:self.items[indexPath.row]];
    if (indexPath.row == self.currentIndex) {
        [cell setSelected];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndex = indexPath.row;
}

#pragma mark - 显示和移除

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.contentView.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1);
    [UIView animateWithDuration:0.17 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.bgView.alpha = 1;
//        self.contentView.alpha = 1;
//        self.contentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateKeyframesWithDuration:0.17 delay:0.1 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.1 animations:^{
            self.contentView.alpha = 0.07;
            self.contentView.layer.transform = CATransform3DMakeScale(1.18, 1.18, 1);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.1 animations:^{
            self.contentView.alpha = 0.15;
            self.contentView.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.7 animations:^{
            self.contentView.alpha = 0.85;
            self.contentView.layer.transform = CATransform3DMakeScale(1.01, 1.01, 1);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
            self.contentView.alpha = 1;
            self.contentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }];
    } completion:^(BOOL finished) {
        if (self.detailStyle == HCAlertDetailStyleTextField) {
            [self.textFields.firstObject becomeFirstResponder];
        }
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.17 animations:^{
        self.bgView.alpha = 0;
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        self.actions = @[]; // self.actions会强持有action，如果action在外面被强持有了，会循环引用。这里主动放弃action，解除循环。
        [self dismissViewControllerAnimated:false completion:^{
            
        }];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    NSLog(@"%@ dealloc", [self class]);
}

@end

@interface HCAlertSelectCell ()

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIImageView *imgSelect;

@end

@implementation HCAlertSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        WS(ws);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.name = [[UILabel alloc] init];
        self.name.textColor = RGBCOLOR(102, 102, 102);
        self.name.textAlignment = NSTextAlignmentLeft;
        self.name.font = [UIFont systemFontOfSize:11];
        self.imgSelect = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miner_check"]];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.imgSelect];
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.mas_equalTo(ws.contentView);
            make.left.mas_equalTo(8);
            make.right.mas_equalTo(-20);
        }];
        [self.imgSelect mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(8);
            make.right.mas_equalTo(-12);
        }];
    }
    return self;
}

- (void)setItem:(NSString *)item
{
    self.name.text = item;
    self.imgSelect.hidden = true;
}

- (void)setSelected
{
    self.imgSelect.hidden = false;
}

+ (CGFloat)cellHeight
{
    return 41;
}

@end
