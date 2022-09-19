//
//  SearchViewController.swift
//  SearchLocationApp
//
//  Created by Константин Малков on 30.08.2022.
//
//This class is table view for collection data after searching and show result in table view cell

import UIKit
import CoreLocation

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ vc: SearchViewController, didSeletLocationWith coordinates: CLLocationCoordinate2D?)
}

class SearchViewController: UIViewController , UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource{

    weak var delegate: SearchViewControllerDelegate?
    
    private let label: UILabel = {
       let label = UILabel()
        label.text = "Where to?"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.sizeToFit()
        return label
    }()
    
    private let field : UITextField = {
       let field = UITextField()
        field.placeholder = "Enter destination"
        field.clearButtonMode = .always
        field.layer.cornerRadius = 9
        field.returnKeyType = .search
        field.backgroundColor = .tertiarySystemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        return field
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .secondarySystemBackground
        return table
    }()
    
    var locations = [Location]()
    
    override func viewDidLoad() {
        view.addSubview(label)
        view.addSubview(field)
        view.addSubview(tableView)
        view.backgroundColor = .secondarySystemBackground
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        field.delegate = self
        
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 10, y: 10, width: label.frame.size.width, height: label.frame.size.height)
        field.frame = CGRect(x: 10, y: 20+label.frame.size.height, width: view.frame.size.width-20, height: 50)
        let tableY: CGFloat = field.frame.origin.y+field.frame.size.height+5
        tableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height-tableY)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        if let text = field.text , !text.isEmpty {
            LocationManager.shared.findLocations(with: text) { [weak self]  locations in
                DispatchQueue.main.async {
                    self?.locations = locations
                    self?.tableView.reloadData()
                }
            }
        }
        return true
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = .secondarySystemBackground
        cell.backgroundColor = .secondarySystemBackground
        cell.textLabel?.text = locations[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let coordinate = locations[indexPath.row].coordinates
        delegate?.searchViewController(self, didSeletLocationWith: coordinate)
    }

}
