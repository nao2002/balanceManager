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
    var userdefaults = UserDefaults.standard
    var categoryList: [String] = [""] //カテゴリー一覧
    var category:String = "" //選択中カテゴリー
    let dt = Date()
    let dateFormatter = DateFormatter()
    var month: String = ""
    
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
        categoryButton.setTitle(categoryList[0], for: .normal)
        category = categoryList[0]
    }
    
    //追加処理
    @IBAction func done() {
        if changeTextField.text != "" {
            let balText: String = changeTextField.text!
            if let balance = Int(balText) {
                var categoryData: Dictionary<String,[[String]]> = [:]
                
                if userdefaults.dictionary(forKey: "data") != nil {
                    categoryData = userdefaults.dictionary(forKey: "data") as! Dictionary<String,[[String]]>
                }else{
                    print("data nil")
                    categoryData.updateValue([[balText]], forKey: (category+"_"+month+"_sum"))
                    categoryData.updateValue([["",balText,""]], forKey: (category+"_"+month))
                }
                
                if checkCategoryExist(month: month, category: category,categoryData: categoryData) == false {
                    categoryData.updateValue([[balText]], forKey: (category+"_"+month+"_sum"))
                }else {
                    categoryData.updateValue([[String(Int(categoryData[category+"_"+month+"_sum"]![0][0])!+balance)]], forKey: category+"_"+month+"_sum")
                }
                userdefaults.set(categoryData,forKey: "data")
                
                let view = self.presentingViewController as! ViewController
                view.setBal(balance)
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
