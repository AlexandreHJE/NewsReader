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

    //(一定有更好的做法) 剛打開 App 等待 Api 成功回傳後初始化 tableView
    var notInitTableViewYet = 1
    
    let imageCacheDirectoryPath = NSHomeDirectory() + "/Library/Caches/images/"
    let fileManager = FileManager.default
    
    var imageURLsForPresent: [URL] = []
    
    var imageGalleryCollectionView: UICollectionView?
    var imageFlowLayout: UICollectionViewFlowLayout?
    var imageGalleryFlowLayout: ImageCollectionViewFlowLayout?
    let ImageCellID = "ImageCell"
    
    var newsGroupCollectionView: UICollectionView?
    var newsFlowLayout: UICollectionViewFlowLayout?
    var newsGroupFlowLayout: NewsGroupCollectionViewFlowLayout?
    let NewsGroupCellID = "NewsGroupCell"
    
    var webViewLink = ""
    
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
//        print(self.imageURLsForPresent)
        let imgs = imageURLsForPresent
//        print(imgs)
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
        notInitTableViewYet = 0
    }
    private func initCollectionView() {
        
        newsFlowLayout = UICollectionViewFlowLayout()
        newsFlowLayout!.itemSize = CGSize(width: 20, height: 30)
        newsFlowLayout!.sectionInset = UIEdgeInsets(top: 74, left: 0, bottom: 0, right: 0)

        newsGroupFlowLayout = NewsGroupCollectionViewFlowLayout()
        newsGroupCollectionView = UICollectionView(frame: CGRect(x: 0, y: 80, width: view.frame.width, height: 40), collectionViewLayout: newsGroupFlowLayout!)
        
        newsGroupCollectionView!.delegate = self
        newsGroupCollectionView!.dataSource = self
        newsGroupCollectionView!.backgroundColor = .lightGray
        
        let cellXIB = UINib.init(nibName: "NewsGroupCollectionViewCell", bundle: Bundle.main)
        newsGroupCollectionView!.register(cellXIB, forCellWithReuseIdentifier: NewsGroupCellID)
        newsGroupCollectionView!.showsHorizontalScrollIndicator = false
        
        //将Collection View添加到主视图中
        view.addSubview(newsGroupCollectionView!)
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(ViewController.handleTap(_:)))
        newsGroupCollectionView!.addGestureRecognizer(tapRecognizer)
        
    }

    @objc func handleTap(_ sender:UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended{
            let tapPoint = sender.location(in: self.newsGroupCollectionView!)
            //点击的是单元格元素
            if let  indexPath = self.newsGroupCollectionView!.indexPathForItem(at: tapPoint) {
                //通过performBatchUpdates对collectionView中的元素进行批量的插入，删除，移动等操作
                //同时该方法触发collectionView所对应的layout的对应的动画。
                self.newsGroupCollectionView!.performBatchUpdates({ () -> Void in
                    print("tap \(indexPath.row) cell")
//                    self.collectionView.deleteItems(at: [indexPath])
//                    self.images.remove(at: indexPath.row)
                }, completion: nil)
                
            }
                //点击的是空白位置
            else{
                print("tap empty place.")
                //新元素插入的位置（开头）
//                let index = 0
//                images.insert("xcode.png", at: index)
//                self.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
            }
        }
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
        imageGalleryCollectionView!.showsHorizontalScrollIndicator = false
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
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipe(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipe(_:)))
        swipeLeft.direction = .left
        swipeRight.direction = .right
        self.tableView.addGestureRecognizer(swipeLeft)
        self.tableView.addGestureRecognizer(swipeRight)
    }
    
    @objc func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {
//        let centerPoint = tableView.center
        if recognizer.direction == .left {
            print("swipe Left")
        }else if recognizer.direction == .right {
            print("swipe Right")
        }else{
            print("swipe ?? side")
        }
    }
    
}

//MainPageViewModelDelegate
extension ViewController: MainPageViewModelDelegate {
    func viewModel(_ viewModel: MainPageViewModel, didUpdateMainPageData data: [NewsContent]) {
        if notInitTableViewYet > 0 {
            clickBTN(self)
        }
        print("data Updated")
    }
    
}

//CollectionView DataSource
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
            if let imageUrl = content.relatedPictures?.extractURLs().first {
                let imageFileName = imageUrl.lastPathComponent
                if fileManager.fileExists(atPath: imageCacheDirectoryPath + imageFileName) {
                    img.image.image = UIImage(contentsOfFile: imageCacheDirectoryPath + imageFileName)
                }else{
                    img.image.image = UIImage(named: "noPic")
                }
            }else{
                img.image.image = UIImage(named: "noPic")
            }
            img.title.text = content.newsTitle
            return img
        }
    }
}

//Collection View样式布局协议相关方法
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Did select element: \(indexPath.row)")
        if collectionView == self.imageGalleryCollectionView {
            webViewLink = viewModel.contents[indexPath.row].source!
            let webView = storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebViewController
            webView.mainViewController = self
            show(webView, sender: self)
        }
//        cell?.backgroundColor = .yellow
//        cell?.backgroundView?.backgroundColor = .yellow
//        cell?.contentView.layer.borderWidth = 2.0
//        cell?.contentView.layer.borderColor = UIColor.yellow.cgColor
//        cell?.layer.borderWidth = 2.0
//        cell?.layer.borderColor = UIColor.yellow.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("Highlighting at: \(indexPath.row)")
        //如何透過滑動collectionView來連動pageController的顯示？
        if collectionView == self.imageGalleryCollectionView {
            
        }
    }
}

// Mark: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("click table cell: \(indexPath.row)")
        webViewLink = viewModel.contents[indexPath.row+5].source!
//        print(webViewLink)
        let webView = storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebViewController
        webView.mainViewController = self
        show(webView, sender: self)
    }
}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = viewModel.contents[indexPath.row+5]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        
        if let imageUrl = content.relatedPictures?.extractURLs().first {
            let imageFileName = imageUrl.lastPathComponent
            if fileManager.fileExists(atPath: imageCacheDirectoryPath + imageFileName) {
                cell.cellImage.image = UIImage(contentsOfFile: imageCacheDirectoryPath + imageFileName)
            }else{
                cell.cellImage.image = UIImage(named: "noPic")
            }
        }else{
            cell.cellImage.image = UIImage(named: "noPic")
        }
        cell.titleLabel.text = content.newsTitle
        cell.typeLabel.text = content.newsType

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnUIView = UIView()
        initGalleryView()
        returnUIView.addSubview(imageGalleryCollectionView!)
        let pagerView = UIPageControl(frame: CGRect(x: 0, y: imageGalleryCollectionView!.frame.height-50, width: 0, height: 20))
        pagerView.numberOfPages = 5
        pagerView.currentPage = 0
        returnUIView.addSubview(pagerView)
//        returnUIView.backgroundColor = .yellow
        return returnUIView
//        return imageGalleryCollectionView
    }
    
//    private func tableView(tableView: UITableView,
//                   heightForHeaderInSection section: Int) -> CGFloat {
//        return 100
//    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //減五的原因是前面五則新聞方放在header裡面的CollectionView
        return viewModel.contents.count - 5
    }
}
