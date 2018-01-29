//
//  ViewController.swift
//  TestWCDB
//
//  Created by Walden on 2018/1/12.
//  Copyright © 2018年 Walden. All rights reserved.
//

import UIKit
import WCDBSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSHomeDirectory())
        
        
        baseOperation()
    }
    
    
    /// 基本的数据库操作
    func baseOperation() {
        
        do {
            let p1 = Person(name: "walden", sex: "male", age: 21)
            let p2 = Person(name: "healer", sex: "female", age: 20)
            
            let tableName = "PersonTable"
            
            //1.创建数据库
            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/wcdb.db"
            let db = Database(withPath: docPath + "/wcdb.db")
            
            //2.创建数据库表
            try db.create(table: tableName, of: Person.self)
            
            //3.插入数据
            try db.insert(objects: p1, p2, intoTable: tableName)
            
            //4.查找数据
            let objects: [Person]? = try? db.getObjects(fromTable: tableName)
            
            //5.更新操作
            let obj = objects!.first!
            obj.age = 30
//            try db.update(table: tableName, on: Person.Properties, with: obj)
            
            //6.删除操作
            try db.delete(fromTable: tableName)
        } catch {
            print(error)
        }
        
    }
}




