//
//  DetailViewController.swift
//  FienMaandag-pset5
//
//  Created by Fien Maandag on 15-05-17.
//  Copyright © 2017 Fien Maandag. All rights reserved.
//

import UIKit
import SQLite

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    private var database: Connection?
    static let todoList = Table("todoList")
    let idTodo = Expression<Int64>("idTodo")
    static let listId = Expression<Int64>("listId")
    let todo = Expression<String>("todo")
    var completed = Expression<Bool>("completed")
    
    var selectedListId: Int64?
    var selectedListName: String = ""
    var itemList = [(idTodo: Int64, listId: Int64, todo: String, completed: Bool)]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newTodo: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDatabase()
        print("6")
        loadData()
        
        
        print("7")
        print("8")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTodoButtonPressed(_ sender: Any) {
        addTodo()
        tableView.reloadData()
    }
    
    @IBAction func doneSwitch(_ sender: UISwitch) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        guard let cell = self.tableView.cellForRow(at: indexPath) as? TodoItemTableViewCell else {
            return
        }
        
        // update database
        let updateTodo = itemList[indexPath.row]
        let row = DetailViewController.todoList.filter(idTodo == updateTodo.idTodo)
        
        let value = sender.isOn
        
        do {
            cell.doneSwitch.setOn(value, animated: true)
            try database?.run(row.update(completed <- value))
        } catch{
            print("error1")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! TodoItemTableViewCell
        
        cell.todoLabel.text = itemList[indexPath.row].todo
        let value = itemList[indexPath.row].completed
        cell.doneSwitch.setOn(value, animated: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteList = itemList[indexPath.row]
            let removeList = DetailViewController.todoList.filter(idTodo == deleteList.idTodo)
            
            do {
                try database?.run(removeList.delete())
            }
            catch {
                // error handeling
                print("Could not remove: \(error)")
            }
            
            itemList.remove(at: indexPath.row)
            
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
            try database!.run(DetailViewController.todoList.create(ifNotExists: true){t in
                t.column(idTodo, primaryKey: .autoincrement)
                t.column(DetailViewController.listId)
                t.column(todo)
                t.column(completed)
            })
        }
        catch {
        // error handeling
        print("Cannot create table: \(error)")
        }
    }
    
    func loadData() {
        do{
            for todos in try database!.prepare(DetailViewController.todoList.filter(DetailViewController.listId == selectedListId!)){
                itemList.append((
                    idTodo: todos[idTodo],
                    listId: todos[DetailViewController.listId],
                    todo: todos[todo],
                    completed: todos[completed]
                    ))
            }
        }catch {
            // error handeling
            print("No data found: \(error)")
        }
    }
    
    func addTodo(){
        let insert = DetailViewController.todoList.insert(DetailViewController.listId <- selectedListId!, todo <- newTodo.text!, completed <- false)
        
        do {
            let rowId = try database!.run(insert)
            
            do {
                for todos in try database!.prepare(DetailViewController.todoList.filter(idTodo == rowId)){
                    itemList.append((
                        idTodo: todos[idTodo],
                        listId: todos[DetailViewController.listId],
                        todo: todos[todo],
                        completed: todos[completed]
                    ))
                    newTodo.text = nil
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

