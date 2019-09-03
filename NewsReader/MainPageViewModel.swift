//
//  MainPageViewModel.swift
//  NewsReader
//
//  Created by 胡仁恩 on 2019/8/29.
//  Copyright © 2019 alexHu. All rights reserved.
//

import Foundation

protocol MainPageViewModelDelegate {
    func viewModel(_ viewModel: MainPageViewModel, didUpdateMainPageData data: [NewsContent])
}

class MainPageViewModel {
    private(set) var contents = [NewsContent]() {
        didSet {
            delegate?.viewModel(self, didUpdateMainPageData: contents)
        }
    }
    
    //缺若點選更新時，此資料陣列應該要跟著刷新
    private(set) var imageLinks = [URL]() {
        didSet {
            for c in contents {
                if let imgs = c.relatedPictures?.extractURLs() {
                    //陣列內容數不為零
                    if imgs.count != 0 {
                        //取回傳圖片位址陣列的第一個當作要用的
                        imageLinks.append(imgs[0])
                    }else{
                        //若無則用預設圖片(之後應該要修改 改用本地端圖片省流量)
                        imageLinks.append(URL(string: "https://i.imgur.com/RHV00nR.jpg")!)
                    }
                }
            }
        }
    }
    
//    private(set) var contentTable = [String: NewsContent]() {
//        didSet {
//            contents = contentTable
//                .map({ (dictionary) -> NewsContent in
//                    return dictionary.value
//                })
//        }
//    }
    
    var delegate: MainPageViewModelDelegate?
    
    init() {
        print("init")
        NotificationCenter.default.addObserver(self, selector: #selector(processingDataToArray(_:)), name: NSNotification.Name(rawValue: "GetData"), object: nil)
    }
    
    @objc
    func processingDataToArray(_ notification: Notification) {
        print("pdta")
        if let userInfo = notification.userInfo {
            print("userInfo")
//            if let contentTable = userInfo["contents"] as? [String: NewsContent] {
            if let contents = userInfo["contents"] as? [NewsContent] {
//                self.contentTable = contentTable
                self.contents = contents
                print("aa")
                var temps = [NewsContent]()
                for v in contents {
                    temps.append(v)
                }
//                for k in contentTable.keys {
//                    temps.append(contentTable[k]!)
//                }
                
                self.contents = temps
            }else{
                print("iflet content error")
            }
        }
    }
}
