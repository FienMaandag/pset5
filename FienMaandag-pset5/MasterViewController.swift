//
//  MasterViewController.swift
//  FienMaandag-pset5
//
//  Created by Fien Maandag on 15-05-17.
//  Copyright © 2017 Fien Maandag. All rights reserved.
//

import UIKit
import SQLite

class MasterViewController: UITableViewController {

    @IBOutlet weak var newList: UITextField!
    
    var detailViewController: DetailViewController? = nil
    
    var todoLists = [(idList: Int64, listName: String)]()
    
    private var database: Connection?
    let list = Table("list")
    let idList = Expression<Int64>("idList")
    let listName = Expression<String>("listName")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDatabase()
        loadData()
        
        navigationItem.leftBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        addListToLists()
        tableView.reloadData()

    }
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let listName = todoLists[indexPath.row].listName
                let listId = todoLists[indexPath.row].idList
                print("1")
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                // can i delete this?
                // controller.detailItem = "hello!"
                print("2")
                controller.selectedListId = listId
                controller.selectedListName = listName
                print("3")
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                print("4")
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = todoLists[indexPath.row].listName
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteList = todoLists[indexPath.row]
            let removeList = list.filter(idList == deleteList.idList)
            let removeTodos = DetailViewController.todoList.filter(DetailViewController.listId == deleteList.idList)
            
            do {
                try database?.run(removeList.delete())
            }
            catch {
                // error handeling
                print("Could not remove: \(error)")
            }
            
            todoLists.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func setUpDatabase() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            database = try Connection("\(path)/db.sqlite3")
            createTable()
        }
        catch {
            // error handeling
            print("Cannot connect to database: \(error)")
        }
    }
    
    func createTable() {
        do {
            try database!.run(list.create(ifNotExists: true) {t in
                t.column(idList, primaryKey: .autoincrement)
                t.column(listName)
            })
        }
        catch {
            // error handeling
            print("Cannot create table: \(error)")
        }
    }
    
    func loadData() {
        do{
            for lists in try database!.prepare(list){
                todoLists.append((
                    idList: lists[idList],
                    listName: lists[listName]
                ))
            }
        }catch {
            // error handeling
            print("No data found: \(error)")
        }
    }
    
    func addListToLists(){
        let insert = list.insert(listName <- newList.text!)
        
        do {
            let rowId = try database!.run(insert)
            
            do {
                for list in try database!.prepare(list.filter(idList == rowId)){
                    todoLists.append((
                        idList:   list[idList],
                        listName: list[listName]
                    ))
                    newList.text = nil
                }
            } catch{
                // error handeling
                print("Could not search in database: \(error)")
            }
            
        } catch{
            // error handeling
            print("Error creating to do: \(error)")
        }
    }
    


}

