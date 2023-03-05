//
//  PhotoViewsViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 8/30/20.
//  Copyright © 2020 choi jun hyung. All rights reserved.
//

import UIKit
import SDWebImage

final class PhotoViewsViewController: UIViewController {
    
    private let url: URL
    
    
    
    init(with url:URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo"
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(imageView)
        imageView.sd_setImage(with: url, completed: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        }

        @objc func backTapped(sender: UIBarButtonItem) {
            navigationController?.popViewController(animated: false)
        }

    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
        
    }
}
