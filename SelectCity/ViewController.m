//
//  ViewController.m
//  SelectCity
//
//  Created by 童星 on 16/8/31.
//  Copyright © 2016年 Personal. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
#import "CityModel.h"
#import "CityManager.h"

/*
 从16位色值获取颜色
 */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
/**
 * 屏幕宽度
 */
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>{
    UIPickerView *pickView;
    
    NSMutableArray *provinceArray;            //存储省份信息array
    NSMutableArray *cityArray;                //存储当前省份下城市信息array
    NSMutableArray *districtArray;            //存储当前城市下地区信息array
    
    CityModel *provinceModel;                 //省份model
    CityModel *cityModel;                     //城市model
    CityModel *districtModel;                 //区model
}

@property (strong, nonatomic) UIView *pickerBgView;

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //初始化数据库，如果已经运行过一次之后需要看到数据库红内容的话可以通过sqliteborwser软件来查看  sqliteborwser下载地址：http://sqlitebrowser.org
    [self initWithCityDatabase];
    [self.view addSubview:self.pickerBgView];
    
    //初始化省份数组
    provinceArray = [[CityManager sharedManager] queryCase:@"SELECT * FROM CITYLIST WHERE PCODE=0;"];
    provinceModel = [provinceArray objectAtIndex:0];
    
    //初始化城市数组  默认北京市下属区县  北京id为11  直辖市city就是非直辖市中的district
    cityArray = [[CityManager sharedManager] queryCase:@"SELECT * FROM CITYLIST WHERE PCODE=11;"];
    cityModel = [cityArray objectAtIndex:0];
    
    //默认省份北京市，由于北京是直辖市不存在省份，所以 省份就是北京市，城市就是北京市下面的区县，区县就为空
    districtArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//初始化数据库
-(void)initWithCityDatabase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"City.db"];
    
    //判断数据库是否存在如果不存在则创建，存在则跳过 确保数据库只创建一次，毕竟写这么多数据需要花费好几秒时间
    if(![[NSFileManager defaultManager] fileExistsAtPath:dbPath]){
        NSError *error;
        NSString *cityText = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"city" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
        NSArray *dataArray = [cityText componentsSeparatedByString:@"\n"];
        for(int i = 0; i < [dataArray count]; i++){
            NSArray *array = [[NSString stringWithFormat:@"%@",[dataArray objectAtIndex:i]] componentsSeparatedByString:@","];
            CityModel *model = [[CityModel alloc] init];
            
            //切记一定要去空格去换行，去空格去换行，去空格去换行，最开始被空格和换行符给坑惨了，一直查不到数据好坑，，
            model.code = [[array objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            model.name = [[array objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            model.level = [[array objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            model.pcode = [[array objectAtIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [[CityManager sharedManager] insertCaseData:model];
        }
    }
}

- (UIView *)pickerBgView {
    if(_pickerBgView == nil) {
        _pickerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 280, ScreenWidth, 280)];
        [_pickerBgView setBackgroundColor:UIColorFromRGB(0xffffff)];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, _pickerBgView.frame.size.width, 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xeeeeee)];
        [_pickerBgView addSubview:lineView];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(_pickerBgView.frame.size.width - 60, 0, 50, 44)];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:22 / 255.0 green:157 / 255.0 blue:237 / 255.0 alpha:1.0f] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(finishSelectAreaAction:) forControlEvents:UIControlEventTouchUpInside];
        [_pickerBgView addSubview:btn];
        [_pickerBgView setHidden:YES];
        
        pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, _pickerBgView.frame.size.width, 236)];
        [pickView setDelegate:self];
        [pickView setDataSource:self];
        pickView.showsSelectionIndicator = YES;
        //默认选中第0行
        [pickView selectRow:0 inComponent:0 animated:NO];
        [pickView selectRow:0 inComponent:1 animated:NO];
        [_pickerBgView addSubview:pickView];
    }
    return _pickerBgView;
}

-(IBAction)selectCtiyAction:(id)sender{
    [self.pickerBgView setHidden:NO];
}

//省市区选择完成点击
- (void)finishSelectAreaAction:(id)sender {
    NSLog(@"完成");
    [self.pickerBgView setHidden:YES];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component == 0){
        return [provinceArray count];
    }
    else if(component == 1){
        return [cityArray count];
    }
    else{
        return [districtArray count];
    }
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return ScreenWidth / 3;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 44;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(component == 0){
        CityModel *model = [provinceArray objectAtIndex:row];
        return model.name;
    }
    else if(component == 1){
        CityModel *model = [cityArray objectAtIndex:row];
        return model.name;
    }
    else{
        CityModel *model = [districtArray objectAtIndex:row];
        return model.name;
    }
}

//自定义每行的样式，比如字数太多换行，字体大小等
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth / 3 - 20 , 44)];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [pickerLabel setNumberOfLines:0];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //选择每列之后立刻通过PCODE查询数据库中的所有数据给下一级的数组，然后刷新下一级的pickerView，每次都要考虑到直辖市的问题，所以要判断是否存在区县，，，
    NSString *SQLString;
    if(component == 0){
        CityModel *model = [provinceArray objectAtIndex:row];
        provinceModel = model;
        SQLString = [NSString stringWithFormat:@"SELECT * FROM CITYLIST WHERE PCODE=%@;",model.code];
        [cityArray removeAllObjects];
        cityArray = [[CityManager sharedManager] queryCase:SQLString];
        [pickView reloadComponent:1];
        [pickView selectRow:0 inComponent:1 animated:YES];
        cityModel = [cityArray objectAtIndex:0];
        
        [districtArray removeAllObjects];
        CityModel *model2 = [cityArray objectAtIndex:0];
        districtArray = [[CityManager sharedManager] queryCase:[NSString stringWithFormat:@"SELECT * FROM CITYLIST WHERE PCODE=%@;",model2.code]];
        [pickView reloadComponent:2];
        if([districtArray count] > 0){
            //选择更改后下一级节点默认选择第0行
            [pickView selectRow:0 inComponent:2 animated:YES];
            districtModel = [districtArray objectAtIndex:0];
        }
        else{
            districtModel = nil;
        }
    }
    else if(component == 1){
        CityModel *model = [cityArray objectAtIndex:row];
        cityModel = model;
        SQLString = [NSString stringWithFormat:@"SELECT * FROM CITYLIST WHERE PCODE=%@;",model.code];
        [districtArray removeAllObjects];
        districtArray = [[CityManager sharedManager] queryCase:SQLString];
        [pickView reloadComponent:2];
        if([districtArray count] > 0){
            //选择更改后下一级节点默认选择第0行
            [pickView selectRow:0 inComponent:2 animated:YES];
            districtModel = [districtArray objectAtIndex:0];
        }
        else{
            districtModel = nil;
        }
    }
    else{
        districtModel = [districtArray objectAtIndex:row];
    }
    
    if(districtModel){
        [self.textField setText:[NSString stringWithFormat:@"%@ %@ %@",provinceModel.name,cityModel.name,districtModel.name]];
    }
    else{
        [self.textField setText:[NSString stringWithFormat:@"%@ %@",provinceModel.name,cityModel.name]];
    }
}

@end
