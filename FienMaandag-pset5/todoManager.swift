//
//  todoManager.swift
//  FienMaandag-pset5
//
//  Created by Fien Maandag on 15-05-17.
//  Copyright © 2017 Fien Maandag. All rights reserved.
//

import Foundation

class TodoManager {
    private init() {}
    
    static let sharedInstance = TodoManager()

//    func setUpDatabase() {
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//    
//        do {
//            database = try Connection("\(path)/db.sqlite3")
//            createTable()
//        }
//        catch {
//            // error handeling
//            print("Cannot connect to database: \(error)")
//        }
//    }
//
//    func createTable() {
//        do {
//            try database!.run(todoList.create(ifNotExists: true){t in
//                t.column(idTodo, primaryKey: .autoincrement)
//                t.column(listId)
//                t.column(todo)
//                t.column(completed)
//            })
//        }
//        catch {
//        // error handeling
//        print("Cannot create table: \(error)")
//        }
//    }
    
//    func loadDataLists(list: Table) {
//        do{
//            for lists in try database!.prepare(list){
//                todoLists.append((
//                    idList: lists[idList],
//                    listName: lists[listName]
//                ))
//            }
//        }catch {
//            // error handeling
//            print("No data found: \(error)")
//        }
//    }
}
