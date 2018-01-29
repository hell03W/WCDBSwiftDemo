//
//  AddPersonController.swift
//  TestWCDB
//
//  Created by Walden on 2018/1/27.
//  Copyright © 2018年 Walden. All rights reserved.
//

import UIKit
import WCDBSwift
import SVProgressHUD

class AddPersonController: UIViewController {

    /// 此控制器的编辑类型
    ///
    /// - edit: 修改
    /// - add: 新增
    enum PersonEditType {
        case edit
        case add
    }
    
    var editType: PersonEditType = .add
    var person: Person?

    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var sexField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.text = person?.name
        sexField.text = person?.sex
        ageField.text = "\(person?.age ?? 0)"
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        
        guard let name = nameField.text,
            let sex = sexField.text,
            let ageText = ageField.text,
            let age = Int(ageText) else {
                
            return
        }
        let p = person ?? Person()
        p.name = name
        p.sex = sex
        p.age = age
        if editType == .add {
            //数据库中新增一个人物
            let db = Database(withPath: dbPath)
            try? db.create(table: "PersonTable", of: Person.self)
            try? db.insert(objects: p, intoTable: "PersonTable")
            SVProgressHUD.showSuccess(withStatus: "添加成功!")
        }
        else if editType == .edit {
            //修改一个数据库中的人物
            let db = Database(withPath: dbPath)
            try? db.create(table: "PersonTable", of: Person.self)
            try? db.update(table: "PersonTable",
                           on: Person.Properties.all,
                           with: p,
                           where: Person.Properties.id == p.id!.asExpression())
            SVProgressHUD.showSuccess(withStatus: "修改成功!")
        }
    }
    
    @IBAction func clearAction(_ sender: UIButton) {
        nameField.text = ""
        sexField.text = ""
        ageField.text = ""
    }
}



