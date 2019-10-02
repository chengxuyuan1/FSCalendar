//
//  FSCalendarWeekdayView.m
//  FSCalendar
//
//  Created by dingwenchao on 03/11/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendarWeekdayView.h"
#import "FSCalendar.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarExtensions.h"

@interface FSCalendarWeekdayView()

@property (strong, nonatomic) NSPointerArray *weekdayPointers;
@property (weak  , nonatomic) UIView *contentView;
@property (weak  , nonatomic) FSCalendar *calendar;

- (void)commonInit;

@end

@implementation FSCalendarWeekdayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:contentView];
    _contentView = contentView;
    
    _weekdayPointers = [NSPointerArray weakObjectsPointerArray];
    for (int i = 0; i < 7; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:weekdayLabel];
        [_weekdayPointers addPointer:(__bridge void * _Nullable)(weekdayLabel)];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    // Position Calculation
    NSInteger count = self.weekdayPointers.count;
    size_t size = sizeof(CGFloat)*count;
    CGFloat *widths = malloc(size);
    CGFloat contentWidth = self.contentView.fs_width;
    FSCalendarSliceCake(contentWidth, count, widths);
    
    BOOL opposite = NO;
    if (@available(iOS 9.0, *)) {
        UIUserInterfaceLayoutDirection direction = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.calendar.semanticContentAttribute];
        opposite = (direction == UIUserInterfaceLayoutDirectionRightToLeft);
    }
    CGFloat x = 0;
    for (NSInteger i = 0; i < count; i++) {
        CGFloat width = widths[i];
        NSInteger labelIndex = opposite ? count-1-i : i;
        UILabel *label = [self.weekdayPointers pointerAtIndex:labelIndex];
        label.frame = CGRectMake(x, 0, width, self.contentView.fs_height);
        x = CGRectGetMaxX(label.frame);
    }
    free(widths);
}

- (void)setCalendar:(FSCalendar *)calendar
{
    _calendar = calendar;
    [self configureAppearance];
}

- (NSArray<UILabel *> *)weekdayLabels
{
    return self.weekdayPointers.allObjects;
}

- (void)configureAppearance
{
    BOOL useVeryShortWeekdaySymbols = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    NSArray *weekdaySymbols = useVeryShortWeekdaySymbols ? self.calendar.gregorian.veryShortStandaloneWeekdaySymbols : self.calendar.gregorian.shortStandaloneWeekdaySymbols;
    BOOL useDefaultWeekdayCase = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesDefaultCase;
    
    for (NSInteger i = 0; i < self.weekdayPointers.count; i++) {
        NSInteger index = (i + self.calendar.firstWeekday-1) % 7;
        UILabel *label = [self.weekdayPointers pointerAtIndex:i];
        label.font = self.calendar.appearance.weekdayFont;
        label.textColor = self.calendar.appearance.weekdayTextColor;
        label.text = useDefaultWeekdayCase ? weekdaySymbols[index] : [weekdaySymbols[index] uppercaseString];
        label.layer.borderWidth = 1;
                label.layer.borderColor = [[self colorWithHex:@"#D5D5D5"] CGColor];
    }

}
- (UIColor *)colorWithHex:(NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}
@end
