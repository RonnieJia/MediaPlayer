//
//  RJFunctions.m
//  APPFormwork
//
//  Created by 辉贾 on 2016/10/23.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import "RJFunctions.h"
#import "MBProgressHUD.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>


#pragma mark - JSON
void AddObjectForKeyIntoDictionary(id object, id key, NSMutableDictionary *dic)
{
    if (object == nil || key == nil || dic == nil
        || ![dic isKindOfClass:[NSDictionary class]]
        || ([object isKindOfClass:[NSString class]] && [object isEqualToString:@""]))
        return;
    
    [dic setObject:object forKey:key];
}

id ObjForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    if (unserializedJSONDic == nil || key == nil || ![unserializedJSONDic isKindOfClass:[NSDictionary class]])
        return nil;
    
    id obj = [unserializedJSONDic objectForKey:key];
    if (obj == [NSNull null])
        return nil;
    else if ([obj isKindOfClass:[NSString class]] && [obj isEqualToString:@""])
        return nil;
    else
        return obj;
}
NSString* StringForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  @"";
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    return  [NSString stringWithFormat:@"%@",obj];
}
CGFloat FloatForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  0.0;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj floatValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [obj floatValue];
    }
    return  0.0;
}
double DoubleForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  0.0;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj doubleValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [obj doubleValue];
    }
    return  0.0;
}
NSInteger IntForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  0;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj intValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [obj intValue];
    }
    return  0;
}
Boolean BoolForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  NO;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj boolValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [obj boolValue];
    }
    return  NO;
}
UInt64 BigIntForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  0;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj unsignedLongLongValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [obj unsignedLongLongValue];
    }
    return  0;
}

void ignoreInteractionEvents() {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}
void endIgnoneInteractionEvents() {
    [[UIApplication sharedApplication]endIgnoringInteractionEvents];
}

#pragma mark -MD5加密
NSString* EncryptPassword(NSString *str)
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


#pragma mark -是否含有中文
Boolean IsHaveChinese(NSString *str)
{
    for (int i=0; i<str.length; i++) {
        unichar ch = [str characterAtIndex:i];
        if (0x4E00 <= ch  && ch <= 0x9FA5) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -判断是否为空
Boolean IsStringEmptyOrNull(NSString * str)
{
    
    if (!str) {
        // null object
        return true;
    } else {
        
        if (![[str class] isSubclassOfClass:[NSString class]]) {
            
            str=[NSString stringWithFormat:@"%@",str];
        }
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            // empty string
            return true;
        } else if([trimedString isEqualToString:@"null"]){
            // is neither empty nor null
            return true;
        }
        else if([trimedString isEqualToString:@"(null)"]){
            // is neither empty nor null
            return true;
        }else {
            return false;
        }
    }
}

Boolean IsNormalMobileNum(NSString  *userMobileNum){
    if ([userMobileNum length] != 11) {
        return NO;
    }
    
    NSString *regex = @"^([1][34578])\\d{9}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:userMobileNum];
    return YES;
    
}
#pragma mark - 保存用户信息
void UserDefaultSaveBool(NSString *key, BOOL value) {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
BOOL UserDefaultBoolForKey(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

void UserDefaultSaveObj(NSString *key, id obj) {
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
id UserDefaultObjForKey(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

void SaveUser(NSString *uName, NSString *pwd) {
    if (!IsStringEmptyOrNull(uName) && !IsStringEmptyOrNull(pwd)) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:uName forKey:@"rjsave_username"];
        [defaults setObject:pwd forKey:@"rjsave_pwd"];
        [defaults synchronize];
    }
}

void ClearUser() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"rjsave_pwd"];
    [defaults synchronize];
}

BOOL IsSaveUser() {
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"rjsave_username"];
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"rjsave_pwd"];
    if (IsStringEmptyOrNull(userName) || IsStringEmptyOrNull(pwd)) {
        return NO;
    }
    return YES;
}

NSString *GetUserName() {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"rjsave_username"];
}

NSString *GetUserPwd() {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"rjsave_pwd"];
}



void SaveUserLocation(NSString *lat, NSString *lon, NSString *city) {
    if (IsStringEmptyOrNull(lat) || IsStringEmptyOrNull(lon) || IsStringEmptyOrNull(city)) {
        
    } else {
        NSDictionary *dict = @{@"lat":lat, @"lon":lon, @"city":city};
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"user_locatiionInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

void ClearUserLocation() {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_locatiionInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *GetUserLatitude() {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_locatiionInfo"];
    return [dict objectForKey:@"lat"];
}
NSString *GetUserLongtude() {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_locatiionInfo"];
    return [dict objectForKey:@"lon"];
}
NSString *GetUserCity() {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_locatiionInfo"];
    return [dict objectForKey:@"city"];
}

void ShowImportErrorAlertView(NSString *errorString){
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}


#pragma mark -Image TOOL
UIImage* createImageWithColor(UIColor *color)
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

UIColor* colorAddAlpha(UIColor* color,CGFloat alpha)
{
    if (CGColorGetNumberOfComponents([color CGColor]) == 2) {
        const CGFloat *colorComponents = CGColorGetComponents([color CGColor]);
        return [UIColor colorWithRed:colorComponents[0]
                               green:colorComponents[0]
                                blue:colorComponents[0]
                               alpha:alpha];
    }
    else if (CGColorGetNumberOfComponents([color CGColor]) == 4) {
        const CGFloat * colorComponents = CGColorGetComponents([color CGColor]);
        return [UIColor colorWithRed:colorComponents[0]
                               green:colorComponents[1]
                                blue:colorComponents[2]
                               alpha:alpha];
    }
    return color;
}

NSDictionary* colorComponents(UIColor *color) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    AddObjectForKeyIntoDictionary(@(components[0]), @"r", dict);
    AddObjectForKeyIntoDictionary(@(components[1]), @"g", dict);
    AddObjectForKeyIntoDictionary(@(components[2]), @"b", dict);
    AddObjectForKeyIntoDictionary(@(components[3]), @"a", dict);
    return dict;
}

#pragma mark -dateFormat
NSDateFormatter* dateLocalShortStyleFormatter()
{
    NSDateFormatter *dateFormatter = dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    dateFormatter.locale = [NSLocale currentLocale];
    return dateFormatter;
}

#pragma mark -MBProgressHUD
MBProgressHUD* CreateCustomColorHUDOnView(UIView *onView)
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:onView];
    hud.bezelView.color = [UIColor blackColor];
    hud.label.textColor = [UIColor whiteColor];
    return hud;
}

void ShowAutoHideMBProgressHUD(UIView *onView, NSString *labelText)
{
    if (!onView || [labelText length] <= 0)
        return;
    
    MBProgressHUD *hud = CreateCustomColorHUDOnView(onView);
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = labelText;
    hud.label.textColor = [UIColor whiteColor];
    hud.completionBlock = nil;
    [onView addSubview:hud];
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:2.0];
}

void ShowAutoHideMBProgressHUDWithOneSec(UIView *onView, NSString *labelText)
{
    if (!onView || [labelText length] <= 0)
        return;
    
    MBProgressHUD *hud = CreateCustomColorHUDOnView(onView);
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = labelText;
    hud.completionBlock = nil;
    [hud hideAnimated:YES afterDelay:0.3];
    [onView addSubview:hud];
    [hud showAnimated:YES];
}

void ShowIMAutoHideMBProgressHUD(UIView *onView, NSString *labelText)
{
    if (!onView || [labelText length] <= 0)
        return;
    
    MBProgressHUD *hud = CreateCustomColorHUDOnView(onView);
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = labelText;
    hud.completionBlock = nil;
    [onView addSubview:hud];
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:1.0];
}

void WaittingMBProgressHUD(UIView *onView, NSString *labelText)
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:onView];
    if (hud == nil) {
        hud = CreateCustomColorHUDOnView(onView);
    }
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = labelText;
    hud.label.textColor = [UIColor whiteColor];
    hud.completionBlock = nil;
    [onView addSubview:hud];
    [hud showAnimated:YES];
}
void SuccessMBProgressHUD(UIView *onView, NSString *labelText)
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:onView];
    if (hud == nil) {
        return;
    }
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_tips_ok.png"]];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = labelText;
    hud.label.textColor = [UIColor whiteColor];
    hud.completionBlock = nil;
    [onView addSubview:hud];
    [onView bringSubviewToFront:hud];
    [hud hideAnimated:YES afterDelay:1.0];
}

void LongTimeSuccessMBProgressHUD(UIView *onView, NSString *labelText)
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:onView];
    if (hud == nil) {
        return;
    }
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_tips_ok.png"]];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text=nil;
    hud.label.font=[UIFont systemFontOfSize:16.0f];
    hud.detailsLabel.text = labelText;
    hud.completionBlock = nil;
    [onView addSubview:hud];
    [onView bringSubviewToFront:hud];
    [hud hideAnimated:YES afterDelay:2.5];
}

void FailedMBProgressHUD(UIView *onView, NSString *labelText)
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:onView];
    if (hud == nil) {
        return;
    }
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_tips_error.png"]];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = labelText;
    hud.label.textColor = [UIColor whiteColor];
    hud.completionBlock = nil;
    [onView addSubview:hud];
    [onView bringSubviewToFront:hud];
    [hud hideAnimated:YES afterDelay:2.5];
}
void FinishMBProgressHUD(UIView *onView)
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:onView];
    if (hud == nil) {
        return;
    }
    [hud hideAnimated:YES];
}

#pragma mark -url处理

NSString *WebShareURLWithContentOfURL(NSString *urlStr)
{
    NSString *userId=nil;
    //    if (IsStringEmptyOrNull([CurrentUserInformation sharedCurrentUserInfo].userID)) {
    //        userId=@"0";
    //    }
    //    else
    //    {
    //        userId=[CurrentUserInformation sharedCurrentUserInfo].userID;
    //    }
    
    NSString *url;
    NSRange range=[urlStr rangeOfString:@"?"];
    if (range.location==NSNotFound) {
        url = [NSString stringWithFormat:@"%@?uid=%@",urlStr,userId];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@&uid=%@",urlStr,userId];
    }
    
    return url;
}

NSString *webURLEncode(NSString *urlStr) {
    return [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

NSString *webURLDecode(NSString *urlStr) {
    return [urlStr stringByRemovingPercentEncoding];
}

NSString *WebURLWithContentOfURL(NSString *urlStr,NSString *token)
{
    NSString *userId=nil;
    //    if (IsStringEmptyOrNull([CurrentUserInformation sharedCurrentUserInfo].userID)) {
    //        userId=@"0";
    //    }
    //    else
    //    {
    //        userId=[CurrentUserInformation sharedCurrentUserInfo].userID;
    //    }
    
    NSString *url;
    NSRange range=[urlStr rangeOfString:@"?"];
    if (range.location==NSNotFound) {
        url = [NSString stringWithFormat:@"%@?uid=%@",urlStr,userId];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@&uid=%@",urlStr,userId];
    }
    
    return url;
}

#pragma mark -时间函数
NSString *timeShortDesc(double localAddTime)
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:localAddTime];
    
    // 年月日获得
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSCalendarUnitWeekOfYear)
                        fromDate:timeDate];
    
    NSInteger year0 = [comps year];
    NSInteger day0 = [comps day];
    NSInteger weak0 = [comps weekOfYear];
    NSInteger month0=[comps month];
    
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSCalendarUnitWeekOfYear)
                        fromDate:[NSDate date]];
    
    NSInteger year1 = [comps year];
    NSInteger day1 = [comps day];
    NSInteger weak1 = [comps weekOfYear];
    NSInteger month1=[comps month];
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    if (year1 > year0)
    {
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        return [dateformatter stringFromDate:timeDate];
    }
    if(month1 > month0)
    {
        [dateformatter setDateFormat:@"MM-dd HH:mm"];
        return [dateformatter stringFromDate:timeDate];
    }
    NSUInteger day = day1 - day0;
    if (day == 0)
    {
        [dateformatter setDateFormat:@"HH:mm"];
        return [dateformatter stringFromDate:timeDate];
    }
    
    if (day == 1)
    {
        [dateformatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"昨天 %@",[dateformatter stringFromDate:timeDate]];
    }
    if (day == 2)
    {
        [dateformatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"前天 %@",[dateformatter stringFromDate:timeDate]];
    }
    
    //本周
    if (weak0 == weak1) {
        [dateformatter setDateFormat:@"EEEE HH:mm"];
        return [dateformatter stringFromDate:timeDate];
    }
    
    [dateformatter setDateFormat:@"MM-dd HH:mm"];
    return [dateformatter stringFromDate:timeDate];
}


extern BOOL CompareStr(NSString *str1,NSString *str2)
{
    if ([str1 compare:str2] == NSOrderedAscending) {
        
        return YES;
    }
    else {
        
        return NO;
    }}

#pragma mark - 获取url参数
NSDictionary *URLParametersWithURLString(NSString *query){
    
    NSStringEncoding  encoding = NSUTF8StringEncoding;
    
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"?&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0]
                             stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString* value = [[kvPair objectAtIndex:1]
                               stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
    
}

#pragma mark - character 字符数
NSInteger CountOfCharacter(NSString *string)
{
    int i,count = (int)[string length],chinese = 0,ascii = 0;unichar cha;
    for(i = 0;i < count;i++){
        cha=[string characterAtIndex:i];
        if(isascii(cha)){
            ascii++;
        }else{
            chinese += 2;
        }
    }
    if(ascii == 0 && chinese == 0){
        return 0;
    }
    return chinese+ascii;
}


#pragma mark - 时间转换
NSDate * getDateFromString(NSString *time,NSString *formatter)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSDate *destDate= [dateFormatter dateFromString:time];
    return destDate;
}

NSString *getStringFromDate(NSDate *date,NSString *formatter)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSString *string = [dateFormatter stringFromDate:date];
    return string;
}
