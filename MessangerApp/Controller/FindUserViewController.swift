//
//  FindUserViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 6/14/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit

class FindUserViewController: UIViewController {

    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = false
        view.addSubview(tableView)
        let resetIcon = UIImage(systemName: "arrow.clockwise")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: resetIcon, style: .done, target: self, action: #selector(hello))
        // Do any additional setup after loading the view.
    }
    
    @objc private func hello(){
        print("hi")
        return
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
//
//extension FindUserViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
//        for: indexPath) as! ConversationTableViewCell
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
//    }
//}
