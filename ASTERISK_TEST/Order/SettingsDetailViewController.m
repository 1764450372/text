//
//  SettingsDetailViewController.m
//  Order
//
//  Created by mac-sper on 2015/06/23.
//  Copyright (c) 2015年 SPer. All rights reserved.
//

#import "SettingsDetailViewController.h"

@interface SettingsDetailViewController () <UITableViewDelegate, UITableViewDataSource> {
    System *sys;
    NSArray *dataSource;
    NSString *keyStr;
    //2015-06-26 ueda
    NSArray *setValue;
}

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@end

@implementation SettingsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sys = [System sharedInstance];
    
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    
    //2016-04-08 ueda
    if (YES) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.text = self.navigationItem.title;
        titleLabel.textColor = [UIColor whiteColor];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel sizeToFit];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.minimumScaleFactor = 0.5f;
        self.navigationItem.titleView = titleLabel;
    }

    BOOL isEnglish;
    if ([sys.lang isEqualToString:@"1"]) {
        isEnglish = YES;
    } else {
        isEnglish = NO;
    }
    switch (self.sectionNo) {
        case 0:
            //0000
            dataSource = @[[String Off3],[String On3]];
            setValue   = @[@"0",         @"1"];
            keyStr = @"demo";
            break;
        case 1:
            //8888
            dataSource = @[[String Off3],[String On3]];
            setValue   = @[@"0",         @"1"];
            keyStr = @"training";
            break;
        case 2:
            //1111
            switch (self.rowNo) {
                case 4:
                    dataSource = @[@"A",@"B",@"C"];
                    setValue   = @[@"0",@"1",@"2"];
                    keyStr = @"entryType";
                    break;
                case 5:
                    dataSource = @[[String Slip_No],[String Details],[String Newes]];
                    setValue   = @[@"0",            @"1",            @"2"];
                    keyStr = @"voucherType";
                    break;
                case 6:
                    dataSource = @[[String Off],[String On]];
                    setValue   = @[@"1",        @"0"];
                    keyStr = @"nonselect";
                    break;
                case 7:
                    dataSource = @[[String Off3],[String On3]];
                    setValue   = @[@"1",         @"0"];
                    keyStr = @"sound";
                    break;
                    
                default:
                    break;
            }
            break;
        case 3:
            //2222
            switch (self.rowNo) {
                case 0:
                    dataSource = @[[String tableMultiSelectOkTitle],[String tableMultiSelectNgTitle]];
                    setValue   = @[@"0",                            @"1"];
                    keyStr = @"tableMultiSelect";
                    break;
                case 1:
                    dataSource = @[[String Off2],[String On2]];
                    setValue   = @[@"1",        @"0"];
                    keyStr = @"printOut1";
                    break;
                case 3:
                    dataSource = @[[String useOrderStatusNotTitle],[String useOrderStatusYesTitle]];
                    setValue   = @[@"0",                           @"1"];
                    keyStr = @"useOrderStatus";
                    break;
                //2015-09-17 ueda
                case 4:
                    dataSource = @[[String useOrderConfirmNotTitle],[String useOrderConfirmYesTitle]];
                    setValue   = @[@"0",                           @"1"];
                    keyStr = @"useOrderConfirm";
                    break;
                    
                default:
                    break;
            }
            break;
        case 4:
            //3333
            switch (self.rowNo) {
                case 0:
                    dataSource = @[[String Select],[String Input]];
                    setValue   = @[@"0",           @"1"];
                    keyStr = @"tableType";
                    break;
                case 1:
                    dataSource = @[[String Off3],[String On3]];
                    setValue   = @[@"0",         @"1"];
                    keyStr = @"codeType";
                    break;
                case 2:
                    dataSource = @[[String Off3],[String On3]];
                    setValue   = @[@"0",         @"1"];
                    keyStr = @"regularCategory";
                    break;
                case 3:
                    dataSource = @[[String Off4],[String Modify],[String QTY]];
                    setValue   = @[@"1",         @"0",           @"2"];
                    keyStr = @"kakucho1Type";
                    break;
                case 4:
                    //dataSource = @[[String Off4],[String SimpleRegi],[String PokeRegi],[String PokeRegiOnly]];
                    if (isEnglish) {
                        dataSource = @[[String Off4],[String SimpleRegi],@"PokeRegi",@"PokeRegi Only"];
                    } else {
                        dataSource = @[[String Off4],[String SimpleRegi],@"ポケレジ", @"ポケレジ 専用"];
                    }
                        setValue   = @[@"0",         @"1",               @"2",       @"3"];
                    keyStr = @"RegisterType";
                    break;
                case 5:
                    dataSource = @[[String PayNormal],[String PayYadokake]];
                    setValue   = @[@"0",              @"1"];
                    keyStr = @"PaymentType";
                    break;
                case 6:
                    dataSource = @[[String Off3],[String On3]];
                    setValue   = @[@"1",         @"0"];
                    keyStr = @"searchType";
                    break;
                case 7:
                    dataSource = @[[String Off3],[String On3]];
                    setValue   = @[@"1",         @"0"];
                    keyStr = @"useBarcode";
                    break;
                 
                default:
                    break;
            }
            break;
        case 5:
            //4444
            switch (self.rowNo) {
                case 0:
                    dataSource = @[[String Off5],[String On5]];
                    setValue   = @[@"1",         @"0"];
                    keyStr = @"menuPatternEnable";
                    break;
                case 3:
                    dataSource = @[[String Off3],[String On3]];
                    setValue   = @[@"0",         @"1"];
                    keyStr = @"childInputOnOff";
                    break;
                case 4:
                    dataSource = @[[String Off3],[String On3]];
                    setValue   = @[@"0",         @"1"];
                    keyStr = @"staffCodeInputOnOff";
                    break;
                case 5:
                    dataSource = @[[String staffCodeKeta2],[String staffCodeKeta6]];
                    setValue   = @[@"0",                   @"1"];
                    keyStr = @"staffCodeKetaKbn";
                    break;
                    
                default:
                    break;
            }
            break;
        case 6:
            //6666
            switch (self.rowNo) {
                case 0:
                    dataSource = @[[String Divide2],[String Divide10]];
                    setValue   = @[@"1",            @"0"];
                    keyStr = @"bunkatsuType";
                    break;
                case 1:
                    dataSource = @[[String Off4],[String VLayer],[String Customer]];
                    setValue   = @[@"1",         @"0",           @"2"];
                    keyStr = @"kakucho2Type";
                    break;
                case 2:
                    dataSource = @[[String Off3],[String On3]];
                    setValue   = @[@"1",         @"0"];
                    keyStr = @"choriType";
                    break;
                    
                default:
                    break;
            }
            break;
        case 7:
            //7777
            switch (self.rowNo) {
                case 0:
                    dataSource = @[[String Off3],[String On3]];
                    setValue   = @[@"1",         @"0"];
                    keyStr = @"transceiver";
                    break;
                    
                default:
                    break;
            }
            break;
        case 8:
            //9999
            switch (self.rowNo) {
                case 0:
                    dataSource = @[[String Japanese],[String English]];
                    setValue   = @[@"0",             @"1"];
                    keyStr = @"lang";
                    break;
                case 1:
                    dataSource = @[[String Yen],[String Dollar]];
                    setValue   = @[@"0",        @"1"];
                    keyStr = @"money";
                    break;
                case 2:
                    dataSource = @[[String typeCseatCaptionAlphabet],[String typeCseatCaptionNumber]];
                    setValue   = @[@"0",                             @"1"];
                    keyStr = @"typeCseatCaptionType";
                    break;
                    
                default:
                    break;
            }
            break;
        case 9:
            //9061
            switch (self.rowNo) {
                case 0:
                    dataSource = @[[String Off3],[String On3]];
                    setValue   = @[@"0",         @"1"];
                    keyStr = @"transitionOnOff";
                    break;
                case 1:
                    dataSource = @[[String Off3],[String On3]];
                    setValue   = @[@"0",         @"1"];
                    keyStr = @"scrollOnOff";
                    break;
                    
                default:
                    break;
            }
            break;
            
        //2015-11-18 ueda ASTERISK_TEST
        case 10:
            switch (self.rowNo) {
                case 0:
                    dataSource = @[@"7",@"8",@"9",@"10"];
                    setValue   = @[@"7",@"8",@"9",@"10"];
                    keyStr = @"categoryCount";
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//////////////////////////////////////////////////////////////
#pragma mark - Settings TableView
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger dataCount;
    
    dataCount = dataSource.count;

    return dataCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = dataSource[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSString *setteingValue = [sys valueForKey:keyStr];
    //2015-06-26 ueda
    NSInteger pointer = [setValue[indexPath.row] integerValue];
    if ([[NSString stringWithFormat:@"%zd", pointer] isEqualToString:setteingValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [System tapSound];
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    //[self.settingsTableView reloadData];
    //[self performSelector:@selector(_deselectTableRow:) withObject:tableView afterDelay:0.2f];
    for (NSInteger index=0; index<[self.settingsTableView numberOfRowsInSection:0]; index++) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == index) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            //2015-06-26 ueda
            NSInteger pointer = [setValue[indexPath.row] integerValue];
            [sys setValue:[NSString stringWithFormat:@"%zd", pointer] forKey:keyStr];
            [sys saveChacheAccount];
        }
    }
    //2015-06-26 ueda
    if (self.sectionNo == 5) {
        //4444
        if (self.rowNo == 5) {
            //担当者コード桁数
            //強制的にダウンロードするように設定
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.getMasterSetFg = 1;
        }
    }
}

@end
