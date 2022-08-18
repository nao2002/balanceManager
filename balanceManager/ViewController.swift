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
            payDay = 25
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
    
    //カテゴリー編集
    @IBAction func manageCategory() {
        print("push category")
    }
    
    //切り替え日変更
    @IBAction func managePayDay() {
        print("push payday")
    }
    
    
    //UDリセット用
    func resetData() {
        userdefaults.removeObject(forKey: "bal")
        userdefaults.removeObject(forKey: "payDay")
        userdefaults.removeObject(forKey: "category")
        userdefaults.removeObject(forKey: "data")
    }


}
