//
//  FavoriteTableViewController.swift
//  SearchLocationApp
//
//  Created by Константин Малков on 18.09.2022.
//
//This is demo view which will show users favorite location in table view

import UIKit

class FavoriteTableViewController: UITableViewController {

    let titleString = "Check title cell"
    
    let tableview: UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    let label: UILabel = {
       let label = UILabel()
        label.text = "This page in development by myself. Later there will be table view with favorite location by user"
        label.numberOfLines = 4
        label.font = UIFont(name: "Times New Roman", size: 24)
        return label
    }()
    
    @IBOutlet var tableViewStoryboard: UITableView?
    
    var textlabel: [String?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        tableViewStoryboard?.delegate = self
        tableViewStoryboard?.dataSource = self
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
        label.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 110)
    }
    
    @objc func didTapCancel(){
        dismiss(animated: true)
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = "Check"
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
