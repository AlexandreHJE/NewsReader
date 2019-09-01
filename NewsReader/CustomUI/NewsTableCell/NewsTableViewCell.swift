//
//  NewsTableViewCell.swift
//  NewsReader
//
//  Created by 胡仁恩 on 2019/9/1.
//  Copyright © 2019 alexHu. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUI() {
        cellImage.image = UIImage(named: "noPic")
        titleLabel.text = "新北加一分 五五六六得第一 "
        typeLabel.text = "Not a Type"
    }
    
//    func setUI(with content: NewsContent) {}
}
