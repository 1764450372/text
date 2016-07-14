//
//  TypeCCountViewController.m
//  Order
//
//  Created by mac-sper on 2014/10/21.
//  Copyright (c) 2014年 SPer. All rights reserved.
//

#import "TypeCCountViewController.h"
#import "HomeViewController.h"
#import "OrderEntryViewController.h"
#import "SSGentleAlertView.h"

@interface TypeCCountViewController () <MBProgressHUDDelegate> {
    MBProgressHUD *mbProcess;

    System *sys;
    DataList *dat;
    
    UIButton *bt_common_table;
    UIButton *bt_common_man;
    UIButton *bt_common_woman;
    UIButton *bt_common_child;
    
    UIButton *bt_common_man_down;
    UIButton *bt_common_woman_down;
    UIButton *bt_common_child_down;
    
    NSArray *tableArray;
    
    BOOL directInput;
    BOOL tableInput;
}

@property (weak, nonatomic) IBOutlet UILabel *lb_title;

@property (weak, nonatomic) IBOutlet UIView *entryView_tableOff;
@property (weak, nonatomic) IBOutlet UIButton *bt_man_1;
@property (weak, nonatomic) IBOutlet UIButton *bt_man_down_1;
@property (weak, nonatomic) IBOutlet UIButton *bt_woman_1;
@property (weak, nonatomic) IBOutlet UIButton *bt_woman_down_1;
@property (weak, nonatomic) IBOutlet UIButton *bt_child_1;
@property (weak, nonatomic) IBOutlet UIButton *bt_child_down_1;

@property (weak, nonatomic) IBOutlet UILabel *lb_man_1;
@property (weak, nonatomic) IBOutlet UILabel *lb_woman_1;
@property (weak, nonatomic) IBOutlet UILabel *lb_child_1;
@property (weak, nonatomic) IBOutlet UILabel *lb_count_man_1;
@property (weak, nonatomic) IBOutlet UILabel *lb_count_woman_1;
@property (weak, nonatomic) IBOutlet UILabel *lb_count_child_1;

@property (weak, nonatomic) IBOutlet UIView *entryView_tableOn;
@property (weak, nonatomic) IBOutlet UIButton *bt_table_2;
@property (weak, nonatomic) IBOutlet UIButton *bt_man_2;
@property (weak, nonatomic) IBOutlet UIButton *bt_man_down_2;
@property (weak, nonatomic) IBOutlet UIButton *bt_woman_2;
@property (weak, nonatomic) IBOutlet UIButton *bt_woman_down_2;
@property (weak, nonatomic) IBOutlet UIButton *bt_child_2;
@property (weak, nonatomic) IBOutlet UIButton *bt_child_down_2;

@property (weak, nonatomic) IBOutlet UILabel *lb_table_2;
@property (weak, nonatomic) IBOutlet UILabel *lb_man_2;
@property (weak, nonatomic) IBOutlet UILabel *lb_woman_2;
@property (weak, nonatomic) IBOutlet UILabel *lb_child_2;
@property (weak, nonatomic) IBOutlet UILabel *lb_count_table_2;
@property (weak, nonatomic) IBOutlet UILabel *lb_count_man_2;
@property (weak, nonatomic) IBOutlet UILabel *lb_count_woman_2;
@property (weak, nonatomic) IBOutlet UILabel *lb_count_child_2;


@property (weak, nonatomic) IBOutlet UIButton *bt_return;
@property (weak, nonatomic) IBOutlet UIButton *bt_next;
@property (weak, nonatomic) IBOutlet UIButton *bt_clear;


@property NSInteger man_count;
@property NSInteger woman_count;
@property NSInteger child_count;


- (IBAction)iba_selectInputField:(UIButton *)sender;
- (IBAction)iba_countDown:(UIButton *)sender;

- (IBAction)iba_numeric:(UIButton *)sender;

- (IBAction)iba_clear:(UIButton *)sender;
- (IBAction)iba_back:(UIButton *)sender;

- (IBAction)iba_return:(UIButton *)sender;
- (IBAction)iba_next:(UIButton *)sender;


@end

@implementation TypeCCountViewController

/////////////////////////////////////////////////////////////////
#pragma mark -
/////////////////////////////////////////////////////////////////

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
    // Do any additional setup after loading the view.
    sys = [System sharedInstance];
    dat = [DataList sharedInstance];
    //self.type = TypeOrderOriginal;
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    self.lb_count_table_2.text = @"";
    self.man_count   = dat.manCount;
    self.woman_count = dat.womanCount;
    self.child_count = dat.childCount;
    self.lb_title.text = [String tableNew];
    [self.bt_next setTitle:[String bt_next] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    
    if ([sys.tableType isEqualToString:@"1"]) {
        //テーブルも入力
        tableInput = YES;
    } else {
        tableInput = NO;
    }
    if (self.type == TypeOrderAdd) {
        tableInput = NO;
    }
    
    if (tableInput) {
        //テーブルも入力
        self.lb_title.text = [String tableNew];
        self.entryView_tableOff.hidden = YES;
        bt_common_table = self.bt_table_2;
        bt_common_man   = self.bt_man_2;
        bt_common_woman = self.bt_woman_2;
        bt_common_child = self.bt_child_2;

        bt_common_man_down   = self.bt_man_down_2;
        bt_common_woman_down = self.bt_woman_down_2;
        bt_common_child_down = self.bt_child_down_2;

        bt_common_table.selected = YES;
        bt_common_man.selected   = NO;
        bt_common_woman.selected = NO;
        bt_common_child.selected = NO;
        
        self.lb_table_2.text = [String table];
        self.lb_man_2.text   = [String manTypeC];
        self.lb_woman_2.text = [String womanTypeC];
        self.lb_child_2.text = [String childTypeC];
        
        [self.bt_man_down_2 setTitle:@"" forState:UIControlStateNormal];
        [self.bt_woman_down_2 setTitle:@"" forState:UIControlStateNormal];
        [self.bt_child_down_2 setTitle:@"" forState:UIControlStateNormal];
        self.bt_man_down_2.backgroundColor = [UIColor clearColor];
        self.bt_woman_down_2.backgroundColor = [UIColor clearColor];
        self.bt_child_down_2.backgroundColor = [UIColor clearColor];
        
        [self reloadTableStatus];
    } else {
        //人数だけ入力
        NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *_str = [NSString stringWithFormat:[String tableNo],_no];
        self.lb_title.text = _str;
        self.entryView_tableOn.hidden = YES;
        bt_common_table = self.bt_table_2;
        bt_common_man   = self.bt_man_1;
        bt_common_woman = self.bt_woman_1;
        bt_common_child = self.bt_child_1;
        
        bt_common_man_down   = self.bt_man_down_1;
        bt_common_woman_down = self.bt_woman_down_1;
        bt_common_child_down = self.bt_child_down_1;
        
        bt_common_table.selected = NO;
        bt_common_man.selected   = YES;
        bt_common_woman.selected = NO;
        bt_common_child.selected = NO;
        
        self.lb_man_1.text   = [String manTypeC];
        self.lb_woman_1.text = [String womanTypeC];
        self.lb_child_1.text = [String childTypeC];
        
        [self.bt_man_down_1 setTitle:@"" forState:UIControlStateNormal];
        [self.bt_woman_down_1 setTitle:@"" forState:UIControlStateNormal];
        [self.bt_child_down_1 setTitle:@"" forState:UIControlStateNormal];
        self.bt_man_down_1.backgroundColor = [UIColor clearColor];
        self.bt_woman_down_1.backgroundColor = [UIColor clearColor];
        self.bt_child_down_1.backgroundColor = [UIColor clearColor];
    }
    
    [System adjustStatusBarSpace:self.view];
    [self setBackgroudPng];
    [self dispNumVal];
    //2016-02-03 ueda ASTERISK
    [self.bt_clear setTitle:@"CL" forState:UIControlStateNormal];
    UIImage *img = [UIImage imageNamed:@"ButtonYellow.png"];
    [self.bt_clear setBackgroundImage:img forState:UIControlStateNormal];
    //2016-04-08 ueda ASTERISK
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        //英語
    } else {
        [self.bt_clear.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
        [self.bt_clear setTitle:@"クリア" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier]isEqualToString:@"ToOrderEntryView"]){
        OrderEntryViewController *view_ = (OrderEntryViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/////////////////////////////////////////////////////////////////
#pragma mark - NetWorkManagerDelegate
/////////////////////////////////////////////////////////////////

-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    dispatch_async(dispatch_get_main_queue(), ^{
         switch (type) {
                
            case RequestTypeTableStatus:{//[N11]
                if ([(NSArray*)_dataList count]>0) {
                    tableArray = [[NSMutableArray alloc]initWithArray:(NSArray*)_dataList[0]];
                    //[self.gmGridView reloadData];
                }
                break;
            }
            
            default:
                break;
        }
        
        if (mbProcess) {
            [mbProcess hide:YES];
        }
    });
}

-(void)didFinishReadWithError:(NSError*)_error
                          msg:(NSString*)_msg
                         type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //2014-12-04 ueda
/*
        if (type == RequestTypeTableStatus) {
            //2014-10-30 ueda
            if (([_msg rangeOfString:@"マスターダウンロード"].location != NSNotFound) ||
                ([_msg rangeOfString:@"Execute Master download"].location != NSNotFound)){
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                alert.cancelButtonIndex=0;
                alert.tag = 503;
                [alert show];
            }
            else{
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Table_status_did_not]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                [alert addButtonWithTitle:[String No]];
                alert.cancelButtonIndex=0;
                alert.tag = 502;
                [alert show];
            }
        }
        else{
            NSRange range = [_msg rangeOfString:@"該当する"];
            if (range.location != NSNotFound) {
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[[_msg substringFromIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
            }
            else{
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
            }
        }
 */
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        if (type == RequestTypeTableStatus) {
            alert.delegate=self;
            alert.tag = 502;
        }
        [alert show];
        
        if (mbProcess) {
            [mbProcess hide:YES];
        }
    });
}

/////////////////////////////////////////////////////////////////
#pragma mark - alertView Delegate
/////////////////////////////////////////////////////////////////

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (mbProcess) {
        [mbProcess hide:YES];
    }
    switch (buttonIndex) {
        case 0:
            if(alertView.tag==502){
                //2014-12-04 ueda
                //[self reloadTableStatus];
                [self.navigationController popViewControllerAnimated:YES];
            }
            //2014-12-04 ueda
/*
            else if(alertView.tag==503){
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [parent iba_getMaster:nil];
                [self.navigationController popToViewController:parent animated:YES];
            }
 */
            else if (alertView.tag==701) {
                [self finishEntryCount];
            }
            else if (alertView.tag==501) {
                [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
            }
            break;
            
        case 1:
            //2014-12-04 ueda
/*
            if(alertView.tag==502){
                [self.navigationController popViewControllerAnimated:YES];
            }
 */
            
            break;
    }
}

/////////////////////////////////////////////////////////////////
#pragma mark - MBProgressHUD Delegate
/////////////////////////////////////////////////////////////////

- (void)showIndicator{
    if (!mbProcess) {
        mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
        //2014-10-30 ueda
        //mbProcess.labelText = @"Loading Data";
        [self.view addSubview:mbProcess];
        [mbProcess setDelegate:self];
    }
    [mbProcess show:YES];
}

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [mbProcess removeFromSuperview];
}

/////////////////////////////////////////////////////////////////
#pragma mark - Button Action
/////////////////////////////////////////////////////////////////

- (IBAction)iba_selectInputField:(UIButton *)sender {
    UIButton *button = (UIButton*)sender;
    if (button == bt_common_table) {
        [bt_common_table setSelected:YES];
        [bt_common_man   setSelected:NO];
        [bt_common_woman setSelected:NO];
        [bt_common_child setSelected:NO];
    }
    else if (button == bt_common_man) {
        [bt_common_table setSelected:NO];
        [bt_common_man   setSelected:YES];
        [bt_common_woman setSelected:NO];
        [bt_common_child setSelected:NO];
        self.man_count = MIN(99, self.man_count + 1);
    }
    else if (button == bt_common_woman) {
        [bt_common_table setSelected:NO];
        [bt_common_man   setSelected:NO];
        [bt_common_woman setSelected:YES];
        [bt_common_child setSelected:NO];
        self.woman_count = MIN(99, self.woman_count + 1);
    }
    else if (button == bt_common_child) {
        [bt_common_table setSelected:NO];
        [bt_common_man   setSelected:NO];
        [bt_common_woman setSelected:NO];
        [bt_common_child setSelected:YES];
        self.child_count = MIN(99, self.child_count + 1);
    }
    [self setBackgroudPng];
    [self dispNumVal];
    [System tapSound];
    directInput = NO;
}

- (IBAction)iba_countDown:(UIButton *)sender {
    UIButton *button = (UIButton*)sender;
    if (button == bt_common_man_down) {
        [bt_common_table setSelected:NO];
        [bt_common_man   setSelected:YES];
        [bt_common_woman setSelected:NO];
        [bt_common_child setSelected:NO];
        self.man_count = MAX(0, self.man_count - 1);
    }
    else if (button == bt_common_woman_down) {
        [bt_common_table setSelected:NO];
        [bt_common_man   setSelected:NO];
        [bt_common_woman setSelected:YES];
        [bt_common_child setSelected:NO];
        self.woman_count = MAX(0, self.woman_count - 1);
    }
    else if (button == bt_common_child_down) {
        [bt_common_table setSelected:NO];
        [bt_common_man   setSelected:NO];
        [bt_common_woman setSelected:NO];
        [bt_common_child setSelected:YES];
        self.child_count = MAX(0, self.child_count - 1);
    }
    [self setBackgroudPng];
    [self dispNumVal];
    [System tapSound];
    directInput = NO;
}

- (IBAction)iba_numeric:(UIButton *)sender {
    UIButton *button = (UIButton*)sender;
    NSMutableString *str= [[NSMutableString alloc]init];
    NSInteger max = 0;
    NSInteger count = 0;
    if (bt_common_table.selected){
        [str appendString:self.lb_count_table_2.text];
        [str appendString:[NSString stringWithFormat:@"%zd",button.tag]];
        max = 3;
    }
    else if (bt_common_man.selected) {
        if (directInput) {
            count = self.man_count * 10 + button.tag;
        } else {
            count = 0 + button.tag;
        }
        [str appendString:[NSString stringWithFormat:@"%zd",count]];
        max = 2;
    }
    else if(bt_common_woman.selected){
        if (directInput) {
            count = self.woman_count * 10 + button.tag;
        } else {
            count = 0 + button.tag;
        }
        [str appendString:[NSString stringWithFormat:@"%zd",count]];
        max = 2;
    }
    else if(bt_common_child.selected){
        if (directInput) {
            count = self.child_count * 10 + button.tag;
        } else {
            count = 0 + button.tag;
        }
        [str appendString:[NSString stringWithFormat:@"%zd",count]];
        max = 2;
    }
    if (str.length>max) {
        return;
    }
    if (bt_common_table.selected){
        self.lb_count_table_2.text = str;
    }
    else if (bt_common_man.selected) {
        self.man_count = count;
    }
    else if(bt_common_woman.selected){
        self.woman_count = count;
    }
    else if(bt_common_child.selected){
        self.child_count = count;
    }
    [self dispNumVal];
    directInput = YES;
}

- (IBAction)iba_clear:(UIButton *)sender {
    if (bt_common_table.selected){
        self.lb_count_table_2.text = @"";
    }
    else if (bt_common_man.selected) {
        self.man_count = 0;
    }
    else if(bt_common_woman.selected){
        self.woman_count = 0;
    }
    else if(bt_common_child.selected){
        self.child_count = 0;
    }
    [self dispNumVal];
    directInput = YES;
}

- (IBAction)iba_back:(UIButton *)sender {
    if (bt_common_table.selected){
        NSMutableString *str= [[NSMutableString alloc]init];
        [str appendString:self.lb_count_table_2.text];
        if (str.length==0) {
            return;
        }
        [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
        self.lb_count_table_2.text = str;
    }
    else if (bt_common_man.selected) {
        self.man_count = self.man_count / 10;
    }
    else if(bt_common_woman.selected){
        self.woman_count = self.woman_count / 10;
    }
    else if(bt_common_child.selected){
        self.child_count = self.child_count / 10;
    }
    [self dispNumVal];
    directInput = YES;
}

- (IBAction)iba_return:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)iba_next:(UIButton *)sender {
    if (tableInput) {
        //テーブルも入力
        if ([self.lb_count_table_2.text length]==0) {
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Input_the_table]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=nil;
            [alert addButtonWithTitle:@"OK"];
            alert.cancelButtonIndex=0;
            [alert show];
            return;
        }
        
        BOOL isExistence = NO;
        for (int ct = 0; ct < [tableArray count]; ct++) {
            NSDictionary *dic = tableArray[ct];
            NSString *_no1 = [dic[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *_no2 = [self.lb_count_table_2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([_no1 isEqualToString:_no2]) {
                isExistence = YES;
                dat.selectTable[0] = [NSMutableDictionary dictionaryWithDictionary:dic];
                dat.currentTable = dat.selectTable[0];
                break;
            }
        }
        if (!isExistence) {
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String The_Table_which]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=nil;
            [alert addButtonWithTitle:@"OK"];
            alert.cancelButtonIndex=0;
            [alert show];
            return;
        }
    }
    
    if ([sys.zeronin isEqualToString:@"0"] && (self.man_count + self.woman_count + self.child_count == 0)) {
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String The_number]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=self;
        [alert addButtonWithTitle:[String Yes]];
        [alert addButtonWithTitle:[String No]];
        alert.cancelButtonIndex=0;
        alert.tag = 701;
        [alert show];
        return;
    }
    
    if ([sys.zeronin isEqualToString:@"2"] && (self.man_count + self.woman_count + self.child_count == 0)) {
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Input_the_number]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:[String bt_confirm]];
        alert.cancelButtonIndex=0;
        [alert show];
        return;
    }

    [self finishEntryCount];
}


/////////////////////////////////////////////////////////////////
#pragma mark - Local Method
/////////////////////////////////////////////////////////////////

- (void)setBackgroudPng {
    if (bt_common_table.selected) {
        bt_common_table.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:bt_common_table.bounds]];
    } else {
        bt_common_table.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:bt_common_table.bounds]];
    }
    if (bt_common_man.selected) {
        bt_common_man.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:bt_common_man.bounds]];
    } else {
        bt_common_man.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:bt_common_man.bounds]];
    }
    if (bt_common_woman.selected) {
        bt_common_woman.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:bt_common_woman.bounds]];
    } else {
        bt_common_woman.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:bt_common_woman.bounds]];
    }
    if (bt_common_child.selected) {
        bt_common_child.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:bt_common_child.bounds]];
    } else {
        bt_common_child.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:bt_common_child.bounds]];
    }
}

- (void)dispNumVal {
    if (self.entryView_tableOff.hidden) {
        self.lb_count_man_2.text   = [NSString stringWithFormat:@"%zd",self.man_count];
        self.lb_count_woman_2.text = [NSString stringWithFormat:@"%zd",self.woman_count];
        self.lb_count_child_2.text = [NSString stringWithFormat:@"%zd",self.child_count];
    } else {
        self.lb_count_man_1.text   = [NSString stringWithFormat:@"%zd",self.man_count];
        self.lb_count_woman_1.text = [NSString stringWithFormat:@"%zd",self.woman_count];
        self.lb_count_child_1.text = [NSString stringWithFormat:@"%zd",self.child_count];
    }
}

- (void)reloadTableStatus{
    [self showIndicator];
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net getTableStatus:self];
}

- (void)finishEntryCount{
    
    dat.manCount   = self.man_count;
    dat.womanCount = self.woman_count;
    dat.childCount = self.child_count;
    
    if (tableInput) {
        //テーブルも入力
        dat.currentVoucher = nil;
        
        if ([dat tableCheck:self type:self.type]) {
            [self showIndicator];
        }
        return;
    }
    
    [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
}

@end
