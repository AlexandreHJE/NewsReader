//
//  ApiModel.swift
//  NewsReader
//
//  Created by 胡仁恩 on 2019/8/29.
//  Copyright © 2019 alexHu. All rights reserved.
//

import Foundation

struct NewsContent: Codable {
    
    var articleType: String?
    var fileName: String?
    var link: String?
    var source: String?
    var newsType: String?
    var newsTitle: String?
    var newsContent: String?
    var newsRemarks: String?
    var publishDate: String?
    var relatedFiles: String?
    var relatedLinks: String?
    var relatedPictures: String?
    var relatedVideos: String?
    
    enum CodingKeys: String, CodingKey {
        case articleType = "ArticleType"
        case fileName = "FileName"
        case link = "Link"
        case source = "Source"
        case newsType = "類別"
        case newsTitle = "主題"
        case newsContent = "內容"
        case newsRemarks = "備註"
        case publishDate = "上版日期"
        case relatedFiles = "相關檔案"
        case relatedLinks = "相關連結"
        case relatedPictures = "相關圖片"
        case relatedVideos = "相關影音"
    }
    
}
