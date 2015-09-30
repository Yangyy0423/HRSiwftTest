//
//  HRLocationPicker.m
//  HRPlacePicker
//
//  Created by ZhangHeng on 15/8/17.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import "HRLocationPicker.h"
#import "FMDB.h"
#import "HRLocationItem.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

@interface HRLocationPicker()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIPickerView    *picker;
    NSMutableArray  *provinceArray;
    NSMutableArray  *citiesArray;
    NSMutableArray  *districArray;
}
@end


@implementation HRLocationPicker

-(id)init{
    self = [super init];
    if(self){
        [self setFrame:CGRectMake(0, screen_height - screen_width, screen_width, screen_width)];
        self.backgroundColor = [UIColor lightGrayColor];
        [self configPicker];
    }
    
    return self;
}

-(void)configPicker{
    provinceArray   =   [NSMutableArray new];
    citiesArray     =   [NSMutableArray new];
    districArray    =   [NSMutableArray new];
    
    [self configData];
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 60, self.frame.size.width, self.frame.size.height - 60)];
    picker.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    picker.showsSelectionIndicator = YES;
    [picker setDataSource:self];
    [picker setDelegate:self];
    [self addSubview:picker];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(10, 10, 70, 40)];
    [self addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(dismissPicker) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *getAddressButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [getAddressButton setTitle:@"确定" forState:UIControlStateNormal];
    [getAddressButton setFrame:CGRectMake(screen_width - 80, 10, 70, 40)];
    [self addSubview:getAddressButton];
    [getAddressButton addTarget:self action:@selector(confirmSelection) forControlEvents:UIControlEventTouchUpInside];
}

-(void)dismissPicker{
    [self removeFromSuperview];
    [[self dataBase] close];
}

-(void)confirmSelection{
    if(_delegate && [_delegate respondsToSelector:@selector(didSelectLocation:)]){
        NSInteger   proIndex    =   [picker selectedRowInComponent:0];
        NSInteger   cityIndex   =   [picker selectedRowInComponent:1];
        NSInteger   disIndex    =   [picker selectedRowInComponent:2];
        
        HRLocationItem  *province = [provinceArray objectAtIndex:proIndex];
        NSString *address = province.locationName;
        if(citiesArray.count > 0){
            HRLocationItem  *city   =   [citiesArray objectAtIndex:cityIndex];
            address = [address stringByAppendingString:city.locationName];
            if(districArray.count > 0){
                HRLocationItem  *district   =   [districArray objectAtIndex:disIndex];
                address = [address stringByAppendingString:district.locationName];
            }
        }
        
        [_delegate didSelectLocation:address];
    }
}

-(void)configData{
    FMDatabase *db = [self dataBase];
    [db open];
    FMResultSet *rs = [db executeQuery:@"select * from S_Province"];
    while (rs.next) {
        HRLocationItem *item = [HRLocationItem new];
        item.locationName   =   [rs stringForColumn:@"ProvinceName"];
        item.locationId     =   [rs intForColumn:@"ProvinceID"];
        
        [provinceArray addObject:item];
    }
    
    HRLocationItem *item = [provinceArray firstObject];
    FMResultSet *cityItems = [db executeQuery:@"select * from S_City where ProvinceID = ?",@(item.locationId)];
    while (cityItems.next) {
        HRLocationItem *item = [HRLocationItem new];
        item.locationName   =   [cityItems stringForColumn:@"CityName"];
        item.locationId     =   [cityItems intForColumn:@"CityID"];
        item.fatherId       =   [cityItems intForColumn:@"ProvinceID"];
        
        [citiesArray addObject:item];
    }
    
    HRLocationItem  *firstCity = [citiesArray firstObject];
    FMResultSet *result = [db executeQuery:@"select * from S_District where CityID = ?",@(firstCity.locationId)];
    while (result.next) {
        HRLocationItem *item = [HRLocationItem new];
        item.locationName   =   [result stringForColumn:@"DistrictName"];
        item.locationId     =   [result intForColumn:@"DistrictID"];
        item.fatherId       =   [result intForColumn:@"CityID"];
        
        [districArray addObject:item];
    }
    
    [db close];
    [picker reloadAllComponents];
}

//根据省的id获取城市
-(void)getCityDataByProvinceId:(int)provinceID{
    if(citiesArray.count > 0)
        [citiesArray removeAllObjects];
    FMDatabase *db = [self dataBase];
    [db open];
    FMResultSet *cityItems = [db executeQuery:@"select * from S_City where ProvinceID = ?",@(provinceID)];
    while (cityItems.next) {
        HRLocationItem *item = [HRLocationItem new];
        item.locationName   =   [cityItems stringForColumn:@"CityName"];
        item.locationId     =   [cityItems intForColumn:@"CityID"];
        item.fatherId       =   [cityItems intForColumn:@"ProvinceID"];
        
        [citiesArray addObject:item];
    }
    [db close];
}

//根据城市id获取区id
-(void)getDistrictDataByCityId:(int)cityID{
    if(districArray.count > 0)
        [districArray removeAllObjects];
    FMDatabase *db = [self dataBase];
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from S_District where CityID = ?",@(cityID)];
    while (result.next) {
        HRLocationItem *item = [HRLocationItem new];
        item.locationName   =   [result stringForColumn:@"DistrictName"];
        item.locationId     =   [result intForColumn:@"DistrictID"];
        item.fatherId       =   [result intForColumn:@"CityID"];
        
        [districArray addObject:item];
    }
    [db close];
}

-(FMDatabase *)dataBase{
    return [FMDatabase databaseWithPath:[[NSBundle mainBundle] pathForResource:@"location" ofType:@"db"]];
}

#pragma mark- pickerDataSource
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component == 0)
        return provinceArray.count;
    if(component == 1)
        return citiesArray.count;
    else
        return districArray.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return screen_width/3;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.minimumScaleFactor = 8.;
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentLeft];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:17]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    HRLocationItem *currentItem;
    switch (component) {
        case 0:
            currentItem = [provinceArray objectAtIndex:row];
            break;
        case 1:
            currentItem = [citiesArray objectAtIndex:row];
            break;
        case 2:
            currentItem = [districArray objectAtIndex:row];
            break;
        default:
            break;
    }
    
    return currentItem.locationName;
}

#pragma pickerView delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (component) {
        case 0:{
            HRLocationItem *item = [provinceArray objectAtIndex:row];
            [self getCityDataByProvinceId:item.locationId];
            
            HRLocationItem *cityItem = [citiesArray firstObject];
            [self getDistrictDataByCityId:cityItem.locationId];
            
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
        }
            break;
        case 1:{
            HRLocationItem *item = [citiesArray objectAtIndex:row];
            [self getDistrictDataByCityId:item.locationId];
            [pickerView reloadComponent:2];
        }
            break;
        case 2:{
        }
            break;
            
        default:
            break;
    }
}

@end
