//
//  SettingsViewController.m
//  Order
//
//  Created by mac-sper on 2015/06/23.
//  Copyright (c) 2015年 SPer. All rights reserved.
//

#import "SettingsViewController.h"
#import "SSGentleAlertView.h"
#import "SettingsDetailViewController.h"
#import "SettingsInputViewController.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource> {
    System *sys;
    NSString *detailTitle;
    NSInteger sectionNo;
    NSInteger rowNo;
}

@property (nonatomic, strong) UITableView *settingsTableView;

@property (nonatomic, strong) NSArray *dataSource0000;
@property (nonatomic, strong) NSArray *dataSource1111;
@property (nonatomic, strong) NSArray *dataSource2222;
@property (nonatomic, strong) NSArray *dataSource3333;
@property (nonatomic, strong) NSArray *dataSource4444;
@property (nonatomic, strong) NSArray *dataSource6666;
@property (nonatomic, strong) NSArray *dataSource7777;
@property (nonatomic, strong) NSArray *dataSource8888;
@property (nonatomic, strong) NSArray *dataSource9999;
@property (nonatomic, strong) NSArray *dataSource9061;
//2015-11-18 ueda ASTERISK_TEST
@property (nonatomic, strong) NSArray *dataSourceASTERISK;
//2016-04-08 ueda
@property (nonatomic, strong) NSArray *dataSourceNotOpeCheck;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sys = [System sharedInstance];
   
    //2015-06-29 ueda
    //ストーリーボードで設定するとiOS8で表示がおかしくなるのでコードで追加する
    //→switchの再利用で？detailTextが表示されないみたい
    CGRect viewFrame = self.view.bounds;
    viewFrame.size.height -= self.navigationController.navigationBar.frame.size.height;
    self.settingsTableView = [[UITableView alloc] initWithFrame:viewFrame style:UITableViewStyleGrouped];
    [[self view] addSubview:self.settingsTableView];
    
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;

    self.dataSource0000 = @[@"1"];
    self.dataSource1111 = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8"];
    self.dataSource2222 = @[@"1", @"2", @"3", @"4", @"5"];
    self.dataSource3333 = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8"];
    self.dataSource4444 = @[@"1", @"2", @"3", @"4", @"5", @"6"];
    self.dataSource6666 = @[@"1", @"2", @"3"];
    self.dataSource7777 = @[@"1", @"2", @"3"];
    self.dataSource8888 = @[@"1"];
    self.dataSource9999 = @[@"1", @"2", @"3"];
    self.dataSource9061 = @[@"1", @"2", @"3"];
    self.dataSourceASTERISK = @[@"1"];
    //2016-04-08 ueda
    self.dataSourceNotOpeCheck = @[@"1", @"2", @"3", @"4", @"5", @"6"];
}

- (void)oldSetteing:(id)sender {
    [System tapSound];
    [self performSegueWithIdentifier:@"ToOldSettingView" sender:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.settingsTableView deselectRowAtIndexPath:[self.settingsTableView indexPathForSelectedRow] animated:YES];
    sys = [System sharedInstance];
    if ([sys.lang isEqualToString:@"1"]) {
        self.title = @"Settings";
    } else {
        self.title = @"設定";
    }
    [self.settingsTableView reloadData];
    self.navigationController.navigationBarHidden = NO;

    //2015-06-26 ueda
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    // get index of the previous ViewContoller
    long previousViewControllerIndex = [viewControllerArray indexOfObject:self] - 1;
    UIViewController *previous;
    if (previousViewControllerIndex >= 0) {
        previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:[String bt_return]
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:nil];
    }
    //2015-07-03 ueda
/*
    //2015-06-26 ueda
    NSString *btnTitle;
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        btnTitle = @"Old Type";
    } else {
        btnTitle = @"旧タイプ";
    }
    UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithTitle:btnTitle
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(oldSetteing:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btn, nil];
 */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier]isEqualToString:@"ToSettingsDetailView"]) {
        SettingsDetailViewController *view_ = (SettingsDetailViewController *)[segue destinationViewController];
        view_.title = detailTitle;
        view_.sectionNo = sectionNo;
        view_.rowNo = rowNo;
    }
    if([[segue identifier]isEqualToString:@"ToSettingsInputView"]) {
        SettingsInputViewController *view_ = (SettingsInputViewController *)[segue destinationViewController];
        view_.title = detailTitle;
        view_.sectionNo = sectionNo;
        view_.rowNo = rowNo;
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //2015-11-18 ueda ASTERISK_TEST
    //return 10;
    //2016-04-08 ueda
    //return 11;
    return 12;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger dataCount;
    
    // テーブルに表示するデータ件数を返す
    switch (section) {
        case 0:
            dataCount = self.dataSource0000.count;
            break;
        case 1:
            dataCount = self.dataSource8888.count;
            break;
        case 2:
            dataCount = self.dataSource1111.count;
            break;
        case 3:
            dataCount = self.dataSource2222.count;
            break;
        case 4:
            dataCount = self.dataSource3333.count;
            break;
        case 5:
            dataCount = self.dataSource4444.count;
            break;
        case 6:
            dataCount = self.dataSource6666.count;
            break;
        case 7:
            dataCount = self.dataSource7777.count;
            break;
        case 8:
            dataCount = self.dataSource9999.count;
            break;
        case 9:
            dataCount = self.dataSource9061.count;
            break;
        //2015-11-18 ueda ASTERISK_TEST
        case 10:
            dataCount = self.dataSourceASTERISK.count;
            break;
        //2016-04-08 ueda
        case 11:
            dataCount = self.dataSourceNotOpeCheck.count;
            break;
        default:
            dataCount = 0;
            break;
    }
    return dataCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellSettings";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = @"";
    cell.accessoryView = nil;
    //2015-06-26 ueda
    if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    BOOL isEnglish;
    if ([sys.lang isEqualToString:@"1"]) {
        isEnglish = YES;
    } else {
        isEnglish = NO;
    }
    NSArray *selectValue;
    UISwitch *sw;

    switch (indexPath.section) {
        case 0:
            //0000
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Learning mode";
                    } else {
                        cell.textLabel.text = @"ラーニングモード";
                    }
//                    selectValue = @[[String Off3],[String On3]];
//                    cell.detailTextLabel.text = selectValue[[sys.demo intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.demo intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 101;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                default:
                    break;
            }
            break;
            
        case 1:
            //8888
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Training mode";
                        selectValue = @[[String Off6],[String On6]];
                    } else {
                        cell.textLabel.text = @"トレーニングモード";
                        selectValue = @[[String Off3],[String On3]];
                    }
//                    cell.detailTextLabel.text = selectValue[[sys.training intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.training intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 102;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                default:
                    break;
            }
            break;
            
        case 2:
            //1111
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Terminal ID";
                    } else {
                        cell.textLabel.text = @"端末ＩＤ";
                    }
                    cell.detailTextLabel.text = sys.tanmatsuID;
                     break;
                case 1:
                    if (isEnglish) {
                        cell.textLabel.text = @"Host IP";
                    } else {
                        cell.textLabel.text = @"ホストＩＰ";
                    }
                    cell.detailTextLabel.text = sys.hostIP;
                    break;
                case 2:
                    if (isEnglish) {
                        cell.textLabel.text = @"Connection Port";
                    } else {
                        cell.textLabel.text = @"接続ポート";
                    }
                    cell.detailTextLabel.text = sys.port;
                    break;
                case 3:
                    if (isEnglish) {
                        cell.textLabel.text = @"Time-out";
                    } else {
                        cell.textLabel.text = @"タイムアウト";
                    }
                    cell.detailTextLabel.text = sys.timeout;
                    break;
                case 4:
                    if (isEnglish) {
                        cell.textLabel.text = @"Entry Type";
                    } else {
                        cell.textLabel.text = @"入力タイプ";
                    }
                    selectValue = @[@"A",@"B",@"C"];
                    cell.detailTextLabel.text = selectValue[[sys.entryType intValue]];
                    break;
                case 5:
                    if (isEnglish) {
                        cell.textLabel.text = @"Slip request type";
                    } else {
                        cell.textLabel.text = @"伝票の要求タイプ";
                    }
                    selectValue = @[[String Slip_No],[String Details],[String Newes]];
                    cell.detailTextLabel.text = selectValue[[sys.voucherType intValue]];
                    break;
                case 6:
                    if (isEnglish) {
                        cell.textLabel.text = @"Non selection menu";
                    } else {
                        cell.textLabel.text = @"ノンセレクト商品";
                    }
                    selectValue = @[[String On],[String Off]];
                    cell.detailTextLabel.text = selectValue[[sys.nonselect intValue]];
                    break;
                case 7:
                    if (isEnglish) {
                        cell.textLabel.text = @"Sound effect";
                    } else {
                        cell.textLabel.text = @"効果音";
                    }
//                    selectValue = @[[String On3],[String Off3]];
//                    cell.detailTextLabel.text = selectValue[[sys.sound intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.sound intValue] == 0);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 103;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                default:
                    break;
            }
            break;
            
        case 3:
            //2222
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Table select";
                    } else {
                        cell.textLabel.text = @"テーブル選択";
                    }
                    selectValue = @[[String tableMultiSelectOkTitle],[String tableMultiSelectNgTitle]];
                    cell.detailTextLabel.text = selectValue[[sys.tableMultiSelect intValue]];
                    break;
                case 1:
                    if (isEnglish) {
                        cell.textLabel.text = @"Checkout slip output";
                    } else {
                        cell.textLabel.text = @"チェック伝票出力先";
                    }
                    selectValue = @[[String On2],[String Off2]];
                    cell.detailTextLabel.text = selectValue[[sys.printOut1 intValue]];
                    break;
                case 2:
                    if (isEnglish) {
                        cell.textLabel.text = @"Printer No.";
                    } else {
                        cell.textLabel.text = @"プリンタ番号";
                    }
                    cell.detailTextLabel.text = sys.printOut2;
                    break;
                case 3:
                    if (isEnglish) {
                        cell.textLabel.text = @"[Confirm] button";
                    } else {
                        cell.textLabel.text = @"【チェック】ボタン";
                    }
                    selectValue = @[[String useOrderStatusNotTitle],[String useOrderStatusYesTitle]];
                    cell.detailTextLabel.text = selectValue[[sys.useOrderStatus intValue]];
                    break;
                //2015-09-17 ueda
                case 4:
                    if (isEnglish) {
                        cell.textLabel.text = @"Confirm screen";
                    } else {
                        cell.textLabel.text = @"オーダー確認画面";
                    }
                    selectValue = @[[String useOrderConfirmNotTitle],[String useOrderConfirmYesTitle]];
                    cell.detailTextLabel.text = selectValue[[sys.useOrderConfirm intValue]];
                    break;
                default:
                    break;
            }
            break;

        case 4:
            //3333
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Table input";
                    } else {
                        cell.textLabel.text = @"テーブル入力";
                    }
                    selectValue = @[[String Select],[String Input]];
                    cell.detailTextLabel.text = selectValue[[sys.tableType intValue]];
                    break;
                case 1:
                    if (isEnglish) {
                        cell.textLabel.text = @"Order code";
                    } else {
                        cell.textLabel.text = @"コード注文";
                    }
//                    selectValue = @[[String Off3],[String On3]];
//                    cell.detailTextLabel.text = selectValue[[sys.codeType intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.codeType intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 104;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 2:
                    if (isEnglish) {
                        cell.textLabel.text = @"Category";
                    } else {
                        cell.textLabel.text = @"カテゴリー移動";
                    }
//                    selectValue = @[[String Off3],[String On3]];
//                    cell.detailTextLabel.text = selectValue[[sys.regularCategory intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.regularCategory intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 105;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 3:
                    if (isEnglish) {
                        cell.textLabel.text = @"Input SP";
                    } else {
                        cell.textLabel.text = @"拡張入力";
                    }
                    selectValue = @[[String Modify],[String Off4],[String QTY]];
                    cell.detailTextLabel.text = selectValue[[sys.kakucho1Type intValue]];
                    break;
                case 4:
                    if (isEnglish) {
                        cell.textLabel.text = @"Register type";
                    } else {
                        cell.textLabel.text = @"レジのタイプ";
                    }
                    //selectValue = @[[String Off4],[String SimpleRegi],[String PokeRegi],[String PokeRegiOnly]];
                    if (isEnglish) {
                        selectValue = @[[String Off4],[String SimpleRegi],@"PokeRegi",@"PokeRegi Only"];
                    } else {
                        selectValue = @[[String Off4],[String SimpleRegi],@"ポケレジ",@"ポケレジ 専用"];
                    }
                    cell.detailTextLabel.text = selectValue[[sys.RegisterType intValue]];
                    break;
                case 5:
                    if (isEnglish) {
                        cell.textLabel.text = @"Register pay";
                    } else {
                        cell.textLabel.text = @"レジの支払";
                    }
                    selectValue = @[[String PayNormal],[String PayYadokake]];
                    cell.detailTextLabel.text = selectValue[[sys.PaymentType intValue]];
                    break;
                case 6:
                    if (isEnglish) {
                        cell.textLabel.text = @"Search key";
                    } else {
                        cell.textLabel.text = @"検索キー";
                    }
//                    selectValue = @[[String On3],[String Off3]];
//                    cell.detailTextLabel.text = selectValue[[sys.searchType intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.searchType intValue] == 0);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 106;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 7:
                    if (isEnglish) {
                        cell.textLabel.text = @"Barcode";
                    } else {
                        cell.textLabel.text = @"バーコード";
                    }
//                    selectValue = @[[String On3],[String Off3]];
//                    cell.detailTextLabel.text = selectValue[[sys.useBarcode intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.useBarcode intValue] == 0);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 107;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                default:
                    break;
            }
            break;
            
        case 5:
            //4444
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Preset menu";
                    } else {
                        cell.textLabel.text = @"メニュー設定";
                    }
//                    selectValue = @[[String On5],[String Off5]];
//                    cell.detailTextLabel.text = selectValue[[sys.menuPatternEnable intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.menuPatternEnable intValue] == 0);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 108;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    if (isEnglish) {
                        cell.textLabel.text = @"Pattern";
                    } else {
                        cell.textLabel.text = @"パターン";
                    }
                    cell.detailTextLabel.text = sys.menuPatternType;
                    break;
                case 2:
                    if (isEnglish) {
                        cell.textLabel.text = @"Section CD";
                    } else {
                        cell.textLabel.text = @"所属コード";
                    }
                    cell.detailTextLabel.text = sys.sectionCD;
                    break;
                case 3:
                    if (isEnglish) {
                        cell.textLabel.text = @"Input child";
                    } else {
                        cell.textLabel.text = @"小人の人数";
                    }
//                    selectValue = @[[String Off3],[String On3]];
//                    cell.detailTextLabel.text = selectValue[[sys.childInputOnOff intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.childInputOnOff intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 109;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 4:
                    if (isEnglish) {
                        cell.textLabel.text = @"Input Staff Code";
                    } else {
                        cell.textLabel.text = @"担当者コード入力";
                    }
//                    selectValue = @[[String Off3],[String On3]];
//                    cell.detailTextLabel.text = selectValue[[sys.staffCodeInputOnOff intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.staffCodeInputOnOff intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 110;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 5:
                    if (isEnglish) {
                        cell.textLabel.text = @"number of staff cord";
                    } else {
                        cell.textLabel.text = @"担当者コード桁数";
                    }
                    selectValue = @[[String staffCodeKeta2],[String staffCodeKeta6]];
                    cell.detailTextLabel.text = selectValue[[sys.staffCodeKetaKbn intValue]];
                    break;
                default:
                    break;
            }
            break;
            
        case 6:
            //6666
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Divide type";
                    } else {
                        cell.textLabel.text = @"分割";
                    }
                    selectValue = @[[String Divide10],[String Divide2]];
                    cell.detailTextLabel.text = selectValue[[sys.bunkatsuType intValue]];
                    break;
                case 1:
                    if (isEnglish) {
                        cell.textLabel.text = @"Input SP 2";
                    } else {
                        cell.textLabel.text = @"拡張入力２";
                    }
                    selectValue = @[[String VLayer],[String Off4],[String Customer]];
                    cell.detailTextLabel.text = selectValue[[sys.kakucho2Type intValue]];
                    break;
                case 2:
                    if (isEnglish) {
                        cell.textLabel.text = @"Cooking instruction";
                    } else {
                        cell.textLabel.text = @"調理指示";
                    }
//                    selectValue = @[[String On3],[String Off3]];
//                    cell.detailTextLabel.text = selectValue[[sys.choriType intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.choriType intValue] == 0);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 111;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                default:
                    break;
            }
            break;
            
        case 7:
            //7777
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Transceiver";
                    } else {
                        cell.textLabel.text = @"トランシーバー";
                    }
//                    selectValue = @[[String On3],[String Off3]];
//                    cell.detailTextLabel.text = selectValue[[sys.transceiver intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.transceiver intValue] == 0);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 112;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    if (isEnglish) {
                        cell.textLabel.text = @"FTP user";
                    } else {
                        cell.textLabel.text = @"FTPユーザー";
                    }
                    cell.detailTextLabel.text = sys.ftp_user;
                    break;
                case 2:
                    if (isEnglish) {
                        cell.textLabel.text = @"FTP password";
                    } else {
                        cell.textLabel.text = @"FTPパスワード";
                    }
                    cell.detailTextLabel.text = sys.ftp_password;
                    break;
                default:
                    break;
            }
            break;
            
        case 8:
            //9999
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Language";
                    } else {
                        cell.textLabel.text = @"言語";
                    }
                    selectValue = @[[String Japanese],[String English]];
                    cell.detailTextLabel.text = selectValue[[sys.lang intValue]];
                    break;
                case 1:
                    if (isEnglish) {
                        cell.textLabel.text = @"Currency";
                    } else {
                        cell.textLabel.text = @"通貨";
                    }
                    selectValue = @[[String Yen],[String Dollar]];
                    cell.detailTextLabel.text = selectValue[[sys.money intValue]];
                    break;
                case 2:
                    if (isEnglish) {
                        cell.textLabel.text = @"Type C seats";
                    } else {
                        cell.textLabel.text = @"Ｃタイプ 席番";
                    }
                    selectValue = @[[String typeCseatCaptionAlphabet],[String typeCseatCaptionNumber]];
                    cell.detailTextLabel.text = selectValue[[sys.typeCseatCaptionType intValue]];
                    break;
                default:
                    break;
            }
            break;
            
        case 9:
            //9061
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Transition effect";
                    } else {
                        cell.textLabel.text = @"トランジション効果";
                    }
//                    selectValue = @[[String Off3],[String On3]];
//                    cell.detailTextLabel.text = selectValue[[sys.transitionOnOff intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.transitionOnOff intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 113;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    if (isEnglish) {
                        cell.textLabel.text = @"Scroll";
                    } else {
                        cell.textLabel.text = @"スクロール";
                    }
//                    selectValue = @[[String Off3],[String On3]];
//                    cell.detailTextLabel.text = selectValue[[sys.scrollOnOff intValue]];
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.scrollOnOff intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 114;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 2:
                    if (isEnglish) {
                        cell.textLabel.text = @"Home image";
                    } else {
                        cell.textLabel.text = @"ホーム画像";
                    }
                    cell.detailTextLabel.text = sys.home_back;
                    break;
                default:
                    break;
            }
            break;

        //2015-11-18 ueda ASTERISK_TEST
        case 10:
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Category count";
                    } else {
                        cell.textLabel.text = @"カテゴリー表示数";
                    }
                    cell.detailTextLabel.text = sys.categoryCount;
                    break;
            }
            break;

        //2016-04-08 ueda
        case 11:
            switch (indexPath.row) {
                case 0:
                    if (isEnglish) {
                        cell.textLabel.text = @"Do not Sleep.";
                    } else {
                        cell.textLabel.text = @"スリープしない";
                    }
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.notSleepOnOff intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 116;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    if (isEnglish) {
                        cell.textLabel.text = @"No Operation Check";
                    } else {
                        cell.textLabel.text = @"無操作警告";
                    }
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.notOpeCheckOnOff intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 117;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 2:
                    if (isEnglish) {
                        cell.textLabel.text = @"No Operation Second (Normal)";
                    } else {
                        cell.textLabel.text = @"無操作秒数（通常時）";
                    }
                    cell.detailTextLabel.text = sys.notOpeCheckSecNormal;
                    break;
                case 3:
                    if (isEnglish) {
                        cell.textLabel.text = @"No Operation Second (Alert)";
                    } else {
                        cell.textLabel.text = @"無操作秒数（アラート表示時）";
                    }
                    cell.detailTextLabel.text = sys.notOpeCheckSecAlert;
                    break;
                case 4:
                    if (isEnglish) {
                        cell.textLabel.text = @"No Operation Sound";
                    } else {
                        cell.textLabel.text = @"無操作警告音";
                    }
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.notOpeCheckSound intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 118;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 5:
                    if (isEnglish) {
                        cell.textLabel.text = @"No Operation Vib. (Only iPhone) ";
                    } else {
                        cell.textLabel.text = @"無操作警告バイブ（iPhoneのみ）";
                    }
                    sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.on = ([sys.notOpeCheckVib intValue] == 1);
                    [sw addTarget:self action:@selector(tapSwich:) forControlEvents:UIControlEventTouchUpInside];
                    sw.tag = 119;
                    cell.accessoryView = sw;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    //2016-04-08 ueda
    [cell.textLabel setFont:[UIFont systemFontOfSize:17]];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5f;

    return cell;
}

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell*cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([[cell.accessoryView class] isSubclassOfClass:[UISwitch class]]) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [System tapSound];
    sectionNo = indexPath.section;
    rowNo = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowNo inSection:sectionNo]];
    detailTitle = cell.textLabel.text;
    
    BOOL isInput = NO;
    switch (sectionNo) {
        case 2:
            //1111
            if ((rowNo >= 0) && (rowNo <= 3)) {
                isInput = YES;
            }
            break;
        case 3:
            //2222
            if (rowNo == 2) {
                isInput = YES;
            }
            break;
        case 5:
            //4444
            if ((rowNo >= 1) && (rowNo <= 2)) {
                isInput = YES;
            }
            break;
        case 7:
            //7777
            if ((rowNo >= 1) && (rowNo <= 2)) {
                isInput = YES;
            }
            break;
        case 9:
            //9061
            if (rowNo == 2) {
                isInput = YES;
            }
            break;
            
        //2016-04-08 ueda
        case 11:
            if ((rowNo >= 2) && (rowNo <= 3)) {
                isInput = YES;
            }
            break;

        default:
            break;
    }
    if (isInput) {
        [self performSegueWithIdentifier:@"ToSettingsInputView" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"ToSettingsDetailView" sender:nil];
    }
}


-(void)tapSwich:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    NSInteger tagNo = sw.tag;
    NSLog(@"switch tapped. value = %@", (sw.on ? @"ON" : @"OFF"));
    switch (tagNo) {
        case 101:
            sys.demo = (sw.on ? @"1" : @"0");
            break;
        case 102:
            sys.training = (sw.on ? @"1" : @"0");
            break;
        case 103:
            sys.sound = (sw.on ? @"0" : @"1");
            break;
        case 104:
            sys.codeType = (sw.on ? @"1" : @"0");
            break;
        case 105:
            sys.regularCategory = (sw.on ? @"1" : @"0");
            break;
        case 106:
            sys.searchType = (sw.on ? @"0" : @"1");
            break;
        case 107:
            sys.useBarcode = (sw.on ? @"0" : @"1");
            break;
        case 108:
            sys.menuPatternEnable = (sw.on ? @"0" : @"1");
            break;
        case 109:
            sys.childInputOnOff = (sw.on ? @"1" : @"0");
            break;
        case 110:
            sys.staffCodeInputOnOff = (sw.on ? @"1" : @"0");
            break;
        case 111:
            sys.choriType = (sw.on ? @"0" : @"1");
            break;
        case 112:
            sys.transceiver = (sw.on ? @"0" : @"1");
            break;
        case 113:
            sys.transitionOnOff = (sw.on ? @"1" : @"0");
            break;
        case 114:
            sys.scrollOnOff = (sw.on ? @"1" : @"0");
            break;
        //2016-04-08 ueda
        case 116:
            sys.notSleepOnOff = (sw.on ? @"1" : @"0");
            if ([sys.notSleepOnOff isEqualToString:@"1"]) {
                //ロック/スリープの禁止
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            } else {
                //ロック/スリープの禁止の解除
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            }
            break;
        case 117:
            sys.notOpeCheckOnOff = (sw.on ? @"1" : @"0");
            break;
        case 118:
            sys.notOpeCheckSound = (sw.on ? @"1" : @"0");
            break;
        case 119:
            sys.notOpeCheckVib = (sw.on ? @"1" : @"0");
            break;
        default:
            break;
    }
    [sys saveChacheAccount];
}

@end
