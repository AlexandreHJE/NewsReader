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
    
    //姑且一試
    //綜合新聞: 全部內容
    //社會公益: 社會公益/ 社會福利
    //環保公告: 環保工安/ 災害應變中心公告
    //其他分類: 剩餘的內容
    let newsGroups = ["綜合新聞", "社會公益", "行政業務", "環保公告", "其他分類"]
    
    private(set) var contents = [NewsContent]() {
        didSet {
            print("did set contents in vm")
            delegate?.viewModel(self, didUpdateMainPageData: contents)
            print("finished did set contents in vm")
        }
    }
    
    //缺若點選更新時，此資料陣列應該要跟著刷新
    private(set) var newsByGroup = [[NewsContent]]() {
        didSet {
            delegate?.viewModel(self, didUpdateMainPageData: contents)
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
                getAndSaveImageFile(contents)
                
                for i in 0..<newsGroups.count {
                    switch i {
                    case 0:
                        newsByGroup.append(contents)
                    case 1:
                        var temp = [NewsContent]()
                        for c in contents {
                            if c.newsType! == NewsType.socialGoodness.rawValue || c.newsType! == NewsType.socialWellness.rawValue {
                                temp.append(c)
                            }
                        }
                        newsByGroup.append(temp)
                    case 2:
                        var temp = [NewsContent]()
                        for c in contents {
                            if c.newsType! == NewsType.education.rawValue || c.newsType! == NewsType.miscellaneous.rawValue || c.newsType! == NewsType.finacial.rawValue {
                                temp.append(c)
                            }
                        }
                        newsByGroup.append(temp)
                    case 3:
                        var temp = [NewsContent]()
                        for c in contents {
                            if c.newsType! == NewsType.enviromentSafety.rawValue || c.newsType! == NewsType.disasterCenter.rawValue {
                                temp.append(c)
                            }
                        }
                        newsByGroup.append(temp)
                    case 4:
                        var temp = [NewsContent]()
                        for c in contents {
                            if c.newsType! == NewsType.other.rawValue {
                                temp.append(c)
                            }
                        }
                        newsByGroup.append(temp)
                    default:
                        newsByGroup.append(contents)
                    }
                    print("finished newsgroup")
                }
            }else{
                print("iflet content error")
            }
        }
    }
    
    func getAndSaveImageFile(_ contents: [NewsContent]) {
        print("getAndSaveImageFile")
        let fileManager = FileManager.default
        // 建立儲存新聞圖片檔案的資料夾路徑 NSHomeDirectory + "/Library/Caches/images"
        let imageCacheDirectory = NSHomeDirectory() + "/Library/Caches/images"
        let imageSaveDirectoryPath = NSHomeDirectory() + "/Library/Caches/images/"
        // !fileManager.fileExists(atPath: imageCacheDir)
        // 表示此資料夾不存在，情況為第一次開啟App，或資料夾被刪除了。
        if !fileManager.fileExists(atPath: imageCacheDirectory) {
            try! fileManager.createDirectory(atPath: imageCacheDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        
        let imageSession = URLSession(configuration: .default)
        for c in contents {
            if let img = c.relatedPictures?.extractURLs().first {
                let fileName = img.lastPathComponent
                let downloadTask = imageSession.dataTask(with: img) {
                    (data, response, error) in
                    if error != nil {
                        print("download image session failed")
                        return
                    }
                    if let loadedData = data {
                        //如果檔案路徑(imageCacheDirectory)不存在，進行儲存
                        if !fileManager.fileExists(atPath: imageSaveDirectoryPath + fileName) {
                            do {
                                try loadedData.write(to: URL(fileURLWithPath: imageSaveDirectoryPath + fileName))
                                print("圖片儲存成功: \(imageSaveDirectoryPath)\(fileName)")
                            }catch{
                                print("圖片儲存失敗")
                            }
                        }
                    }
                }
                downloadTask.resume()
            }
        }
    }
    
    func getData() {
        DataManager.shared.getNewsData { (contents) in
            //save local
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GetData"), object: self, userInfo: ["contents": contents])
        }
        print("gd")
        
    }
}
