//
//  detailLogViewController.swift
//  balanceManager
//
//  Created by なお on 2022/08/16.
//

import UIKit

class detailLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryNameButton: UIButton!
    var userdefaults = UserDefaults.standard
    var category: String = ""//現在のカテゴリー
    var categoryList: [String]! //カテゴリーの一覧
    
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
    
    var month: String = ""
    
    var changed: Bool = false //データが編集されたか
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "logTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        // Do any additional setup after loading the view.
        
        //カテゴリー変更ボタン設定
        var items: [UIAction] = []
        for i in 0..<categoryList.count {
            items.append(UIAction(title: categoryList[i], handler: { _ in
                self.category = self.categoryList[i]
                self.categoryNameButton.setTitle("\(self.month)-\(self.categoryList[i])", for: .normal)
                self.reloadTable()
            }))
        }
        categoryNameButton.menu = UIMenu(options: .displayInline, children: items)
        categoryNameButton.showsMenuAsPrimaryAction = true
        categoryNameButton.setTitle("\(month)-\(category)", for: .normal)
    }
    
    //TableViewのセル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int = 0
        //カテゴリーのデータが存在しているか確認
        if categoryData[category+"_"+month] != nil {
            count = categoryData[category+"_"+month]!.count
        }
        return count
    }
    
    //TableViewのセル設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! logTableViewCell
        cell.titleLabel.text = categoryData[category+"_"+month]![indexPath.row][0]
        cell.dateLabel.text = categoryData[category+"_"+month]![indexPath.row][3]
        
        cell.priceLabel.text = "¥ " + formattePrice(balance: Int(categoryData[category+"_"+month]![indexPath.row][1])!)
        if Int(categoryData[category+"_"+month]![indexPath.row][1])! > 0 {
            cell.priceLabel.textColor = UIColor.systemGreen
        }else if Int(categoryData[category+"_"+month]![indexPath.row][1])! == 0{
            cell.priceLabel.textColor = UIColor.black
        }else{
            cell.priceLabel.textColor = UIColor.red
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
        let next = storyboard!.instantiateViewController(withIdentifier: "changeBal")  as! changeBalViewController
        next.new = false
        next.index = indexPath.row
        next.category = category
        next.monthTxt = ("\(String(month.prefix(4)))/\(String(month.suffix(2)))/\(String(categoryData[category+"_"+month]![indexPath.row][3].suffix(2)))")
        next.defaultMonth = month
        next.titleTxt = categoryData[category+"_"+month]![indexPath.row][0]
        next.priceTxt = categoryData[category+"_"+month]![indexPath.row][1]
        next.detailTxt = categoryData[category+"_"+month]![indexPath.row][2]
        next.defaultCategory = category
        present(next, animated: true, completion: nil)
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
    
    @IBAction func back() {
        if changed {
            let view = self.presentingViewController as! LogViewController
            view.reloadTable()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func reloadTable() {
        changed = true
        tableView.reloadData()
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
