//
//  NewConversationViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 8/31/20.
//  Copyright © 2020 choi jun hyung. All rights reserved.
//

import UIKit
import JGProgressHUD

final class NewConversationViewController: UIViewController {
    
    public var completion: ((SearchResult) -> (Void))?
    
    private let spinner = JGProgressHUD()
    
    private var users = [[String:String]]()
    private var results = [SearchResult]()
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    private var hasFetched = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        //searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationCell.self,
                       forCellReuseIdentifier: NewConversationCell.identifier)
        return table
    }()
    private func setColor() {
        guard let theme = UserDefaults.standard.value(forKey: "theme") as? String else {
            primary = UIColor(named: "whiteThemePrimary")!
            secondary = UIColor(named: "whiteThemeSecondary")!
            third = UIColor(named: "whiteThemeBackgroundColor")!
            textcolor = UIColor(named: "whiteThemeText")!
            return
        }
        if (theme == "orange") {
            primary = UIColor(named: "OrangePri")!
            secondary = UIColor(named: "OrangeSec")!
            third = UIColor(named: "OrangeThi")!
            textcolor = UIColor(named: "OrangeTex")!
        } else if (theme == "pink") {
            primary = UIColor(named: "mainThemePrimary")!
            secondary = UIColor(named: "mainThemeSecondary")!
            third = UIColor(named: "mainThemeThird")!
            textcolor = UIColor(named: "mainThemeText")!
        } else {
            primary = UIColor(named: "whiteThemePrimary")!
            secondary = UIColor(named: "whiteThemeSecondary")!
            third = UIColor(named: "whiteThemeBackgroundColor")!
            textcolor = UIColor(named: "whiteThemeText")!
        }
    }
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textColor = .secondarySystemBackground
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColor()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        view.backgroundColor = third
        self.tableView.backgroundColor = third
        self.tableView.tableFooterView = UIView()
        noResultsLabel.textColor = textcolor
        searchBar.backgroundColor = secondary
        searchBar.tintColor = primary
        tableView.delegate = self
        tableView.dataSource = self
        let att = NSAttributedString(string: "Search For Users...", attributes: [NSAttributedString.Key.foregroundColor: primary])
        searchBar.searchTextField.attributedPlaceholder = att
        searchBar.searchTextField.textColor = primary
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height - 200)/2,
                                      width: view.width/2,
                                      height: 200)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier, for: indexPath) as! NewConversationCell
        cell.configure(with: model)
        cell.backgroundColor = third
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            
            self?.completion?(targetUserData)
        })
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        if hasFetched {
            filterUsers(with: query)
        }
        else {
            var verifiedUsers = [[String:String]]()
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    
                    DatabaseManager.shared.getVerified { list in
                    for num in list {
                        verifiedUsers.append(usersCollection[num])
                    }
                    self?.hasFetched = true
                    self?.users = verifiedUsers
                    self?.filterUsers(with: query)
                }
                    
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            } )
        }
    }
    func filterUsers(with term: String) {
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        self.spinner.dismiss()
        
        //here
        DatabaseManager.shared.checkBlock { (bool) in
            if (bool) {
                print("he")
                DatabaseManager.shared.getBlock { (list) in
                    let results: [SearchResult] = self.users.filter({
                        guard let email = $0["email"],
                            email != safeEmail else {
                                return false
                        }
                        
                        guard let name = $0["name"]?.lowercased() else {
                            return false
                        }
                        
                        return name.hasPrefix(term.lowercased())
                        }).compactMap({
                            
                            guard let email = $0["email"],
                                let name = $0["name"] else {
                                return nil
                            }
                            if (list.contains(email)) {
                                return nil
                            }
                            return SearchResult(name: name, email: email)
                        })
                    
                    self.results = results
                    
                    self.updateUI()
                }
                
            } else {
                print("h")
                let results: [SearchResult] = self.users.filter({
                    guard let email = $0["email"],
                        email != safeEmail else {
                            return false
                    }
                    
                    guard let name = $0["name"]?.lowercased() else {
                        return false
                    }
                    
                    return name.hasPrefix(term.lowercased())
                    }).compactMap({
                        
                        guard let email = $0["email"],
                            let name = $0["name"] else {
                            return nil
                        }
                        
                        return SearchResult(name: name, email: email)
                    })
                
                self.results = results
                
                self.updateUI()
            }
        }
        
        
    }
    
    func updateUI(){
        if results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
            
            
        } else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
        
    }
}


