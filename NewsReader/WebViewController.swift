//
//  WebViewController.swift
//  NewsReader
//
//  Created by 胡仁恩 on 2019/9/3.
//  Copyright © 2019 alexHu. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    weak var mainViewController: ViewController!
    @IBOutlet weak var naviBar: UINavigationBar!
    
    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("web vc")
        if let url = URL(string: self.mainViewController.webViewLink) {
            let request = URLRequest(url: url)
            webView = WKWebView()
            webView?.navigationDelegate = self
            webView?.load(request)
        }
        view.addSubview(webView!)
        self.webView?.translatesAutoresizingMaskIntoConstraints = false
        self.webView?.topAnchor.constraint(equalTo: self.naviBar.bottomAnchor).isActive = true
        self.webView?.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.webView?.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        self.webView?.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension WebViewController: WKNavigationDelegate {
    
}
