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
//        let row = self.mainViewController.selectedRow
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
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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

extension WebViewController: WKNavigationDelegate {
    
//    override func loadView() {
//        webView = WKWebView()
//        webView?.navigationDelegate = self
//        view = webView
//        let request = URLRequest(url: URL(string: "www.google.com")!)
//        webView?.load(request)
//    }

//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        title = webView.title
//    }

}

