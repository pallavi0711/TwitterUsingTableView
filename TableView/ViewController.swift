//
//  ViewController.swift
//  TableView
//
//  Created by Admin on 14/03/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    var filteredData = [UserData]()
    
    var searchtext:String = "trump" //temp text
    
    var isSearching = false
    
    private var request:Request?
    var users:[UserData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.rowHeight = 130
        tableview.estimatedRowHeight = UITableViewAutomaticDimension
        
        tableview.delegate = self
        tableview.dataSource = self
        searchbar.delegate = self
        
        searchbar.returnKeyType = UIReturnKeyType.done
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        request = Request(search: "\(searchtext)", count: 20)
        
        request?.fetch({ (newTweets) in
            
            let dictionary = newTweets as? [String: AnyObject]
            
            let userData = dictionary!["statuses"] as? [AnyObject]
            
            print("user data \(String(describing: userData!))")
            
          
            if self.isSearching {
                
                for user in userData!
                {
                    let userDetails = user.value(forKey: "user") as? [String:Any]
                    
                    let date: String = userDetails!["created_at"] as! String
                    let substring = date[date.startIndex..<date.index(date.startIndex, offsetBy:10)]
                    let temp:String = String(substring)
                    
                    self.filteredData.insert(UserData(name:(userDetails!["name"] as? String)!,description:(userDetails!["description"] as? String)!,date:temp, imageUrl:(userDetails!["profile_image_url"] as? String)!),at:0)
                    
                    print(self.filteredData)
                }
            }
            else
            {
                for user in userData!
                {
                    let userDetails = user.value(forKey: "user") as? [String:Any]
                    
                    let date: String = userDetails!["created_at"] as! String
                    let substring = date[date.startIndex..<date.index(date.startIndex, offsetBy:10)]
                    let temp:String = String(substring)
                    self.users.append(UserData(name:(userDetails!["name"] as? String)!,description:(userDetails!["description"] as? String)!,date:temp, imageUrl:(userDetails!["profile_image_url"] as? String)!))
                    
                    print(self.users)
                    
                }
                
            }
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching{
            return filteredData.count
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! CustomTableViewCell

        if isSearching{
            
            cell.title.text = filteredData[indexPath.row].name
            cell.date.text = filteredData[indexPath.row].date
            cell.Description.text = filteredData[indexPath.row].description
            
            let imageUrl = URL(string:filteredData[indexPath.row].imageUrl)
            
            URLSession.shared.dataTask(with: imageUrl!, completionHandler: { (data, response, err) in
                
                if let newImage = data {
                    
                    DispatchQueue.main.async {
                        cell.profile_image.image = UIImage(data : newImage)
                    }
                }
            }).resume()
            
        }else{
            
            cell.title.text = users[indexPath.row].name
            cell.date.text = users[indexPath.row].date
            cell.Description.text = users[indexPath.row].description
            
            let imageUrl = URL(string:users[indexPath.row].imageUrl)
            
            URLSession.shared.dataTask(with: imageUrl!, completionHandler: { (data, response, err) in
                
                if let newImage = data {
                    
                    DispatchQueue.main.async {
                        cell.profile_image.image = UIImage(data : newImage)
                    }
                }
            }).resume()

        }
       return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchtext = searchbar.text!
        tableview.reloadData()
        viewWillAppear(true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchbar.text == nil || searchbar.text == "" {
            
            isSearching = false
            
            view.endEditing(true)
            tableview.reloadData()
        }else{
            
            isSearching = true
        
            // filteredData = users.filter({$0 == searchBar.text})
        }
        
    }
}
