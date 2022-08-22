//
//  ViewController.swift
//  balanceManager
//
//  Created by なお on 2022/08/10.
//

import UIKit

class ViewController: UIViewController {
    var userdefaults = UserDefaults.standard
    @IBOutlet weak var balButton: UIButton!
    var balance: Int = 0 //残高総計
    var payDay: Int = 1 //切り替え日(この日から次の月扱い)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        resetData()
        loadUD()
        setBal(0)
        print("viewdidappear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        setUD()
    }
    
    //UserDefaultsデータロード
    func loadUD() {
        balance = userdefaults.integer(forKey: "bal")
        if userdefaults.integer(forKey: "payDay") != 0 {
            payDay = userdefaults.integer(forKey: "payDay")
        }else{
            payDay = 1
            userdefaults.set(payDay, forKey: "payDay")
        }
    }
    
    //Userdefaultsデータセット
    func setUD() {
        userdefaults.set(balance, forKey: "bal")
        userdefaults.set(payDay, forKey: "payDay")
    }
    
    //balanceをもらった引数分変更&フォーマットしてテキスト部分に表示
    public func setBal(_ change: Int) {
        balance += change
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.groupingSize = 3
        let price = f.string(from: NSNumber(value: balance)) ?? "\(balance)"
        balButton.setTitle("¥ " + price, for: .normal)
    }
    
    //詳細一覧へ
    @IBAction func checkBal() {
        print("push checkBal")
        let next = storyboard!.instantiateViewController(withIdentifier: "log")  as! LogViewController
        next.modalPresentationStyle = .fullScreen
        present(next, animated: true, completion: nil)
    }
    
    //収支管理の追加
    @IBAction func addChange() {
        print("push add")
        let next = storyboard!.instantiateViewController(withIdentifier: "changeBal")  as! changeBalViewController
        present(next, animated: true, completion: nil)
    }
    
    //データ出力
    @IBAction func exportData() {
        if userdefaults.dictionary(forKey: "data") != nil {
            let documentDirectoryUrl = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first!
            let fileUrl = documentDirectoryUrl.appendingPathComponent("data.txt")
            var savedData: String = "\(balance),\(payDay),{"
            let dicData: Dictionary<String,[[String]]> = userdefaults.dictionary(forKey: "data") as! Dictionary<String,[[String]]>
            for key in dicData.keys {
                savedData += "\"\(String(key))\":"
                var strData = "["
                for i in 0..<dicData[key]!.count {
                    strData += "\(dicData[key]![i])"
                    if i != dicData[key]!.count-1 {
                        strData += ","
                    }
                }
                savedData += strData + "],"
            }
            savedData.removeLast(1)
            savedData += "}"
            print(savedData)
            try! savedData.data(using: .utf8)!.write(to: fileUrl, options: .atomic)
            
            let alert: UIAlertController = UIAlertController(title: "出力完了", message: "データの出力が完了しました", preferredStyle: .alert)
            let alertAction1 = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction1)
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert: UIAlertController = UIAlertController(title: "出力失敗", message: "データが存在しません\n出力に失敗しました", preferredStyle: .alert)
            let alertAction1 = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction1)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func readDataButton() {
        
        /// ①DocumentsフォルダURL取得
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("フォルダ取得エラー")
            return
        }
        
        /// ②対象のファイルURL取得
        let fileURL = dirURL.appendingPathComponent("data.txt")
        
        /// ③ファイルの読み込み
        guard var fileContents = try? String(contentsOf: fileURL) else {
            print("ファイル取得エラー")
            return
        }
        
        let alert: UIAlertController = UIAlertController(title: "確認", message: "データを読み込みます\n元々のデータは上書きされます\n本当によろしいですか？", preferredStyle: .alert)
        let alertAction1 = UIAlertAction(title: "OK", style: .default, handler: {_ in self.readData(data: fileContents)})
        let alertAction2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(alertAction1)
        alert.addAction(alertAction2)
        self.present(alert, animated: true, completion: nil)
        
        }
    
    func readData(data: String) {
        var fileContents = data
        var textIndex = fileContents.firstIndex(of: ",")
        let replaceBalance = Int(String(fileContents.prefix(textIndex!.utf16Offset(in: fileContents))))!
        
        fileContents = String(fileContents.suffix(fileContents.count-textIndex!.utf16Offset(in: fileContents)-1))
        textIndex = fileContents.firstIndex(of: ",")
        let replacePayDay = Int(String(fileContents.prefix(textIndex!.utf16Offset(in: fileContents))))!
        
        fileContents = String(fileContents.suffix(fileContents.count-textIndex!.utf16Offset(in: fileContents)-1))
        let dicData = fileContents.data(using: .utf8)!
        do {
            let dic = try JSONSerialization.jsonObject(with: dicData) as? [String:Any]
            userdefaults.set(dic, forKey: "data")
            balance = replaceBalance
            payDay = replacePayDay
            setBal(0)
        }catch{
            print("error loading data")
            let alert: UIAlertController = UIAlertController(title: "読み込み失敗", message: "データの読み込み時にエラーが発生しました", preferredStyle: .alert)
            let alertAction1 = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction1)
            self.present(alert, animated: true, completion: nil)
            return
        }
        print(fileContents)
        setUD()
        
        let alert: UIAlertController = UIAlertController(title: "読み込み完了", message: "データの読み込みが完了しました", preferredStyle: .alert)
        let alertAction1 = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction1)
        self.present(alert, animated: true, completion: nil)

    }
    
    
    //UDリセット用
    func resetData() {
        userdefaults.removeObject(forKey: "bal")
        userdefaults.removeObject(forKey: "payDay")
        userdefaults.removeObject(forKey: "category")
        userdefaults.removeObject(forKey: "data")
    }
    
    
}
