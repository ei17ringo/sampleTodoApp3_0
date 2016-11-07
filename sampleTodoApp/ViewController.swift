//
//  ViewController.swift
//  sampleTodoApp
//
//  Created by Eriko Ichinohe on 2016/09/07.
//  Copyright © 2016年 Eriko Ichinohe. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    @IBOutlet weak var todoText: UITextField!
    
    @IBOutlet weak var todoList: UITableView!
    
    var todoArray:[[String: String]] = [[String: String]()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //既に保存されているデータを取り出し
        read()
    
    }

    //Todo登録ボタン
    @IBAction func addTodo(_ sender: UIButton) {
        //CoreDataに保存
        addData()
        
        //Notification設定
        setNotification()
        
        //TableViewに追加したデータを再設定
        read()
        todoList.reloadData()
    }
    
    // 行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoArray.count
    }
    
    // 表示するセルの中身
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "myCell")
        
        if todoArray[0].count != 0{
            cell.textLabel!.text = "\(todoArray[indexPath.row]["dueDate"]! as String)までに\(todoArray[indexPath.row]["todoText"]! as String)"
        }
        return cell
        
    }

    
    // すでに存在するデータの読み込み処理
    func read() {
        // AppDeleteをコードで読み込む
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Entityの操作を制御するmanagedObjectContextをappDelegateから作成
        if let managedObjectContext:NSManagedObjectContext = appDelegate.managedObjectContext {
            
            // Entityを指定する設定
            let entityDiscription = NSEntityDescription.entity(forEntityName: "Todo", in: managedObjectContext)
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
            fetchRequest.entity = entityDiscription
            
            // errorが発生した際にキャッチするための変数
            var error: NSError? = nil
            
            // フェッチリクエスト (データの検索と取得処理) の実行
            do {
                
                let myDateFormatter: DateFormatter = DateFormatter()
                myDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                myDateFormatter.locale     = Locale(identifier: "Japanese")
                
                
                let results = try managedObjectContext.fetch(fetchRequest)
                print(results.count)
                for managedObject in results {
                    let todo = managedObject as! Todo
                    
                    //日本時間に変換
                    let localeDate: String = myDateFormatter.string(from: todo.dueDate! as Date)
                    print("task: \(todo.task), dueDate: \(localeDate)")
                    
                    let dic:Dictionary = ["todoText":todo.task! as String,"dueDate":localeDate]
                    
                    if todoArray[0].count == 0{
                        todoArray[0] = dic
                    }else{
                        todoArray.append(dic)
                    }
                    
                }
            } catch let error1 as NSError {
                error = error1
            }
        }
    }
    
    func addData(){
        // AppDeleteをコードで読み込む
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
        // Entityの操作を制御するmanagedObjectContextをappDelegateから作成
        if let managedObjectContext:NSManagedObjectContext = appDelegate.managedObjectContext {
            
            // 新しくデータを追加するためのEntityを作成します
            let managedObject: AnyObject = NSEntityDescription.insertNewObject(forEntityName: "Todo", into: managedObjectContext)
            
            // Todo EntityからObjectを生成し、Attributesに接続して値を代入
            let todo = managedObject as! Todo
            todo.task = todoText.text
            todo.dueDate = dueDatePicker.date
            
         // データの保存処理
            appDelegate.saveContext()
            
        }
    }

    func setNotification(){
        
        // ローカル通知の設定
        let notification : UILocalNotification = UILocalNotification()
        
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        myDateFormatter.locale     = Locale(identifier: "Japanese")
        
        
        //日本時間に変換
        let localeDate: NSString = myDateFormatter.string(from: dueDatePicker.date) as NSString
        
        // タイトル
        notification.alertTitle = "締め切りが近づいています"
        
        // 通知メッセージ
        notification.alertBody = "通知:\(localeDate) \(todoText.text! as String)"
        
        // Timezoneの設定
        notification.timeZone = TimeZone.current
        
        // 締切1時間前に設定
        notification.fireDate = Date(timeInterval: -60*60, since: dueDatePicker.date)

        
        // Notificationを表示する
        UIApplication.shared.scheduleLocalNotification(notification)
        

    
    }

    @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
        todoText.resignFirstResponder()
    }
    
    //GestureRecognizerのdelegateをselfに設定して使用する
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer
        otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

