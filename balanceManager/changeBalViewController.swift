//
//  changeBalViewController.swift
//  balanceManager
//
//  Created by なお on 2022/08/10.
//

import UIKit

class changeBalViewController: UIViewController {
    @IBOutlet weak var changeTextField: UITextField! //収支入力用テキストボックス
    @IBOutlet weak var titleTextField: UITextField! //タイトル用テキストボックス
    @IBOutlet weak var categoryButton: UIButton! //カテゴリー選択ボタン
    @IBOutlet weak var detailTextView: UITextView! //詳細メモ記述用ボックス
    var userdefaults = UserDefaults.standard
    var categoryList: [String] = [""] //カテゴリー一覧
    var category:String = "" //選択中カテゴリー
    let dt = Date()
    let dateFormatter = DateFormatter()
    var month: String = ""
    
    var new: Bool = true //新規作成か (以降編集時用変数)
    var index: Int! //カテゴリーの中のindex番号
    var titleTxt: String! //titleTextField設定用
    var priceTxt: String! //changeTextField設定用
    var detailTxt: String! //detailTextView設定用
    var monthTxt: String! //monthの選択UI(WIP)設定用
    var defaultCategory: String! //元々のカテゴリー
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM", options: 0, locale: Locale(identifier: "ja_JP"))
            month = dateFormatter.string(from: dt)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // UserDefault読み込み
        if userdefaults.array(forKey: "category") == nil {
            categoryList = ["食費","交通費","日用品費","医療費","雑費"]
            userdefaults.set(categoryList,forKey: "category")
        }else{
            categoryList = userdefaults.array(forKey: "category") as! [String]
        }
        
        //カテゴリー選択ボタン設定
        var items: [UIAction] = []
        for i in 0..<categoryList.count {
            items.append(UIAction(title: categoryList[i], handler: { _ in
                self.category = self.categoryList[i]
                self.categoryButton.setTitle((self.categoryList[i]), for: .normal)
            }))
        }
        categoryButton.menu = UIMenu(options: .displayInline, children: items)
        categoryButton.showsMenuAsPrimaryAction = true
        if new {
            categoryButton.setTitle(categoryList[0], for: .normal)
            category = categoryList[0]
        }else {
            categoryButton.setTitle(categoryList[categoryList.firstIndex(of: category)!], for: .normal)
            
            changeTextField.text = priceTxt
            titleTextField.text = titleTxt
            detailTextView.text = detailTxt
        }
    }
    
    //追加処理
    @IBAction func done() {
        if changeTextField.text != "" && titleTextField.text != "" {
            let balText: String = changeTextField.text!
            if let balance = Int(balText) {
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM-dd", options: 0, locale: Locale(identifier: "ja_JP"))
                let date: String = dateFormatter.string(from: dt)
                var categoryData: Dictionary<String,[[String]]> = [:]
                //新規追加の場合
                if new {
                    //dataキーのdictionary存在確認
                    if userdefaults.dictionary(forKey: "data") != nil {
                        categoryData = userdefaults.dictionary(forKey: "data") as! Dictionary<String,[[String]]>
                        //その月のカテゴリデータが存在していない時
                        if checkCategoryExist(month: month, category: category,categoryData: categoryData) == false {
                            categoryData.updateValue([[balText]], forKey: (category+"_"+month+"_sum"))
                            categoryData.updateValue([[titleTextField.text!,balText,detailTextView.text!,date]], forKey: (category+"_"+month))
                            //その月のカテゴリデータが存在している時
                        }else {
                            categoryData.updateValue([[String(Int(categoryData[category+"_"+month+"_sum"]![0][0])!+balance)]], forKey: category+"_"+month+"_sum")
                            var data: [[String]] = categoryData[category+"_"+month]!
                            data.append([titleTextField.text!,balText,detailTextView.text!,date])
                            categoryData.updateValue(data, forKey: (category+"_"+month))
                        }
                        
                        //dictionary存在してなかった時
                    }else{
                        print("data nil")
                        categoryData.updateValue([[balText]], forKey: (category+"_"+month+"_sum"))
                        categoryData.updateValue([[titleTextField.text!,balText,detailTextView.text!,date]], forKey: (category+"_"+month))
                    }
                    
                    //元ビュー処理
                    let view = self.presentingViewController as! ViewController
                    userdefaults.set(userdefaults.integer(forKey:"bal")+balance,forKey: "bal")
                    view.loadUD()
                    view.setBal(0)
                    
                //編集の場合
                }else{
                    categoryData = userdefaults.dictionary(forKey: "data") as! Dictionary<String,[[String]]>
                    var changedBal: Int = balance - Int(priceTxt)!
                    //月、カテゴリーをまたいでの編集の場合
                    if month != monthTxt || category != defaultCategory {
                        categoryData.updateValue([[String(Int(categoryData[defaultCategory+"_"+monthTxt+"_sum"]![0][0])!-balance)]], forKey: defaultCategory+"_"+monthTxt+"_sum")
                        changedBal = balance
                        var data: [[String]] = categoryData[defaultCategory+"_"+monthTxt]!
                        data.remove(at: index)
                        categoryData.updateValue(data, forKey: (defaultCategory+"_"+monthTxt))
                        //もし移動先のカテゴリーデータがなかった時新規に作成する
                        if categoryData[category+"_"+month] == nil {
                            categoryData.updateValue([["0"]], forKey: category+"_"+month+"_sum")
                            categoryData.updateValue([[titleTextField.text!,balText,detailTextView.text!,date]], forKey: (category+"_"+month))
                        }else {
                            var newData: [[String]] = categoryData[category+"_"+month]!
                            newData.append([titleTextField.text!,balText,detailTextView.text!,date])
                            categoryData.updateValue(data, forKey: (category+"_"+month))
                        }
                        index = categoryData[category+"_"+month]!.count - 1
                    }
                    
                    categoryData.updateValue([[String(Int(categoryData[category+"_"+month+"_sum"]![0][0])!+changedBal)]], forKey: category+"_"+month+"_sum")
                    var data: [[String]] = categoryData[category+"_"+month]!
                        data[index] = [titleTextField.text!,balText,detailTextView.text!,date]
                    categoryData.updateValue(data, forKey: (category+"_"+month))

                    let view = self.presentingViewController as! detailLogViewController
                    //リストを日付順で並び替える関数、tableViewをリロードする関数を実行(WIP)
                }

                
                userdefaults.set(categoryData,forKey: "data")
                
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //キャンセル処理
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    //その月のカテゴリー存在確認
    func checkCategoryExist(month:String,category:String,categoryData:Dictionary<String,[[String]]>) -> Bool{
        if categoryData.keys.contains(category+"_"+month+"_sum") {
            return true
        }else{
            return false
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
