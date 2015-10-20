//
//  ItemViewController.m
//  darkblue
//
//  Created by renchunyu on 14-7-7.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "ItemViewController.h"
#import "itemDetailViewController.h"

@interface ItemViewController ()

@end

@implementation ItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [_itemTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.view.backgroundColor=COLOR_BACKGROUND;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(blueRefresh:)
                                                 name:NOTIFICATION_BLUE_CLOSED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(blueRefresh:)
                                                 name:NOTIFICATION_BLUE_CONNECTED
                                               object:nil];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(gotoHomePage)];
    
    _itemTableView=[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _itemTableView.delegate=self;
    _itemTableView.dataSource=self;
    _itemTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_itemTableView];
    //设置4个开关
    _smokingSwith=[[UISwitch alloc] initWithFrame:CGRectMake(250, 10, 60, 40)];
    _smokingSwith.onTintColor=COLOR_YELLOW_NEW;
    //初始化
     _smokingSwith.on = [[S_USER_DEFAULTS objectForKey:F_STILL_SMOKE] boolValue];
    //添加事件
    [_smokingSwith addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
}

-(void)gotoHomePage
{
//    [self saveTheMoney];
    [[self.navigationController.viewControllers objectAtIndex:0]dismissViewControllerAnimated:YES completion:nil];
}
/*
 获取本地数据
 */
- (NSMutableDictionary *)allInfo
{
    return  [LocalStroge sharedInstance].allInfo;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_smokingSwith.isOn) {
        int num[4]={2,7,3,1};
        return num[_itemCount];
    }else
    {
        int num[4]={2,8,3,1};
        return num[_itemCount];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"customCellId";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) { 
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellSeparator"]];
        cell.textLabel.textColor=COLOR_THEME_ONE;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    }
    switch (_itemCount) {
        case 0:
            if (indexPath.row==0)
            {
                cell.textLabel.text=@"Smoke Version";
                cell.detailTextLabel.text = [S_USER_DEFAULTS objectForKey:F_SMOKE_VERSION];
            }
            else if (indexPath.row==1)
            { cell.textLabel.text=@"Firmware Version";
                cell.detailTextLabel.text = [S_USER_DEFAULTS objectForKey:F_FIRMWARE_VERSION];
            }
            break;
        case 1:
            
            if (indexPath.row==0) {
                cell.textLabel.text = @"Still Smoking";
                 [cell addSubview:_smokingSwith];
            }else if (indexPath.row==1)
            {
                cell.textLabel.text=@"Cigarettes Smoked Per Day";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%li", (long)[[S_USER_DEFAULTS objectForKey:F_CIGARETTES_DAY] integerValue]];
            }
            else if (indexPath.row==2)
            { cell.textLabel.text=@"Years Smoking";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%li", (long)[[S_USER_DEFAULTS objectForKey:F_YEARS_SMOKING] integerValue]];
            }else if (indexPath.row==3)
            {
                cell.textLabel.text=@"Price";
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            }
            else if (indexPath.row==4)
            {
                cell.textLabel.text=@"Puffs Remind";
                cell.detailTextLabel.text = [S_USER_DEFAULTS objectForKey:F_PUFFS_REMIND];
            }
            else if (indexPath.row==5)
            {
                cell.textLabel.text=@"Nicotine Level";
                cell.detailTextLabel.text = [S_USER_DEFAULTS objectForKey:F_NICOTINE_LEVEL];
            }
            else if (indexPath.row==6)
            {
                cell.textLabel.text=@"Age";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%li", (long)[[S_USER_DEFAULTS objectForKey:F_AGE] integerValue]];
            }else
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yy-M-d"];
                cell.textLabel.text=@"Non Smoker Since";
                cell.detailTextLabel.text = [formatter stringFromDate:[S_USER_DEFAULTS objectForKey:F_NON_SMOKING]];
            }
            
            break;
        case 2:
                if (indexPath.row==0)
            {
                cell.textLabel.text=@"Terms of Use";

            }else if (indexPath.row==1)
            {
                cell.textLabel.text=@"Privacy Policy";

            }else
            {
                cell.textLabel.text=@"Customer Support";

            }
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_itemCount==2) {
        switch (indexPath.row) {
            case 0:
                //用safari打开使用指南
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[S_USER_DEFAULTS objectForKey:F_TERMS_USE]]];
                return;
                break;
            case 1:
                //用safari打开隐私政策
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[S_USER_DEFAULTS objectForKey:F_PRIVACY_POLICY]]];
                return;
                break;
            case 2:
                //用safari打开客户支持
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[S_USER_DEFAULTS objectForKey:F_CUSTOMER_SUPPORT]]];
                return;
                break;
            default:
                break;
        }
    }
    if ((_itemCount==1)&&(indexPath.row!=0)) {
        UITableViewCell *cell = [_itemTableView cellForRowAtIndexPath:indexPath];
        itemDetailViewController *pickerVC=[[itemDetailViewController alloc] init];
        pickerVC.dateIndex = _dateIndex;
        pickerVC.itemCount=indexPath.row;
        pickerVC.title=cell.textLabel.text;
        [self.navigationController pushViewController:pickerVC animated:YES];
    }
}

-(void)switchAction
{
    //仍在吸烟开关
    [S_USER_DEFAULTS setObject:[NSNumber numberWithBool:_smokingSwith.on] forKey:F_STILL_SMOKE];
    if (!_smokingSwith.on) {
        [S_USER_DEFAULTS setObject:[NSDate date] forKey:F_NON_SMOKING];
    }
    [S_USER_DEFAULTS synchronize];
    [_itemTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveTheMoney];
}

- (void)saveTheMoney
{
    //传统烟的费用
    NSInteger cigsPer = [[S_USER_DEFAULTS objectForKey:F_CIGARETTES_DAY]integerValue];  //支
    float pricePack = [[S_USER_DEFAULTS objectForKey:F_PRICE_PACK]floatValue]/20;
    //电子烟的费用
    float milliliter = [[[S_ALL_SMOKING objectAtIndex:_dateIndex]objectForKey:F_SCHEDULE]count]/300.0;  //ml
    float priceMl = [[S_USER_DEFAULTS objectForKey:F_PRICE_ML]floatValue]/10;
    [[S_ALL_SMOKING objectAtIndex:_dateIndex]setObject:[NSString stringWithFormat:@"%.2f", (cigsPer*pricePack-priceMl*milliliter)] forKey:F_SAVE_MONEY];
}

- (void)blueRefresh:(NSNotification *)notification
{
    [_itemTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
