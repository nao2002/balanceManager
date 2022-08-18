//
//  LogViewController.swift
//  balanceManager
//
//  Created by なお on 2022/08/10.
//

import UIKit

class LogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monthButton: UIButton!
    var userdefaults = UserDefaults.standard
    
    var categoryList: [String] = [] //カテゴリー一覧の配列　文字列でカテゴリーが並ぶ(["食費","交通費"])
    
    /*カテゴリーそれぞれの詳細データ 年月とカテゴリー名で管理
     カテゴリーのその月の総計とその月のそのカテゴリーの詳細のデータ、その月の全ての詳細データがそれぞれある
     ・categoryData['\(categoryName)+"_"+\(month(yyyy/MM形式))+"_sum"']の時中身は
     [[その月の総計(String)]]なので、[0][0]のみを使用
     ・categoryData['\(categoryName)+"_"+\(month(yyyy/MM形式))']の時中身は
     [[詳細1つ目タイトル,詳細1つ目値段,詳細1つ目メモ,詳細1つ目日付],[詳細2つ目タイトル,詳細2つ目値段,詳細2つ目メモ,詳細2つ目日付]...]といった形で増える
     ・categoryData['\(month(yyyy/MM形式))']の時中身は
     [[詳細1つ目タイトル,詳細1つ目値段,詳細1つ目メモ,詳細1つ目日付,詳細1つ目カテゴリ,カテゴリ内でのIndex][詳細2つ目タイトル,詳細2つ目値段,詳細2つ目メモ,詳細2つ目日付,詳細2つ目カテゴリ,カテゴリ内でのIndex]...]といった形で増える
     おそらくこのアプリで一番データが多い。扱いに注意すべし
     */
    var categoryData: Dictionary<String,[[String]]> = [:]
    
    let dt = Date()
    let dateFormatter = DateFormatter()
    var month: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //テーブルビューの登録
        tableView.register(UINib(nibName: "logTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        //日付のフォーマット設定
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM", options: 0, locale: Locale(identifier: "ja_JP"))
        month = dateFormatter.string(from: dt)
        
        monthButton.setTitle(month, for: .normal)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //UserDefaultsを反映
        if userdefaults.array(forKey: "category") != nil {
            categoryList = userdefaults.array(forKey: "category") as! [String]
        }else {
            categoryList = ["食費","交通費","日用品費","医療費","雑費"]
            userdefaults.set(categoryList,forKey: "category")
        }
        if userdefaults.dictionary(forKey: "data") != nil {
            categoryData = userdefaults.dictionary(forKey: "data") as! Dictionary<String,[[String]]>
            print("data loaded")
            print(categoryData)
        }
    }
    
    //TableViewのセル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    //TableViewのセル設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! logTableViewCell
        cell.titleLabel.text = categoryList[indexPath.row]
        cell.dateLabel.text = ""
        
        if checkCategoryExist(month: month, category: categoryList[indexPath.row]) {
            cell.priceLabel.text = "¥ " + formattePrice(balance: Int(categoryData[categoryList[indexPath.row]+"_"+month+"_sum"]![0][0])!)
            if Int(categoryData[categoryList[indexPath.row]+"_"+month+"_sum"]![0][0])! > 0 {
                cell.priceLabel.textColor = UIColor.systemGreen
            }else if Int(categoryData[categoryList[indexPath.row]+"_"+month+"_sum"]![0][0])! == 0{
                cell.priceLabel.textColor = UIColor.black
            }else{
                cell.priceLabel.textColor = UIColor.red
            }
            
        }else {
            cell.priceLabel.text = "¥ 0"
            cell.priceLabel.textColor = UIColor.black
        }
        
        tableView.rowHeight = 81
        // セルに表示する値を設定する
        return cell
    }
    
    //TableViewのセルが押された時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップされたセルの行番号を出力
        print("\(indexPath.row)番目の行が選択されました。")
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 別の画面に遷移
        let next = storyboard!.instantiateViewController(withIdentifier: "detailLog")  as! detailLogViewController
        next.modalPresentationStyle = .fullScreen
        next.category = categoryList[indexPath.row]
        next.categoryList = categoryList
        next.categoryData = categoryData
        next.month = month
        present(next, animated: true, completion: nil)
    }
    
    //その月のカテゴリデータが存在しているか確認
    func checkCategoryExist(month:String,category:String) -> Bool{
        if categoryData.keys.contains(category+"_"+month+"_sum") {
            return true
        }else{
            return false
        }
    }
    
    //戻るボタン
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func previousMonth() {
        if Int(month.suffix(2)) == 1 {
            month = "\(String(format: "%04d", Int(month.prefix(4))!-1))/12"
        }else{
            month = "\(String(month.prefix(4)))/\(String(format: "%02d", Int(month.suffix(2))!-1))"
        }
        reloadTable()
    }
    
    @IBAction func nextMonth() {
        let nowMonth = dateFormatter.string(from: dt)
        if month == nowMonth {
            back()
        }else{
            if Int(month.suffix(2)) == 12 {
                month = "\(String(format: "%04d", Int(month.prefix(4))!+1))/01"
            }else{
                month = "\(String(month.prefix(4)))/\(String(format: "%02d", Int(month.suffix(2))!+1))"
            }
            reloadTable()
        }
    }
    
    //引数の数字を表示に,をつけて文字列で返す(1000 -> "1,000")
    func formattePrice(balance: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.groupingSize = 3
        let price = f.string(from: NSNumber(value: balance)) ?? "\(balance)"
        return price
    }
    
    func reloadTable() {
        tableView.reloadData()
        monthButton.setTitle(month, for: .normal)
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
