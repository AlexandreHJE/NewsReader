//
//  DataManager.swift
//  NewsReader
//
//  Created by 胡仁恩 on 2019/8/29.
//  Copyright © 2019 alexHu. All rights reserved.
//

import Foundation

class DataManager {
    static let shared = DataManager()
}

extension DataManager {
    
    func getNewsData(_ completion: @escaping ([NewsContent]) -> Void) {
        let url = URL(string: "http://www.cyhg.gov.tw/OpenData.aspx?SN=11744AB71FE3775C")!
        let task = URLSession.shared.dataTask(with: url) {
            (jsonData, response, error)
            in
            let decoder = JSONDecoder()
            if let jData = jsonData, let apiResponse = try? decoder.decode([NewsContent].self, from: jData)
            {
                print("JSON parse success!")
                DispatchQueue.main.sync {
                    completion(apiResponse)
                }
                
            }else{
                print("JSON parse failed...")
            }
        }
        task.resume()
    }
}

extension DataManager {
    
    func getImageFileList(_ completion: @escaping ([String]) -> Void) {
        let fileManager = FileManager.default
        let imageCacheDirectory = NSHomeDirectory() + "/Library/Caches/images"
        if !fileManager.fileExists(atPath: imageCacheDirectory) {
            try! fileManager.createDirectory(atPath: imageCacheDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        do {
            let imageFileNames = try fileManager.contentsOfDirectory(atPath: imageCacheDirectory)
            completion(imageFileNames)
        }catch{
            print("阿怎麼沒有東西")
        }
    }
}
