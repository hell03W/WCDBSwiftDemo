//
//  TableViewController.swift
//  TestWCDB
//
//  Created by Walden on 2018/1/27.
//  Copyright © 2018年 Walden. All rights reserved.
//

import UIKit
import WCDBSwift
import SVProgressHUD

let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/wcdb.db"

class TableViewController: UITableViewController {
    
    /// 初始化一个searchbar
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        searchBar.delegate = self
        searchBar.placeholder = "输入想要搜索的名字"
        searchBar.setShowsCancelButton(true, animated: true)
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = searchBar
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        setupRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pulldownAction()
    }
    
    /// 配置下拉刷新
    func setupRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pulldownAction), for: .valueChanged)
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
    }
    
    @objc func pulldownAction() {
        let text = searchBar.text ?? ""
        dataArray = searchFor(text)
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    func searchFor(_ name: String = "") -> [Person]? {
        let db = Database(withPath: dbPath)
        let persons: [Person]? = try? db.getObjects(on: Person.Properties.all, fromTable: "PersonTable", where: Person.Properties.name.like("%\(name)%"))
        return persons
    }

    var dataArray: [Person]?

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        if let person = dataArray?[indexPath.row] {
            cell.textLabel?.text = "\(person.name ?? "")-\(person.sex ?? "")-\(person.age ?? 0)"
        }
        return cell
    }
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "删除") { (action, indexPath) in
            self.deleteAction(indexPath: indexPath)
        }
        let editAction = UITableViewRowAction(style: .default, title: "编辑") { (action, indexPath) in
            self.editAction(indexPath: indexPath)
        }
        return [deleteAction, editAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// 删除动作
    func deleteAction(indexPath: IndexPath) {
        let cancleAction = UIAlertAction(title: "取消", style: .cancel)
        let confirmAction = UIAlertAction(title: "确定", style: .default) { (action) in
            let p = self.dataArray?[indexPath.row]
            let db = Database(withPath: dbPath)
            let exp = Person.Properties.id == p!.id!.asExpression()
            try? db.delete(fromTable: "PersonTable", where: exp)
            SVProgressHUD.showSuccess(withStatus: "删除成功!")
            self.dataArray?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let alert = UIAlertController(title: "", message: "是否删除?", preferredStyle: .alert)
        alert.addAction(cancleAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// 编辑动作
    func editAction(indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let editController = sb.instantiateViewController(withIdentifier: "AddPersonController") as? AddPersonController {
            editController.title = "编辑"
            editController.editType = .edit
            editController.person = dataArray?[indexPath.row]
            navigationController?.pushViewController(editController, animated: true)
        }else{
            print("Cant find VC!")
        }
    }
}



extension TableViewController: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataArray = searchFor(searchText)
        tableView.reloadData()
    }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}






