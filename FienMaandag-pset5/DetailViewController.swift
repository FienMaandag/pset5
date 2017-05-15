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
    let todoList = Table("todoList")
    let idTodo = Expression<Int64>("idTodo")
    let listId = Expression<Int64>("listId")
    let todo = Expression<String>("todo")
    var completed = Expression<Bool>("completed")
    
    var selectedListId: Int64 = 0
    var selectedListName: String = ""
    var itemList = [(idTodo: Int64, listId: Int64, todo: String, completed: Bool)]()

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newTodo: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDatabase()
        print("6")
        loadData()
        print("7")
        // can i delete this?
        configureView()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! TodoItemTableViewCell
        
        cell.todoLabel.text = itemList[indexPath.row].todo
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteList = itemList[indexPath.row]
            let removeList = todoList.filter(idTodo == deleteList.idTodo)
            
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
            try database!.run(todoList.create(ifNotExists: true){t in
                t.column(idTodo, primaryKey: .autoincrement)
                t.column(listId)
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
            for todos in try database!.prepare(todoList.filter(listId == selectedListId)){
                itemList.append((
                    idTodo: todos[idTodo],
                    listId: todos[listId],
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
        let insert = todoList.insert(listId <- selectedListId, todo <- newTodo.text!, completed <- false)
        
        do {
            let rowId = try database!.run(insert)
            
            do {
                for todos in try database!.prepare(todoList.filter(idTodo == rowId)){
                    itemList.append((
                        idTodo: todos[idTodo],
                        listId: todos[listId],
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

    // can i delete this?
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    // can i delete this?
    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }

}

