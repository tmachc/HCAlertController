//
//  HCAlertController.h
//  F2Pool
//
//  Created by 韩冲 on 2018/6/13.
//  Copyright © 2018年 f2pool. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HCAlertControllerStyle) {
    HCAlertControllerStyleActionSheet = 0,
    HCAlertControllerStyleAlert
};

typedef NS_ENUM(NSInteger, HCAlertActionStyle) {
    HCAlertActionStyleDefault = 0,
    HCAlertActionStyleCancel,
    HCAlertActionStyleDestructive
};

@interface HCAlertAction : NSObject

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(HCAlertActionStyle)style handler:(void (^ __nullable)(HCAlertAction *action))handler;

@property (nullable, nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) HCAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

@interface HCAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(HCAlertControllerStyle)preferredStyle;

- (void)addAction:(HCAlertAction *)action;
- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;

// 只调用一次
- (void)addSelectItems:(NSArray *)items defaultIndex:(NSInteger)index;

@property (nonatomic, readonly) NSArray<HCAlertAction *> *actions;
@property (nonatomic, readonly) NSArray<UITextField *> *textFields;

@end

#define HCAlertSelectCellID @"HCAlertSelectCellID"

@interface HCAlertSelectCell : UITableViewCell

- (void)setItem:(NSString *)item;
- (void)setSelected;
+ (CGFloat)cellHeight;

@end
