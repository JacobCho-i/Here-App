import UIKit
import FirebaseAuth
import JGProgressHUD

class ExperimentViewController: UITableViewController {
    
    private var emailList:[String] = []
    private var nameList:[String] = []
    private var numList:[Int] = []
    private var notColored = true
    
    private let spinners = JGProgressHUD(style: .dark)
    
    private let noUsersLabel: UILabel = {
        let label = UILabel()
        label.text = "No User found. Please come back later!"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    override func viewDidLoad() {
        setColor()
        reloadUsers()
        self.navigationController?.tabBarItem.badgeColor = primary
        noUsersLabel.textColor = primary
        noUsersLabel.frame = CGRect(x: 10, y: (view.height-100)/2, width: view.width-20, height: 100)
        view.addSubview(noUsersLabel)
        tableView.separatorColor = .clear
        view.backgroundColor = secondary
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        let image = UIImage(systemName: "arrow.clockwise")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(reloadUsers))
        navigationItem.title = "Find Users"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        tableView.reloadData()
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        tableView.tintColor = primary
        navigationItem.rightBarButtonItem?.tintColor = primary
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setColor()
        self.navigationController?.navigationBar.isHidden = false
    }
    
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    @objc func reloadUsers() {
        tableView.isUserInteractionEnabled = true
        self.spinners.dismiss()
        self.spinners.show(in: view)
        numList = []
        nameList = ["","","","","","","",""]
        emailList = ["","","","","","","",""]
        var users = 0
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("reloading")
        DatabaseManager.shared.getAllUsers { result in
            switch result {
            case .success(let user):
                print("reload user successful")
                var total = user.count
                guard total != 1 else {
                    //self.tableView.isHidden = true
                    self.noUsersLabel.isHidden = false
                    return
                }
                DatabaseManager.shared.setUserID { (result) in
                    switch result {
                    case .success(let num):
                        print("received num")
                        users = num as! Int
                        if !email.hasPrefix("demo-mode") {
                            var totalList = [Int]()
                        DatabaseManager.shared.getMyID { (myID) in
                            DatabaseManager.shared.getDeletedUsers { (list) in
                                DatabaseManager.shared.getVerified { (list2) in
                                    for index in list2 {
                                        totalList.append(index)
                                    }
                                    print("\(totalList.count) \(myID) \(totalList.contains(myID))")
                                    if totalList.contains(myID) {
                                        if let newIndex = totalList.firstIndex(of: myID) {
                                        totalList.remove(at: newIndex)
                                        }
                                    }
                                    for index in list {
                                        print("\(index) \(totalList.contains(index))")
                                        if totalList.contains(index) {
                                            if let newIndex = totalList.firstIndex(of: index) {
                                            totalList.remove(at: newIndex)
                                            }
                                        }
                                    }
                                    DatabaseManager.shared.checkBlock(completion: { (bool) in
                                    if (bool) {
                                        DatabaseManager.shared.getBlockId { (list3) in
                                            
                                            for index in list3 {
                                                if totalList.contains(index) {
                                                    if let newIndex = totalList.firstIndex(of: index) {
                                                    totalList.remove(at: newIndex)
                                                    }
                                                }
                                            }
                                            total = totalList.count
                                            if total > 8 {
                                                total = 8 }
                                            print(total-1)
                                            print("total1 : \(total)")
                                            for num in 0...total-1 {
                                                    var randomUser = Int.random(in: 0...users-1)
                                                while(myID == randomUser || self.numList.contains(randomUser) || list.contains(randomUser) || !list2.contains(randomUser) || list3.contains(randomUser)) {
                                                            randomUser = Int.random(in: 0...users-1)
                                                    }
                                                    self.numList.append(randomUser)
                                                    DatabaseManager.shared.findUser(index: randomUser) { (name) in
                                                        self.nameList.insert(name, at: num)
                                                        DatabaseManager.shared.getEmail(index: randomUser) { (email) in
                                                            while(email == " ") {
                                                                randomUser = Int.random(in: 0...users-1)
                                                            }
                                                            self.emailList.insert(email, at: num)
                                                            let profilePic = UIImageView()
                                                            profilePic.image = UIImage(systemName: "person.circle")
                                                            profilePic.tintColor = self.primary
                                                            self.tableView.reloadData()
                                                            self.spinners.dismiss()
                                                    }}}}} else {
                                        total = totalList.count
                                        print("total \(total)")
                                        if total > 8 {
                                            total = 8
                                        }
                                        print("total after \(total)")
                                        for num in 0...total-1 {
                                                var randomUser = Int.random(in: 0...users-1)
                                                while(myID == randomUser || self.numList.contains(randomUser) ||  list.contains(randomUser) || !list2.contains(randomUser)) {
                                                        randomUser = Int.random(in: 0...users-1)
                                                        //print("\(randomUser) \(myID == randomUser) \(self.numList.contains(randomUser)) \(list.contains(randomUser)) \(!list2.contains(randomUser))")
                                                }
                                                print("user id: \(randomUser)")
                                                self.numList.append(randomUser)
                                                DatabaseManager.shared.findUser(index: randomUser) { (name) in
                                                    self.nameList.insert(name, at: num)
                                                    DatabaseManager.shared.getEmail(index: randomUser) { (email) in
                                                        while(email == " ") {
                                                            randomUser = Int.random(in: 0...users-1)
                                                        }
                                                        self.emailList.insert(email, at: num)
                                                        let profilePic = UIImageView()
                                                        profilePic.image = UIImage(systemName: "person.circle")
                                                        profilePic.tintColor = self.primary
                                                        self.tableView.reloadData()
                                                        self.spinners.dismiss()
                                                }}}}})
                                }}}} else {
                            print("we on demo mode")
                            var totalList = [Int]()
                            DatabaseManager.shared.getDeletedUsers { (list) in
                                DatabaseManager.shared.getVerified { (list2) in
                                    for index in list2 {
                                        if !totalList.contains(index) {
                                            totalList.append(index)
                                        }
                                    }
                                    DatabaseManager.shared.checkBlock(completion: { (bool) in
                                    if (bool) {
                                        DatabaseManager.shared.getBlockId { (list3) in
                                            for index in list {
                                                if totalList.contains(index) {
                                                    if let newIndex = totalList.firstIndex(of: index) {
                                                    totalList.remove(at: newIndex)
                                                    }
                                                }
                                            }
                                            for index in list3 {
                                                if totalList.contains(index) {
                                                    if let newIndex = totalList.firstIndex(of: index) {
                                                    totalList.remove(at: newIndex)
                                                    }
                                                }
                                            }
                                            total = totalList.count
                                            if total > 8 {
                                                total = 8
                                            }
                                            print("total3 : \(total)")
                                            for num in 0...total-1 {
                                                    var randomUser = Int.random(in: 0...users-1)
                                                while(self.numList.contains(randomUser) || list.contains(randomUser) || !list2.contains(randomUser) || list3.contains(randomUser)) {
                                                            randomUser = Int.random(in: 0...users-1)
                                                    }
                                                    self.numList.append(randomUser)
                                                    DatabaseManager.shared.findUser(index: randomUser) { (name) in
                                                        self.nameList.insert(name, at: num)
                                                        DatabaseManager.shared.getEmail(index: randomUser) { (email) in
                                                            while(email == " ") {
                                                                randomUser = Int.random(in: 0...users-1)
                                                            }
                                                            self.emailList.insert(email, at: num)
                                                            let profilePic = UIImageView()
                                                            profilePic.image = UIImage(systemName: "person.circle")
                                                            profilePic.tintColor = self.primary
                                                            self.tableView.reloadData()
                                                            self.spinners.dismiss()
                                                           
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        print("here then?")
                                        for index in list {
                                            if totalList.contains(index) {
                                                if let newIndex = totalList.firstIndex(of: index) {
                                                totalList.remove(at: newIndex)
                                                }
                                            }
                                        }
                                        total = totalList.count
                                        if total > 8 {
                                            total = 8
                                        }
                                        print("total4 : \(total)")
                                        for num in 0...total-1 {
                                            
                                                var randomUser = Int.random(in: 0...users-1)
                                                while(self.numList.contains(randomUser) || list.contains(randomUser) || !list2.contains(randomUser)) {
                                                        randomUser = Int.random(in: 0...users-1)
                                                }
                                                self.numList.append(randomUser)
                                                DatabaseManager.shared.findUser(index: randomUser) { (name) in
                                                    self.nameList.insert(name, at: num)
                                                    DatabaseManager.shared.getEmail(index: randomUser) { (email) in
                                                        while(email == " ") {
                                                            randomUser = Int.random(in: 0...users-1)
                                                        }
                                                        self.emailList.insert(email, at: num)
                                                        let profilePic = UIImageView()
                                                        profilePic.image = UIImage(systemName: "person.circle")
                                                        profilePic.tintColor = self.primary
                                                        self.tableView.reloadData()
                                                        self.spinners.dismiss()
                                                        
                                                        //cell.configure(path: path, name: name)
                                                    
                                                }
                                            }
                                        }
                                    }
                                        })
                                    }
                                }
                        }
                    case .failure(let error):
                        print("Failed to read data with error: \(error)")
                    }
                }

            case .failure(_):
                print("user failed")
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numList.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindCell", for: indexPath) as! ExpTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = secondary
        cell.selectedBackgroundView = backgroundView
        
//        
        
        print(indexPath.row)
        //print("name num \(nameList.count)")
        //name == 14
        //email == 7
        //print("email num \(emailList.count)")
        let name = nameList[indexPath.row]
        let email = emailList[indexPath.row]
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let path = "images/\(safeEmail)_profile_picture.png"
        cell.configure(path: path, name: name)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        spinners.show(in: view)
        self.tableView.isUserInteractionEnabled = false
                let name = self.nameList[indexPath.row]
                let email = self.emailList[indexPath.row]
                let path = "images/\(email)_profile_picture.png"
                print("1")
                DatabaseManager.shared.getStatus(email: email) { (userStatus) in
                    print("2")
                    DatabaseManager.shared.checkRequested(otherEmail: email) { (request) in
                        print("3")
                        if (request) {
                            print("4")
                            let vc = ProfileUserViewController(with: name, status: userStatus, path: path, isMine: false, email: email, request: 1, passcord: false)
                            let navVC = UINavigationController(rootViewController: vc)
                            navVC.navigationBar.isHidden = true
                            self.spinners.dismiss()
                            self.tableView.isUserInteractionEnabled = true
                            self.present(navVC, animated: true)
                        } else {
                            print("5")
                            DatabaseManager.shared.checkReceive(otherEmail: email) { (receive) in
                                print("6")
                                if (receive) {
                                    print("7")
                                    let vc = ProfileUserViewController(with: name, status: userStatus, path: path, isMine: false, email: email, request: 4, passcord: false)
                                    let navVC = UINavigationController(rootViewController: vc)
                                    navVC.navigationBar.isHidden = true
                                    self.tableView.isUserInteractionEnabled = true
                                    self.spinners.dismiss()
                                    self.present(navVC, animated: true)
                                } else {
                                    print("8")
                                    let vc = ProfileUserViewController(with: name, status: userStatus, path: path, isMine: false, email: email, request: 2, passcord: false)
                                    let navVC = UINavigationController(rootViewController: vc)
                                    navVC.navigationBar.isHidden = true
                                    self.tableView.isUserInteractionEnabled = true
                                    self.spinners.dismiss()
                                    self.present(navVC, animated: true)
                                }
                            }
                        }
                    }
                }
        
    }
    
    private func createNewConversation(name: String, email: String) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        //let name = DatabaseManager.shared.getUserName(email: email)
        
        DatabaseManager.shared.conversationExists(with: safeEmail, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: safeEmail, id: conversationId, passcord:nil)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: safeEmail, id: nil, passcord:nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
//    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        let name = nameList[indexPath.row]
//        let email = emailList[indexPath.row]
//        let path = "images/\(email)_profile_picture.png"
//
//        DatabaseManager.shared.getStatus(email: email) { (userStatus) in
//            let vc = ProfileUserViewController(with: name, status: userStatus, path: path, isMine: false, email: email)
//            let navVC = UINavigationController(rootViewController: vc)
//            navVC.navigationBar.isHidden = true
//            self.present(navVC, animated: true)
//        }
//    }
}
