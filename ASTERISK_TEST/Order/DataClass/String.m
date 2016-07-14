//
//  String.m
//  Order
//
//  Created by koji kodama on 13/05/25.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "String.h"
#import "System.h"

@implementation String


+ (NSString*)Order_Station{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"オーダーステーション";
    }
    else{
        return @"Order Station";
    }
}

+ (NSString*)Cancel1{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"キャンセルしますか？";
    }
    else{
        return @"Cancel ?";
    }
}

+ (NSString*)Clear_this_slip{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        //2015-01-08 ueda
        //return @"注文をクリアしますか？";
        return @"伝票をクリアしますか？";
    }
    else{
        return @"Clear this slip ?";
    }
}

+ (NSString*)Input_the_table{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"テーブルを入力して下さい";
    }
    else{
        return @"Input the table.";
    }
}

+ (NSString*)The_Table_which{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"入力したテーブルは登録されていません";
    }
    else{
        return @"The Table which you inputted to is unregistered.";
    }
}

+ (NSString*)The_number{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"人数が0人です。\nよろしいですか？";
    }
    else{
        return @"The number of people is 0.\nExecute ?";
    }
}

+ (NSString*)Order_send{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"オーダーが送信されました";
    }
    else{
        return @"Order send.";
    }
}

+ (NSString*)Table_status_did_not{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"テーブル状況の取得に失敗しました。再度読み込みますか？";
    }
    else{
        return @"Table status did not read.Reload?";
    }
}

+ (NSString*)Table_did_not_select{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"テーブルが選択されていません";
    }
    else{
        return @"Table did not select.";
    }
}

+ (NSString*)Split_Table_for_New_Customer{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"伝票が存在しています。\n新規登録を行いますか？";
    }
    else{
        return @"Split Table for New Customer.";
    }
}

+ (NSString*)Slip_has_been_printed{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"伝票が存在しています。\n新規登録は行えません。";
    }
    else{
        return @"Slip has been printed\nNot enable to input\nNew order";
    }
}

+ (NSString*)Table_is_empty{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"選択されたテーブルは空席です";
    }
    else{
        return @"Table is empty.";
    }
}

+ (NSString*)No_order1{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"注文がありません";
    }
    else{
        return @"No order";
    }
}

+ (NSString*)Choice_staff{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"担当者が選択されていません";
    }
    else{
        return @"Choice staff";
    }
}

+ (NSString*)New_or_Add{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"新規／追加を選択して下さい。";
    }
    else{
        return @"New or Add";
    }
}

+ (NSString*)No_order2{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"オーダーが選択されていません";
    }
    else{
        return @"No order";
    }
}

+ (NSString*)No_canceled{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"取消がありません";
    }
    else{
        return @"No canceled date";
    }
}

+ (NSString*)No_canceled_date{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"個数が整合していません。";
    }
    else{
        return @"No canceled date";
    }
}

+ (NSString*)Cannot_be_divide1{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"分割できる個数がありません。";
    }
    else{
        return @"Cannot be divide";
    }
}

+ (NSString*)Cannot_be_divide2{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"分割できません。";
    }
    else{
        return @"Cannot be divide";
    }
}

+ (NSString*)Divide_Execute{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"2分割します。\nよろしいですか？";
    }
    else{
        return @"2Divide\nExecute ?";
    }
}

+ (NSString*)Choose{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"分割する商品が選択されていません。";
    }
    else{
        return @"Choose.";
    }
}

+ (NSString*)Divide_Execute_some{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"%d分割します。\nよろしいですか？";
    }
    else{
        return @"%dDivide\nExecute ?";
    }
}

+ (NSString*)Can_be_divided{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"10分割以上は選択できません。";
    }
    else{
        return @"Can be divided to 10 at the maxinum\nImpossible to do";
    }
}

+ (NSString*)Print_Slip{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"伝票を印刷しますか？";
    }
    else{
        return @"Print Slip ?";
    }
}


+ (NSString*)Input_num{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"[%@]の入力は%@のみ許可しています。";
    }
    else{
        return @"[%@]\nInput";
    }
}

+ (NSString*)The_number_of_the_composition{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"構成メニュー数は%dまでです。";
    }
    else{
        return @"Up to %d menu can be input";
    }
}

+ (NSString*)Cancel_syohin{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"この商品をクリアします。\nよろしいですか？";
    }
    else{
        return @"Clear this items?";
    }
}

+ (NSString*)Password{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"パスワード";
    }
    else{
        return @"Password";
    }
}

+ (NSString*)Wrong_password{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"パスワードが違います。";
    }
    else{
        return @"Wrong password";
    }
}

+ (NSString*)Setting_cancel{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"設定をキャンセルしますか？";
    }
    else{
        return @"Cancel ?";
    }
}

+ (NSString*)figure{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"%d桁で設定して下さい。";
    }
    else{
        return @"% dfigure";
    }
}

+ (NSString*)To_figure{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"%d〜%d桁で設定して下さい。";
    }
    else{
        return @"%d〜%d figure";
    }
}

+ (NSString*)Entry_to{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"%dまで設定して下さい。";
    }
    else{
        return @"Entriy to %d";
    }
}

+ (NSString*)Entry{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"%d〜%dで設定して下さい。";
    }
    else{
        return @"Entry %d〜%d";
    }
}

+ (NSString*)System_will_finish{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"システムを終了します。\nよろしいですか？";
    }
    else{
        return @"System will finish.";
    }
}

+ (NSString*)Load_Master_with_num{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"マスタのロードを行いますか？[%@]";
    }
    else{
        return @"Load Master Data? [%@]";
    }
}

+ (NSString*)Set_up{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return [NSString stringWithFormat:@"オーダーステーション for iOS\n%@\n\n設定を行いますか？",[self Ver]];
    }
    else{
        return [NSString stringWithFormat:@"ORDER STATION for iOS\n%@\n\nSet up？",[self Ver]];
    }
}

+ (NSString*)Load_Master{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"マスタデータを取得します。\nよろしいですか？";
    }
    else{
        return @"Load Master Data?";
    }
}

+ (NSString*)Clear_table{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"案内中？";
    }
    else{
        
        return @"Kept already ?";
    }
}

+ (NSString*)Kept_already{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"準備完了？";
    }
    else{
        return @"Clear table already ?";
    }
}

+ (NSString*)Clear_table2{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"案内中その２？";
    }
    else{
        return @"Clear table already ?2";
    }
}

+ (NSString*)Vacant{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"空席？";
    }
    else{
        return @"Vacant?";
    }
}

+ (NSString*)Reserve{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"予約時刻:%@時%@分\n予約者名:%@\n人数:%@";
    }
    else{
        return @"%@:%@\n%@ (%@)";
    }
}

+ (NSString*)Choose_split{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"伝票が選択されていません";
    }
    else{
        return @"Choose.";
    }
}

+ (NSString*)not_possible_to_confirm{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"注文内容が確認できませんでした。";
    }
    else{
        return @"It was not possible to confirm the order details";
    }
}

+ (NSString*)Plese_try_again{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"通信がタイムアウトで終了しました。";
    }
    else{
        return @"Plese try again [RCV]";
    }
}

+ (NSString*)Network_is_disconnected{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"通信環境を確認することができませんでした。";
    }
    else{
        return @"Network is disconnected";
    }
}

+ (NSString*)search{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"検索";
    }
    else{
        return @"Search";
    }
}

+ (NSString*)searchC{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　検索? - 顧客";
    }
    else{
        return @"Search? - Customer";
    }
}

+ (NSString*)searchAdd{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　検索? - 追加";
    }
    else{
        return @"　Search? - Add";
    }
}

+ (NSString*)searchCheck{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　検索? - チェック";
    }
    else{
        return @"　Search? - Check";
    }
}

+ (NSString*)searchCancel{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　検索? - 取消";
    }
    else{
        return @"　Search? - Cancel";
    }
}

+ (NSString*)tableNew{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　ﾃｰﾌﾞﾙ?　−　新規";
    }
    else{
        return @"　Table?　−　New";
    }
}

+ (NSString*)tableAdd{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　ﾃｰﾌﾞﾙ?　−　追加";
    }
    else{
        return @"　Table?　−　Add";
    }
}

+ (NSString*)tableOrder{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　ﾃｰﾌﾞﾙ?　−　注文";
    }
    else{
        return @"　Table?　−　Order";
    }
}

+ (NSString*)tableCancel{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　ﾃｰﾌﾞﾙ?　−　取消";
    }
    else{
        return @"　Table?　−　Cancel";
    }
}

+ (NSString*)tableConfirm{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　ﾃｰﾌﾞﾙ?　−　ﾁｪｯｸ";
    }
    else{
        return @"　Table?　−　Check";
    }
}

+ (NSString*)tableDivide{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　ﾃｰﾌﾞﾙ?　−　分割";
    }
    else{
        return @"　Table?　−　Divide";
    }
}

+ (NSString*)tableMove1{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　ﾃｰﾌﾞﾙ?　−　移動元";
    }
    else{
        return @"　Table?　−　previous table";
    }
}

+ (NSString*)tableMove2{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　移動先 [ %@ ⇒　? ]";
    }
    else{
        return @"　Move [ %@ ⇒　? ]";
    }
}

+ (NSString*)tableNo{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　ﾃｰﾌﾞﾙ　%@";
    }
    else{
        return @"　Table　%@";
    }
}

+ (NSString*)tableCook{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"　ﾃｰﾌﾞﾙ?　−　調理指示";
    }
    else{
        return @"　Table?　−　Cook";
    }
}

+ (NSString*)table{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ﾃｰﾌﾞﾙ";
    }
    else{
        return @"Table";
    }
}

+ (NSString*)slipNo{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"伝票No";
    }
    else{
        return @"SlipNo";
    }
}

+ (NSString*)Search{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"検索\n ";
    }
    else{
        return @"Search\n ";
    }
}

+ (NSString*)Printing_slip{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"はい";
    }
    else{
        return @"Printing slip";
    }
}

+ (NSString*)Indicate_on_display{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return [String No];
    }
    else{
        return @"Indicate on display";
    }
}

+ (NSString*)The_change{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"設定変更の確認";
    }
    else{
        return @"The change of the setting";
    }
}

+ (NSString*)Change_setting{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"変更してもよろしいですか？";
    }
    else{
        return @"Change setting. OK?";
    }
}

+ (NSString*)Yes{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"はい";
    }
    else{
        return @"Yes";
    }
}

+ (NSString*)No{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"いいえ";
    }
    else{
        return @"No";
    }
}

+ (NSString*)Sub_menu{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @" サブメニュー";
    }
    else{
        return @" Sub menu";
    }
}

+ (NSString*)Setting_system{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @" システム設定";
    }
    else{
        return @" Setting system";
    }
}

+ (NSString*)Layer{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @" 客層";
    }
    else{
        //2014-11-20 ueda
        return @" Visitor Layer";
    }
}

+ (NSString*)Input_the_number{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"人数を入力して下さい";
    }
    else{
        return @"Input the number of people.";
    }
}

+ (NSString*)Deal{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        //2014-12-25 ueda
        //return @" 取引?";
        return @" オーダー種類";
    }
    else{
        //2014-12-25 ueda
        //return @" Deal?";
        return @" Serving Type";
    }
}

+ (NSString*)Clear_Message{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"メッセージをクリアしますか？";
    }
    else{
        //2014-10-28 ueda
        //return @"testtest";
        return @"Do you clear a message?";
    }
}

+ (NSString*)Speak_now{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"録音中";
    }
    else{
        return @"Speak now";
    }
}

+ (NSString*)Tray{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"Tray";
    }
    else{
        return @"";
    }
}

+ (NSString*)Add_to_trays{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Add to %d trays\n\nExecute ?";
    }
    else{
        return @"トレイを %d　セット追加しますか？";
    }
}

+ (NSString*)DeviceID{
    if (![[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"DeviceID";
    }
    else{
        return @"端末ID";
    }
}

+ (NSString*)Menu_pattern{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Menu pattern";
    }
    else{
        return @"メニューパターン";
    }
}

+ (NSString*)Erase_Tray{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"[%d]Erase Tray\nExecute ?";
    }
    else{
        return @"[%d]のトレイを\n消去します。\n\nよろしいですか？";
    }
}

+ (NSString*)Clear_This_Item{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Clear This Item?";
    }
    else{
        return @"この商品を\nクリアします。\nよろしいですか？";
    }
}

+ (NSString*)Clear_This_Menu{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Clear This Menu?";
    }
    else{
        return @"クリアします。\nよろしいですか？";
    }
}

+ (NSString*)Extra_time{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Extra time?";
    }
    else{
        return @"延長時間設定？";
    }
}

+ (NSString*)EXTRA_TIME_OF_TABLE{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"EXTRA TIME OF TABLE:%d";
    }
    else{
        return @"テーブル:%dの時間延長";
    }
}

+ (NSString*)HOUR{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"1 HOUR";
    }
    else{
        return @"１時間";
    }
}

+ (NSString*)MINITES1{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"30 MINITES";
    }
    else{
        return @"３０分";
    }
}

+ (NSString*)MINITES2{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"10 MINITES";
    }
    else{
        return @"１０分";
    }
}

+ (NSString*)RESET{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"RESET";
    }
    else{
        return @"リセット";
    }
}

+ (NSString*)SUBMIT{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"SUBMIT";
    }
    else{
        return @"登録";
    }
}

+ (NSString*)CANCEL2{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"CANCEL";
    }
    else{
        return @"戻る";
    }
}

+ (NSString*)The_content{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"The content you have entered is not submitted yet.\nAre you sure you want to finish setting?";
    }
    else{
        return @"編集内容が登録されていません。\nテーブル:%dの時間延長設定を終了しますか？";
    }
}

+ (NSString*)It_changes{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"It changes the schedule time of Table: %d";
    }
    else{
        return @"テーブル：%dの退店時間を変更します\nよろしいですか？";
    }
}

+ (NSString*)SCHEDULE_TIME{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"SCHEDULE TIME";
    }
    else{
        return @"現在の退店予定";
    }
}

+ (NSString*)EXTRA_TIME{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"EXTRA TIME";
    }
    else{
        return @"延長時間";
    }
}

+ (NSString*)NEW_TIME{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"NEW TIME";
    }
    else{
        return @"新しい退店予定";
    }
}

+ (NSString*)Order_{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Order [%d]/%d";
    }
    else{
        return @"注文 [%d]/%d";
    }
}

+ (NSString*)Enter_a_message{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"メッセージを入力して下さい";
    }
    else{
        return @"Enter a message";
    }
}





+ (NSString*)Ver{
    //return @"Ver 1.0.0\nImage";
    NSString *str1= @"Ver ";
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"%@%@",str1,version];
}

+ (NSString*)Setting{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"設定";
    }
    else{
        return @"Setting";
    }
}

+ (NSString*)Program_end{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"終了";
    }
    else{
        return @"Program end";
    }
}

+ (NSString*)Download{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ダウンロード";
    }
    else{
        return @"Download";
    }
}

+ (NSString*)Normal{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"指定なし";
    }
    else{
        return @"Normal";
    }
}
+ (NSString*)Select_staff{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ここをタッチすると担当者を確定";
    }
    else{
        //2015-11-04 ueda
        //return @"Select staff";
        return @"I determine to touch it here in staff.";
    }
}
//2015-11-04 ueda
+ (NSString*)No_Staff{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"担当者を選択";
    }
    else{
        return @"Select Staff";
    }
}
+ (NSString*)Served_already{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"提供完了？";
    }
    else{
        return @"Served already ?";
    }
}

+ (NSString*)Str_t{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ﾃ";
    }
    else{
        return @"T";
    }
}

+ (NSString*)Cancel_confirm{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"取消確認";
    }
    else{
        return @"Cancel";
    }
}

+ (NSString*)Confirm{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"確認";
    }
    else{
        return @"Confirmation";
    }
}

+ (NSString*)Total{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"合計";
    }
    else{
        return @"Total";
    }
}


+ (NSString*)Stock{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"残";
    }
    else{
        return @"Stock";
    }
}

+ (NSString*)Out_of_stock_change{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"品切れになりました。変更してください。";
    }
    else{
        return @"Out of stock change.";
    }
}

+ (NSString*)Go_to_modify{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        //2014-01-29 ueda
        //2016-02-03 ueda ASTERISK
        //return @"　\n%@\n　　アレンジしますか？";
        return @"　\n%@\n　　トッピングしますか？";
    }
    else{
        return @"%@\nGo to 'Modify menu'?";
    }
}

+ (NSString*)Demo_mode{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ラーニング モード";
    }
    else{
        return @"Learning mode";
    }
}
+ (NSString*)Training_mode{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"トレーニング モード";
    }
    else{
        return @"Training mode";
    }
}

+ (NSString*)Show_slip{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"いいえ（画面に表示）";
    }
    else{
        return @"NO[Show slip]";
    }
}

+ (NSString*)No_amount{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"金額が「￥０」です。\nよろしいですか？";
    }
    else{
        return @"No amount\nExecute?";
    }
}

+ (NSString*)Reissue_slip{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"伝票の再発行を行います。";
    }
    else{
        return @"Reissue slip";
    }
}

+ (NSString*)Reissue_slip2{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"伝票の再発行を行いますか？";
    }
    else{
        return @"Reissue slip?";
    }
}

+ (NSString*)ONLY{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"のみ";
    }
    else{
        return @"ONLY";
    }
}

+ (NSString*)ALL{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"すべて";
    }
    else{
        return @"ALL";
    }
}

+ (NSString*)Cancel_slip{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"取り消し";
    }
    else{
        return @"CANCEL";
    }
}

+ (NSString*)CHECK_OUT{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"カスタマ・厨房伝票";
    }
    else{
        return @"CHECK OUT,KITCHEN";
    }
}

+ (NSString*)TICKET{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"キッチンチケット";
    }
    else{
        return @"TICKET";
    }
}

+ (NSString*)CHOICE{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"選択";
    }
    else{
        return @"CHOICE";
    }
}






+ (NSString*)bt_print1{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"印刷";
    }
    else{
        return @"Print";
    }
}


+ (NSString*)bt_print2{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        //2014-02-07 ueda
        return @"ﾁｪｯｸ\n伝票";
    }
    else{
        return @"C.O.\nSlip";
    }
}

+ (NSString*)bt_print3{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        //2014-02-07 ueda
        return @"ｶｽﾀﾏ\n伝票";
    }
    else{
        return @"Cust.\nSlip";
    }
}


+ (NSString*)bt_divide{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"分割";
    }
    else{
        return @"Divide";
    }
}

+ (NSString*)bt_move{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"移動";
    }
    else{
        return @"Move";
    }
}

+ (NSString*)bt_cook{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"指示";
    }
    else{
        return @"Cook";
    }
}

+ (NSString*)bt_setting{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"設定";
    }
    else{
        return @"Setting";
    }
}

+ (NSString*)bt_check{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ﾁｪｯｸ";
    }
    else{
        return @"Confirm";
    }
}

+ (NSString*)bt_cancel{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"取消";
    }
    else{
        return @"Cancel";
    }
}

+ (NSString*)bt_add{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"追加";
    }
    else{
        return @"Add";
    }
}

+ (NSString*)bt_new{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"新規";
    }
    else{
        return @"New";
    }
}

+ (NSString*)bt_next{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"次へ";
    }
    else{
        return @"Next";
    }
}

+ (NSString*)bt_return{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"戻る";
    }
    else{
        return @"Return";
    }
}

+ (NSString*)bt_search{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"検索";
    }
    else{
        return @"Search";
    }
}

+ (NSString*)bt_send{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"送信";
    }
    else{
        return @"Send";
    }
}

+ (NSString*)bt_confirm{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"確認";
    }
    else{
        return @"OK";
    }
}

+ (NSString*)bt_done{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"完了";
    }
    else{
        return @"Finish";
    }
}

+ (NSString*)bt_count{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"人数";
    }
    else{
        return @"Guests";
    }
}

+ (NSString*)bt_finish{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"終了";
    }
    else{
        return @"End";
    }
}

+ (NSString*)bt_order{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"注文";
    }
    else{
        return @"Order";
    }
}

+ (NSString*)bt_ok{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"決定";
    }
    else{
        return @"OK";
    }
}

+ (NSString*)bt_top{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ﾄｯﾌﾟ";
    }
    else{
        return @"TOP";
    }
}

//2014-07-08 ueda
+ (NSString*)bt_sort{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"並替";
    }
    else{
        return @"Sort";
    }
}

//2014-07-08 ueda
+ (NSString*)bt_addOrder{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ｵｰﾀﾞｰ\n追加";
    }
    else{
        return @"ADD\nOrder";
    }
}



+ (NSString*)man{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"男";
    }
    else{
        //2014-09-09 ueda
        //return @"M";
        return @"Ad";
    }
}

//2014-10-24 ueda
+ (NSString*)manTypeC{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"男";
    }
    else{
        return @"Male";
    }
}

+ (NSString*)woman{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"女";
    }
    else{
        //2014-09-09 ueda
        //return @"F ";
        return @"Ch";
    }
}

+ (NSString*)womanTypeC{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"女";
    }
    else{
        return @"Female";
    }
}



+ (NSString*)The_change_of_the_setting{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"設定変更の確認";
    }
    else{
        return @"The change of the setting";
    }
}

+ (NSString*)Changes_setting{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"変更してもよろしいですか？";
    }
    else{
        return @"Changes setting. OK?";
    }
}






+ (NSString*)TerminalID{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"端末ID [4桁]";
    }
    else{
        return @"TerminalID[4figure]";
    }
}

+ (NSString*)HostIP{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ﾎｽﾄIPｱﾄﾞﾚｽ";
    }
    else{
        return @"HostIP";
    }
}

//2014-08-01 ueda
+ (NSString*)PortNoStr{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"接続ポート番号";
    }
    else{
        return @"Connection Port No";
    }
}

+ (NSString*)Time_out{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"タイムアウト [1〜99秒]";
    }
    else{
        return @"Time-out[1-99s]";
    }
}

+ (NSString*)Entry_Type{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"入力タイプ";
    }
    else{
        return @"Entry Type";
    }
}

+ (NSString*)Slip_request_type{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"伝票の要求タイプ";
    }
    else{
        return @"Slip request type";
    }
}


+ (NSString*)Slip_No{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"番号";
    }
    else{
        return @"Slip No.";
    }
}

+ (NSString*)Details{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"詳細";
    }
    else{
        return @"Details";
    }
}

+ (NSString*)Newes{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"最新";
    }
    else{
        return @"Newest";
    }
}

+ (NSString*)Non_selection_menu{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ノンセレクト商品";
    }
    else{
        return @"Non selection menu";
    }
}

+ (NSString*)Sound_effect{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"効果音設定";
    }
    else{
        return @"Sound effect";
    }
}

+ (NSString*)Transceiver{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"トランシーバーを利用する";
    }
    else{
        return @"Transceiver";
    }
}

+ (NSString*)On{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"確認する";
    }
    else{
        return @"On";
    }
}

+ (NSString*)Off{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"確認しない";
    }
    else{
        return @"Off";
    }
}


+ (NSString*)Fixation_of_checkout{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"チェック伝票出力先固定の設定";
    }
    else{
        return @"Fixation of checkout slip output";
    }
}

+ (NSString*)On2{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"固定する";
    }
    else{
        return @"On";
    }
}

+ (NSString*)Off2{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"固定しない";
    }
    else{
        return @"Off";
    }
}

+ (NSString*)Checkout_slip_output{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"チェック伝票出力先の設定\n  プリンタ番号";
    }
    else{
        return @"Checkout slip output\n  Printer No.";
    }
}

+ (NSString*)Table_input_type{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"テーブル入力のタイプの設定";
    }
    else{
        return @"Table input type";
    }
}

+ (NSString*)Select{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"タッチ";
    }
    else{
        return @"Select";
    }
}

+ (NSString*)Input{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"コード";
    }
    else{
        return @"Input";
    }
}

+ (NSString*)Order_code_input{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"コード注文の設定";
    }
    else{
        return @"Order code input";
    }
}

+ (NSString*)Off3{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"使用しない";
    }
    else{
        return @"Off";
    }
}

+ (NSString*)On3{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"使用する";
    }
    else{
        return @"On";
    }
}

+ (NSString*)Regular_Category{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"既存カテゴリー移動";
    }
    else{
        return @"Regular Category";
    }
}

+ (NSString*)Input_SP{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"拡張の設定";
    }
    else{
        return @"Input SP";
    }
}

+ (NSString*)Modify{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        //2016-02-03 ueda ASTERISK
        //return @"アレンジ";
        return @"トッピング";
    }
    else{
        return @"Modify";
    }
}

+ (NSString*)Modify2{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        //2016-02-03 ueda ASTERISK
        //return @"ｱﾚﾝｼﾞ";
        //2016-02-08 ueda ASTERISK
        //return @"ﾄｯﾋﾟﾝｸﾞ";
        return @"ＴＰ";
    }
    else{
        return @"Modify";
    }
}


+ (NSString*)Off4{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"なし";
    }
    else{
        return @"Off";
    }
}

+ (NSString*)QTY{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"数量";
    }
    else{
        return @"QTY";
    }
}

+ (NSString*)Search_key{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"検索キー機能の設定";
    }
    else{
        return @"Search key";
    }
}

+ (NSString*)Menu_list{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"メニューパターンの設定";
    }
    else{
        return @"Menu list";
    }
}

+ (NSString*)On5{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"する";
    }
    else{
        return @"On";
    }
}

+ (NSString*)Off5{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"しない";
    }
    else{
        return @"Off";
    }
}

+ (NSString*)Menu_list_pattern{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"設定するパターン(0～7)";
    }
    else{
        return @"Menu list pattern[0～7]";
    }
}


+ (NSString*)SectionCD{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"所属コードの設定[2桁]";
    }
    else{
        return @"SectionCD[2figure]";
    }
}

+ (NSString*)Divide_type{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"分割機能の設定";
    }
    else{
        return @"Divide type";
    }
}

+ (NSString*)Divide10{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"１０分割";
    }
    else{
        return @"10 Divide";
    }
}

+ (NSString*)Divide2{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"２分割";
    }
    else{
        return @"2 Divide";
    }
}

+ (NSString*)Input_SP2{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"拡張入力2";
    }
    else{
        return @"Input SP 2";
    }
}

+ (NSString*)VLayer{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"客層";
    }
    else{
        return @"V.Layer";
    }
}

+ (NSString*)Customer{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"顧客";
    }
    else{
        //2014-10-23 ueda
        //return @"Customer";
        return @"Cust.";
    }
}

+ (NSString*)Cooking_instruction{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"調理指示の設定";
    }
    else{
        return @"Cooking instruction";
    }
}

+ (NSString*)Training{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"トレーニングモードの設定";
    }
    else{
        return @"Training mode";
    }
}

+ (NSString*)Off6{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"通常";
    }
    else{
        return @"Off";
    }
}

+ (NSString*)On6{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"トレーニング";
    }
    else{
        return @"On";
    }
}

+ (NSString*)Language{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"言語の設定";
    }
    else{
        return @"Language";
    }
}

+ (NSString*)Japanese{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"日本語";
    }
    else{
        return @"Japanese";
    }
}

+ (NSString*)English{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"英語";
    }
    else{
        return @"English";
    }
}

+ (NSString*)Currency{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"通貨の設定";
    }
    else{
        return @"Currency";
    }
}

+ (NSString*)Yen{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"円";
    }
    else{
        return @"Yen";
    }
}

+ (NSString*)Dollar{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ドル";
    }
    else{
        return @"Dollar";
    }
}

+ (NSString*)Demo{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"ラーニングモードの設定";
    }
    else{
        return @"Learning mode";
    }
}

+ (NSString*)Ftp_user{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"FTPユーザー";
    }
    else{
        return @"Ftp user";
    }
}

+ (NSString*)Ftp_password{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"FTPパスワード";
    }
    else{
        return @"Ftp password";
    }
}

//2014-06-23 ueda
+ (NSString*)PhotoMsg{
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"写真";
    }
    else{
        return @"Image";
    }
}

//2014-08-05 ueda
+ (NSString*)scanBarcodeMsg {
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        return @"バーコードにピントを合わせて下さい";
    }
    else{
        return @"Focus BARCODE.";
    }
}

+ (NSString*)Cancel3{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Cancel";
    }
    else{
        return @"キャンセル";
    }
}

//2014-10-02 ueda
//2014-08-19 ueda
+ (NSString*)useBarcodeMsg {
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Use barcode on search key or customer";
    }
    else{
        return @"検索キーや顧客検索でバーコードを使用する";
    }
}

//2014-09-05 ueda
+ (NSString*)typeCseatCaptionType {
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"SeatCaptionType(Ctype)";
    } else {
        return @"席番表示形式（Ｃタイプ使用時）";
    }
}

+ (NSString*)typeCseatCaptionAlphabet {
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Alphabet";
    } else {
        return @"英字";
    }
}
+ (NSString*)typeCseatCaptionNumber {
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Number";
    } else {
        return @"数字";
    }
}
+ (NSString*)typeCseatAndOrdertypeTitle {
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        //2014-10-23 ueda
        //return @"Select Seat / Order Kind";
        return @"Seat / ServingType";
    } else {
        //2014-10-23 ueda
        //return @"席番・オーダー種類選択";
        return @"席番/オーダー種類";
    }
}

//2014-09-16 ueda
+ (NSString*)Enter_a_Arrange{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        //2014-10-06 ueda
        //return @"Enter a Arrange";
        return @"Remark";
    } else {
        //2016-02-03 ueda ASTERISK
        //return @"アレンジを入力して下さい";
        return @"トッピングを入力して下さい";
    }
}

//2014-09-19 ueda
+ (NSString*)Cut_Character{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"I deleted the letter which I could not use.";
    } else {
        return @"使用できない文字はカットしました";
    }
}

//2014-10-02 ueda
+ (NSString*)Arrange_Comment{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Arrange input";
    } else {
        //2016-02-03 ueda ASTERISK
        //return @"アレンジ直接入力";
        return @"トッピング直接入力";
    }
}

//2014-10-24 ueda
+ (NSString*)childTypeC{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Child";
    } else {
        return @"小人";
    }
}

//2014-10-28 ueda
//2015-06-23 ueda
+ (NSString*)transitionStr{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Transition effect";
    } else {
        return @"トランジション効果";
    }
}

//2014-10-28 ueda
//2015-06-23 ueda
+ (NSString*)scrollStr{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Scroll like iOS";
    } else {
        return @"iOSらしくスクロール";
    }
    
}

//2014-10-29 ueda
+ (NSString*)sendOrderRetry{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Try again.";
    } else {
        return @"再送信します。";
    }
}

//2014-10-30 ueda
+ (NSString*)home_back{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Home image keyword";
    } else {
        return @"ホーム画像 キーワード";
    }
}

//2014-12-04 ueda
+ (NSString*)Cannot_connect{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Please try again [CE]";
    } else {
        return @"接続できませんでした。";
    }
}

//2014-12-12 ueda
+ (NSString*)childInputStr{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Input the number of Child.\n(A and B type)";
    } else {
        return @"小人の人数を入力する\n（A,Bタイプ）";
    }
}

//2015-02-04 ueda
+ (NSString*)Delete_Called{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Delete ?";
    } else {
        return @"消去？";
    }
}

//2015-03-24 ueda
//2015-06-23 ueda
+ (NSString*)RegisterType{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Register Type";
    } else {
        return @"レジのタイプ";
    }
}
+ (NSString*)SimpleRegi{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Simple";
    } else {
        return @"簡易";
    }
}
+ (NSString*)PokeRegi{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Poke\nRegi";
    } else {
        return @"ポケ\nレジ";
    }
}
+ (NSString*)PokeRegiOnly{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Poke\nRegi\nOnly";
    } else {
        return @"ポケ\nレジ\n専用";
    }
}
//2015-06-23 ueda
+ (NSString*)PaymentType{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Register Payment";
    } else {
        return @"レジの支払機能";
    }
}
+ (NSString*)PayNormal{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Normal";
    } else {
        return @"通常";
    }
}
+ (NSString*)PayYadokake{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"RoomOnly";
    } else {
        return @"宿掛専用";
    }
}
+ (NSString*)bt_register{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Reg.";
    } else {
        return @"レジ";
    }
}
+ (NSString*)bt_checkOut{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"C.Out";
    } else {
        return @"精算";
    }
}
+ (NSString*)PayTitleTotal{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Total orders";
    } else {
        return @"注文合計";
    }
}
+ (NSString*)PayTitleCash{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Cash";
    } else {
        return @"現金";
    }
}
+ (NSString*)PayTitleCard{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Credit card";
    } else {
        return @"カード";
    }
}
+ (NSString*)PayTitleChange{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Change";
    } else {
        return @"つり銭";
    }
}
+ (NSString*)PayTitleRyosyusyo{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Receit";
    } else {
        return @"領収書";
    }
}
+ (NSString*)PayTitleCustomer{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Customer";
    } else {
        return @"顧客";
    }
}
+ (NSString*)PayTitleCustomerName{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Cust.Name";
    } else {
        return @"顧客名";
    }
}
+ (NSString*)urikake1Error{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"[Payment 1] does not set [RECEIVABLE].";
    } else {
        return @"「支払区分１」が「売掛」設定になっていません。";
    }
}
+ (NSString*)PokeRegiCancel{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Stop processing CHECKOUT?";
    } else {
        return @"精算処理を取り消しますか？";
    }
}
//2015-04-14 ueda
+ (NSString*)tableMultiSelectTitle{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Table select (Only for NEW)";
    } else {
        return @"テーブル選択（新規のみ）";
    }
}
+ (NSString*)tableMultiSelectOkTitle{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Multi";
    } else {
        return @"複数";
    }
}
+ (NSString*)tableMultiSelectNgTitle{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Single";
    } else {
        return @"単一";
    }
}

//2015-04-16 ueda
+ (NSString*)AddOrderConfirm{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Any Addition ?";
    } else {
        return @"追加の入力を行いますか？";
    }
}

//2015-04-20 ueda
+ (NSString*)staffCodeInputTitle{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Input Staff Code";
    } else {
        return @"担当者コード入力";
    }
}
+ (NSString*)searchStaffCode{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"　Search? - Staff Code";
    } else {
        return @"　検索? - 担当者コード";
    }
}
+ (NSString*)staffCodeNotFound{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"The staff code does not exist.";
    } else {
        return @"該当する担当者は存在しません。";
    }
}

//2015-06-01 ueda
//2015-06-23 ueda
+ (NSString*)useOrderStatusTitle{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Transition screen of the [Confirm] button.";
    } else {
        return @"【チェック】ボタンの遷移先画面";
    }
}
+ (NSString*)useOrderStatusNotTitle{
    //2015-06-26 ueda
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Table";
    } else {
        return @"テーブル";
    }
}
+ (NSString*)useOrderStatusYesTitle{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Order STATUS";
    } else {
        return @"オーダー状況";
    }
}
+ (NSString*)Select_Printer{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"  Select Printer";
    } else {
        return @"  プリンタ番号選択";
    }
}
//2015-06-02 ueda
+ (NSString*)TellCall{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"May I call?";
    } else {
        return @"電話をかけてもよろしいですか？";
    }
}
//2015-06-17 ueda
+ (NSString*)staffCodeKetaTitle{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"The number of the figures of the staff cord";
    } else {
        return @"担当者コード桁数";
    }
}
+ (NSString*)staffCodeKeta6 {
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"6";
    } else {
        return @"６桁";
    }
}
+ (NSString*)staffCodeKeta2 {
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"2";
    } else {
        return @"２桁";
    }
}
//2015-09-17 ueda
+ (NSString*)useOrderConfirmTitle{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Order confirmation screen";
    } else {
        return @"オーダー確認画面";
    }
}
+ (NSString*)useOrderConfirmNotTitle{
    //2015-06-26 ueda
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Not dispay";
    } else {
        return @"表示しない";
    }
}
+ (NSString*)useOrderConfirmYesTitle{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Display";
    } else {
        return @"表示する";
    }
}
//2016-02-03 ueda ASTERISK
+ (NSString*)bt_nextPage{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Next\nPage";
    } else {
        return @"次\nページ";
    }
}
+ (NSString*)bt_prevPage{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"Prev\nPage";
    } else {
        return @"前\nページ";
    }
}

@end
