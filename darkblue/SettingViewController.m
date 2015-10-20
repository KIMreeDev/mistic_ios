//
//  SettingViewController.m
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "SettingViewController.h"
#import "ItemViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.delegate = self;
    UIBarButtonItem *leftBarbu = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftBarbu;
    self.view.backgroundColor=[UIColor whiteColor];
    self.title =@"Setting";

    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 65, kScreen_Width, 65)];
    headerView.backgroundColor=COLOR_WHITE_NEW;
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 65)];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.textColor=COLOR_THEME_ONE;
    titleLabel.text=@"SMOKER";
    titleLabel.font=[UIFont systemFontOfSize:36];
    
    [headerView addSubview:titleLabel];
    [self.view addSubview:headerView];

    _settingTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 130, kScreen_Width, kScreen_Height-130) style:UITableViewStylePlain];
    _settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
     _settingTableView.delegate=self;
    _settingTableView.dataSource=self;
    [self.view addSubview:_settingTableView];
}

-(void) back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
    return 4;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    return 60;

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:nil];
        cell.textLabel.textColor=COLOR_THEME_ONE;
        cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellSeparator"]];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
      
  }

        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row==0) {
            cell.textLabel.text=@"My Mistic";
        }if (indexPath.row==1) {
            cell.textLabel.text=@"Smoker Profile";
        }
        if (indexPath.row==2) {
           
             cell.textLabel.text=@"Store";
        }
        if (indexPath.row==3) {
            cell.textLabel.text=@"Clear data";
        }
 
  
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        //打开appStore商店
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[S_USER_DEFAULTS objectForKey:STORE_URL]]];
        return;
    }else if (indexPath.row==3)
    {
        UIAlertView  *clearCacheHint=[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Confirm to clear data?", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Sure", @""), nil];
        clearCacheHint.tag=102;
        [clearCacheHint show];
        return;
    }
    UITableViewCell *cell = [_settingTableView cellForRowAtIndexPath:indexPath];
    ItemViewController *itemVC=[[ItemViewController alloc] init];
    itemVC.dateIndex = _dateIndex;
    [self.navigationController  pushViewController:itemVC animated:YES];
    itemVC.itemCount=indexPath.row;
    itemVC.title=cell.textLabel.text;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==102) {
        //清除缓存
        if (buttonIndex==1) {
            [self clearCache];
        }
    }
}

#pragma -mark  UINavigationControllerDelegate
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    
    
    return _navAnimation;
    
}

#pragma mark  enter subview

-(void)clearCache
{
    
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   , ^{
                       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                   
                       
                       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
          
                       
                       NSLog(@"files :%lu",(unsigned long)[files count]);
                   
                       
                       for (NSString *p in files) {
                           NSError *error;
                           NSString *path = [cachPath stringByAppendingPathComponent:p];
                           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                               [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                           }
                       }
                       
                       [[LocalStroge sharedInstance]deleteAllInfo];
                       [S_USER_DEFAULTS setBool:NO forKey:F_OPENED_SECOND];
                       [S_USER_DEFAULTS synchronize];
                       [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];});
}

-(void)clearCacheSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CLEAR_SAVE object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
