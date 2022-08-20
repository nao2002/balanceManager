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
    @IBOutlet weak var dateTextField: UITextField! //日付指定用テキストボックス
    @IBOutlet weak var detailTextView: UITextView! //詳細メモ記述用ボックス
    var userdefaults = UserDefaults.standard
    var categoryList: [String] = [""] //カテゴリー一覧
    var category:String = "" //選択中カテゴリー
    let dt = Date()
    let dateFormatter = DateFormatter()
    var month: String = ""
    var datePicker = UIDatePicker() //日付選択用DatePicker
    
    var new: Bool = true //新規作成か (以降編集時用変数)
    var index: Int! //カテゴリーの中のindex番号
    var titleTxt: String! //titleTextField設定用
    var priceTxt: String! //changeTextField設定用
    var detailTxt: String! //detailTextView設定用
    var monthTxt: String! //monthの選択UIタイトル設定用
    var defaultMonth: String! //編集前monthデータ
    var defaultCategory: String! //元々のカテゴリー
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM", options: 0, locale: Locale(identifier: "ja_JP"))
        month = dateFormatter.string(from: dt)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateSelected))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd", options: 0, locale: Locale(identifier: "ja_JP"))
        if (new) {
            datePicker.date = formatter.date(from: formatter.string(from: dt))!
        }else{
            datePicker.date = formatter.date(from: monthTxt)!
        }
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = toolbar
        if new {
            dateTextField.text = formatter.string(from: dt)
        }else {
            dateTextField.text = monthTxt
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // UserDefault読み込み
        if userdefaults.array(forKey: "category") == nil {
            categoryList = ["総計","収入","食費","交通費","日用品費","医療費","雑費"]
            userdefaults.set(categoryList,forKey: "category")
        }else{
            categoryList = userdefaults.array(forKey: "category") as! [String]
        }
        
        //カテゴリー選択ボタン設定
        var items: [UIAction] = []
        for i in 0..<categoryList.count {
            if i != 0 {
                items.append(UIAction(title: categoryList[i], handler: { _ in
                    self.category = self.categoryList[i]
                    self.categoryButton.setTitle((self.categoryList[i]), for: .normal)
                }))
            }
        }
        categoryButton.menu = UIMenu(options: .displayInline, children: items)
        categoryButton.showsMenuAsPrimaryAction = true
        if new {
            categoryButton.setTitle(categoryList[1], for: .normal)
            category = categoryList[1]
        }else {
            categoryButton.setTitle(categoryList[categoryList.firstIndex(of: category)!], for: .normal)
            
            changeTextField.text = priceTxt
            titleTextField.text = titleTxt
            detailTextView.text = detailTxt
        }
    }
    
    //追加処理
    @IBAction func done() {
        if dateTextField.isEditing {
            if dateSelected() == false {
                return
            }
        }
        if changeTextField.text != "" && titleTextField.text != "" {
            let balText: String = changeTextField.text!
            if let balance = Int(balText) {
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM-dd", options: 0, locale: Locale(identifier: "ja_JP"))
                let date: String = String(dateTextField.text!.suffix(5))
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
                            //総計データがあるか確認
                            if categoryData.keys.contains("総計_"+month) {
                                print("総計データ存在")
                                var data: [[String]] = categoryData["総計_"+month]!
                                data.append( [titleTextField.text!,balText,detailTextView.text!,date,category,"0"])
                                categoryData.updateValue(data, forKey: "総計_"+month)
                                //総計データがない場合
                            }else{
                                categoryData.updateValue([[titleTextField.text!,balText,detailTextView.text!,date,category,"0"]], forKey: "総計_"+month)
                            }
                            
                            //その月のカテゴリデータが存在している時
                        }else {
                            categoryData.updateValue([[String(Int(categoryData[category+"_"+month+"_sum"]![0][0])!+balance)]], forKey: category+"_"+month+"_sum")
                            var data: [[String]] = categoryData[category+"_"+month]!
                            data.append([titleTextField.text!,balText,detailTextView.text!,date])
                            categoryData.updateValue(data, forKey: (category+"_"+month))
                            data = categoryData["総計_"+month]!
                            data.append( [titleTextField.text!,balText,detailTextView.text!,date,category,String(categoryData[category+"_"+month]!.count-1)])
                            categoryData.updateValue(data, forKey: "総計_"+month)
                        }
                        
                        //dictionary存在してなかった時
                    }else{
                        print("data nil")
                        categoryData.updateValue([[balText]], forKey: (category+"_"+month+"_sum"))
                        categoryData.updateValue([[titleTextField.text!,balText,detailTextView.text!,date]], forKey: (category+"_"+month))
                        categoryData.updateValue([[titleTextField.text!,balText,detailTextView.text!,date,category,"0"]], forKey: "総計_"+month)
                    }
                    
                    //元ビュー処理
                    let view = self.presentingViewController as! ViewController
                    userdefaults.set(userdefaults.integer(forKey:"bal")+balance,forKey: "bal")
                    view.loadUD()
                    view.setBal(0)
                    
                    //編集の場合
                }else{
                    categoryData = userdefaults.dictionary(forKey: "data") as! Dictionary<String,[[String]]>
                    
                    //総計データ内の該当データを探す
                    var sumIndex: Int = -1
                    for i in 0..<categoryData["総計_"+defaultMonth]!.count {
                        if (categoryData["総計_"+defaultMonth]![i].contains(String(index)) && (categoryData["総計_"+defaultMonth]![i].contains(defaultCategory))) {
                            sumIndex = i
                            break
                        }
                    }
                    if sumIndex == -1 {
                        print("error 総計内にデータが見つかりませんでした")
                    }
                    print("sumIndex:\(sumIndex)")
                    var changedBal: Int = balance - Int(priceTxt)!
                    //月、カテゴリーをまたいでの編集の場合
                    if month != defaultMonth || category != defaultCategory {
                        categoryData.updateValue([[String(Int(categoryData[defaultCategory+"_"+defaultMonth!+"_sum"]![0][0])!-Int(priceTxt)!)]], forKey: defaultCategory+"_"+defaultMonth+"_sum")
                        changedBal = balance
                        var data: [[String]] = categoryData[defaultCategory+"_"+defaultMonth]!
                        data.remove(at: index)
                        categoryData.updateValue(data, forKey: (defaultCategory+"_"+defaultMonth))
                        //もし移動先のカテゴリーデータがなかった時新規に作成する
                        if categoryData[category+"_"+month] == nil {
                            categoryData.updateValue([["0"]], forKey: category+"_"+month+"_sum")
                            categoryData.updateValue([[titleTextField.text!,balText,detailTextView.text!,date]], forKey: (category+"_"+month))
                        }else {
                            var newData: [[String]] = categoryData[category+"_"+month]!
                            newData.append([titleTextField.text!,balText,detailTextView.text!,date])
                            categoryData.updateValue(newData, forKey: (category+"_"+month))
                        }
                        index = categoryData[category+"_"+month]!.count - 1
                        userdefaults.set(userdefaults.integer(forKey: "bal")-changedBal,forKey: "bal")
                        if month != defaultMonth {
                            if categoryData["総計_"+month] == nil {
                                categoryData.updateValue([], forKey: "総計_"+month)
                            }
                            data = categoryData["総計_"+month]!
                            data.append(categoryData["総計_"+defaultMonth]![sumIndex])
                            categoryData.updateValue(data, forKey: "総計_"+month)
                            data = categoryData["総計_"+defaultMonth]!
                            data.remove(at: sumIndex)
                            categoryData.updateValue(data, forKey: "総計_"+defaultMonth)
                            sumIndex = categoryData["総計_"+month]!.count-1
                        }
                    }
                    
                    categoryData.updateValue([[String(Int(categoryData[category+"_"+month+"_sum"]![0][0])!+changedBal)]], forKey: category+"_"+month+"_sum")
                    var data: [[String]] = categoryData[category+"_"+month]!
                    data[index] = [titleTextField.text!,balText,detailTextView.text!,date]
                    categoryData.updateValue(data, forKey: (category+"_"+month))
                    
                    data = categoryData["総計_"+month]!
                    data[sumIndex] = [titleTextField.text!,balText,detailTextView.text!,date,category,String(index)]
                    categoryData.updateValue(data, forKey: "総計_"+month)
                    
                    userdefaults.set(userdefaults.integer(forKey: "bal")+changedBal,forKey: "bal")
                    
                    let view = self.presentingViewController as! detailLogViewController
                    view.categoryData = categoryData
                    view.reloadTable()
                    //リストを日付順で並び替える関数を実行(WIP)
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
    
    //日付選択Pickerの完了ボタンを押した時
    @objc func dateSelected() -> Bool {
        //選択した日付(年、月、日)と現在の日付(年、月、日)を取得
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd", options: 0, locale: Locale(identifier: "ja_JP"))
        var date: String = formatter.string(from: datePicker.date)
        let selectedYear: String = String(date.prefix(4))
        let selectedMonth: String = String(date.prefix(7).suffix(2))
        let selectedDay: String = String(date.suffix(2))
        let nowDate: String = formatter.string(from: dt)
        let nowYear: String = String(nowDate.prefix(4))
        let nowMonth: String = String(nowDate.prefix(7).suffix(2))
        let nowDay: String = String(nowDate.suffix(2))
        //もし選択した日付が未来の日付だったら
        if (Int(selectedYear)! > Int(nowYear)!) || (Int(selectedYear)! == Int(nowYear)! && Int(selectedMonth)! > Int(nowMonth)!) || (Int(selectedYear)! == Int(nowYear)! && Int(selectedMonth)! == Int(nowMonth)! && Int(selectedDay)! > Int(nowDay)!) {
            //現在の日付か編集前の日付に設定する
            if (new) {
                date = formatter.string(from: dt)
                datePicker.date = formatter.date(from: formatter.string(from: dt))!
            }else{
                datePicker.date = formatter.date(from: monthTxt)!
            }
            return false
        }else{
            //日付を反映する
            datePicker.date = formatter.date(from: date)!
            dateTextField.text = date
            month = String(date.prefix(7))
            self.view.endEditing(true)
            return true
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
