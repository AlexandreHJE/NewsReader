//
//  ViewController.swift
//  NewsReader
//
//  Created by 胡仁恩 on 2019/8/29.
//  Copyright © 2019 alexHu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell")
        return tableView
    }()

    
    
    var imageURLsForPresent: [URL] = []
    
    var imageGalleryCollectionView: UICollectionView?
    var imageFlowLayout: UICollectionViewFlowLayout?
    var imageGalleryFlowLayout: ImageCollectionViewFlowLayout?
    let ImageCellID = "ImageCell"
    
    var newsGroupCollectionView: UICollectionView?
    var newsFlowLayout: UICollectionViewFlowLayout?
    var newsGroupFlowLayout: NewsGroupCollectionViewFlowLayout?
    let NewsGroupCellID = "NewsGroupCell"
    
    private let viewModel = MainPageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        DataManager.shared.getNewsData()
        
        self.viewModel.delegate = self
        //API回應時間比較慢 一開始內容為空陣列
//        print(self.viewModel.contents)
        initCollectionView()

    }
    
    @IBAction func clickBTN(_ sender: Any) {
//        print(self.viewModel.contents)
//        print("ImageLink")
//        print(self.viewModel.imageLinks)
        for c in self.viewModel.contents {
            //imgs成功取值
            if let imgs = c.relatedPictures?.extractURLs() {
                //陣列內容數不為零
                if imgs.count != 0 {
                    //取回傳圖片位址陣列的第一個當作要用的
                    imageURLsForPresent.append(imgs[0])
                }else{
                    //若無則用預設圖片(之後應該要修改 改用本地端圖片省流量)
                    imageURLsForPresent.append(URL(string: "https://i.imgur.com/RHV00nR.jpg")!)
                }
            }
        }
        print(self.imageURLsForPresent)
        let imgs = imageURLsForPresent
        print(imgs)
        let url = imgs[0]
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

            if error != nil {
                print(error!)
                return
            }

            DispatchQueue.main.async {
//                self.image.image = UIImage(data: data!)
            }
        }).resume()
        //initGalleryView()
        initTableView()
    }
    private func initCollectionView() {
        
        newsFlowLayout = UICollectionViewFlowLayout()
        newsFlowLayout!.itemSize = CGSize(width: 40, height: 30)
        newsFlowLayout!.sectionInset = UIEdgeInsets(top: 74, left: 0, bottom: 0, right: 0)

        newsGroupFlowLayout = NewsGroupCollectionViewFlowLayout()
        newsGroupCollectionView = UICollectionView(frame: CGRect(x: 0, y: 80, width: view.frame.width, height: 40), collectionViewLayout: newsGroupFlowLayout!)
        
        newsGroupCollectionView!.delegate = self
        newsGroupCollectionView!.dataSource = self
        newsGroupCollectionView!.backgroundColor = .blue
        
        let cellXIB = UINib.init(nibName: "NewsGroupCollectionViewCell", bundle: Bundle.main)
        newsGroupCollectionView!.register(cellXIB, forCellWithReuseIdentifier: NewsGroupCellID)
        
        //将Collection View添加到主视图中
        view.addSubview(newsGroupCollectionView!)
    }
    
    private func initGalleryView() {
        imageFlowLayout = UICollectionViewFlowLayout()
        imageFlowLayout!.itemSize = CGSize(width: view.frame.width, height: 250)
        imageFlowLayout!.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        imageGalleryFlowLayout = ImageCollectionViewFlowLayout()
        imageGalleryCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 250), collectionViewLayout: imageGalleryFlowLayout!)
        
        imageGalleryCollectionView!.delegate = self
        imageGalleryCollectionView!.dataSource = self
        imageGalleryCollectionView!.backgroundColor = .green
        
        let cellXIB = UINib.init(nibName: "ImageCollectionViewCell", bundle: Bundle.main)
        imageGalleryCollectionView!.register(cellXIB, forCellWithReuseIdentifier: ImageCellID)
        
        //将Collection View添加到主视图中
//        view.addSubview(imageGalleryCollectionView!)
    }

    private func initTableView() {
        print("init TableView")
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.newsGroupCollectionView!.bottomAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.tableView.sectionHeaderHeight = 250
    }
}

extension ViewController: MainPageViewModelDelegate {
    func viewModel(_ viewModel: MainPageViewModel, didUpdateMainPageData data: [NewsContent]) {
        
        print("data Updated")
    }
    
}

//Collection View数据源协议相关方法
extension ViewController: UICollectionViewDataSource {
    //获取分区数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //获取每个分区里单元格数量
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    //返回每个单元格视图
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.newsGroupCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                NewsGroupCellID, for: indexPath) as! NewsGroupCollectionViewCell
            //设置内部显示的图片
            cell.titleLabel.text = "Label"
            //获取重用的单元格
            return cell
        }else{
            let content = viewModel.contents[indexPath.row]
            let img = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellID, for: indexPath) as! ImageCollectionViewCell
            let imgs = imageURLsForPresent
            print(imgs)
            let url = imgs[0]
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    img.image.image = UIImage(data: data!)
                    img.title.text = content.newsTitle
                }
            }).resume()
//            img.image.image = UIImage(data: img[0])
//            img.backgroundColor = .gray
            img.title.text = "PH"
            return img
        }
    }
}

//Collection View样式布局协议相关方法
extension ViewController: UICollectionViewDelegate {
    
}

// Mark: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contents = viewModel.contents[indexPath.row+5]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        cell.cellImage.image = UIImage(named: "noPic")
        cell.setUI()
        cell.titleLabel.text = contents.newsTitle
        cell.typeLabel.text = contents.newsType
//        cell.favoriteButton.tag = indexPath.row + 1000
//        cell.setUI(with: station)
//        cell.favoriteButton.setTitle("Add to favorite", for: .normal)
//        cell.favoriteButton.setTitle("Remove from favorite", for: .selected)
//        cell.favoriteButton.isSelected = viewModel.favoriteIDs.contains(station.sno!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnUIView = UIView()
        initGalleryView()
        returnUIView.addSubview(imageGalleryCollectionView!)
//        returnUIView.backgroundColor = .yellow
        return returnUIView
//        return imageGalleryCollectionView
    }
    
//    private func tableView(tableView: UITableView,
//                   heightForHeaderInSection section: Int) -> CGFloat {
//        return 100
//    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        return 10
        return viewModel.contents.count - 5
    }
}
