//
//  CategoryViewController.swift
//  ToDoList
//
//  Created by Margareta Mudrikova on 12/10/2020.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
         guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        
        setAppearance(for: navBar)
    }
    

//MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
            if let category = categories?[indexPath.row] {
                cell.textLabel?.text = category.name
                
                guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
                
                cell.backgroundColor = categoryColor
                cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            
        } else {
            cell.textLabel?.text = "No Categories added yet"
        }
        
        return cell
    }
    
    
//MARK: - TableView Delegate Methods
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController

        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
//MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
    
            if textField.text != "" {
                let newCategory = Category()
                newCategory.name = textField.text!
                newCategory.color = UIColor.randomFlat().hexValue()
                
                self.save(category: newCategory)
            } else {
                return
            }
         
        }
        
        alert.addTextField { (field) in
            field.autocapitalizationType = .sentences
            field.placeholder = "Create New Category"
            textField = field
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
//MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion.items)
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    //Edit Data From Swipe
    
    override func editModel(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
          
            if textField.text != "" {
                if let category = self.categories?[indexPath.row] {
                    do{
                        try self.realm.write {
                            category.name = textField.text!
                            self.tableView.reloadData()
                        }
                    }
                    catch{
                        print("Error Editing category, \(error)")
                    }
                }
            } else {
                return
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.autocapitalizationType = .sentences
            alertTextField.text = self.categories?[indexPath.row].name
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
 
//MARK: - Navigation Bar Appearance
    
    func setAppearance(for navBar: UINavigationBar ) {
        
        let navigationBar = UINavigationBarAppearance()
        navigationBar.configureWithOpaqueBackground()
        navigationBar.backgroundColor = ColorManager.toDoWhiteColor
        navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorManager.toDoDarkColor ?? .black]
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorManager.toDoDarkColor ?? .black]
        
        navBar.standardAppearance = navigationBar
        navBar.compactAppearance = navigationBar
        navBar.scrollEdgeAppearance = navigationBar
        
        navBar.tintColor = ColorManager.toDoDarkColor
    }
    
 
    //MARK:- Custom Color Manager
    struct ColorManager {
        static let toDoWhiteColor = UIColor(hexString: "F7FCFF")
        static let toDoDarkColor = UIColor(hexString: "4077A1")
    }
    
}




