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

    lazy var loadingScreen: LoadingScreenView = {
        let view = LoadingScreenView(frame: .zero)
        return view
    }()
    
    //綜合新聞: 全部內容
    //社會公益: 社會公益/ 社會福利
    //環保公告: 環保工安/ 災害應變中心公告
    //其他分類: 剩餘的內容
    let newsGroups = ["綜合新聞", "社會公益", "行政業務", "環保公告", "其他分類"]
    var newsGroupPointer = 0
    
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
        
        self.viewModel.delegate = self
        initCollectionView()
        showLoadingScreen()
    }
    
    func showLoadingScreen() {
//        loadingScreen.isHidden = false
        loadingScreen = LoadingScreenView()
        self.view.addSubview(loadingScreen)
        self.loadingScreen.translatesAutoresizingMaskIntoConstraints = false
        self.loadingScreen.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.loadingScreen.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.loadingScreen.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.loadingScreen.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.loadingScreen.backgroundColor = .black
        self.loadingScreen.alpha = 0.95
        self.loadingScreen.tag = 300
        
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        self.loadingScreen.addSubview(activityIndicator)
        activityIndicator.frame = self.view.bounds
        activityIndicator.color = .orange
        activityIndicator.startAnimating()
        
        print("show loading")
    }
    
    func removeLoadingScreen() {
        if let viewWithTag = self.view.viewWithTag(300) {
            viewWithTag.removeFromSuperview()
            print("Removed load screen")
        }else{
            print("Didn't find loading screen")
        }
    }
    
    
    func initTableViewAndHeader() {
        initTableView()
        notInitTableViewYet = 0
    }
    
    private func initCollectionView() {
        
        newsFlowLayout = UICollectionViewFlowLayout()
        newsFlowLayout!.itemSize = CGSize(width: 60, height: 30)
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
            if let indexPath = self.newsGroupCollectionView!.indexPathForItem(at: tapPoint) {
                newsGroupPointer = indexPath.row
                newsGroupCollectionView?.reloadData()
                tableView.reloadData()
//                self.newsGroupCollectionView!.performBatchUpdates({ () -> Void in
//                    print("tap \(indexPath.row) cell")
//                    newsGroupPointer = indexPath.row
//                    tableView.reloadData()
//                }, completion: nil)
            }
            else{
                print("tap empty place.")
            }
        }
    }
    
    @IBAction func clickRefreshBTN(_ sender: Any) {
//        print(self.viewModel.contents)
//        print("ImageLink")
//        print(self.viewModel.imageLinks)
        self.viewModel.getData()
        showLoadingScreen()
    }
    
    private func initGalleryView() {
        imageFlowLayout = UICollectionViewFlowLayout()
        imageFlowLayout!.itemSize = CGSize(width: view.frame.width, height: 250)
        imageFlowLayout!.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        imageGalleryFlowLayout = ImageCollectionViewFlowLayout()
        imageGalleryCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 250), collectionViewLayout: imageGalleryFlowLayout!)
        
        imageGalleryCollectionView!.delegate = self
        imageGalleryCollectionView!.dataSource = self
        imageGalleryCollectionView!.backgroundColor = .white
        
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
            if newsGroupPointer < newsGroups.count - 1 {
                newsGroupPointer += 1
                newsGroupCollectionView?.reloadData()
                tableView.reloadData()
            }
        }else if recognizer.direction == .right {
            if newsGroupPointer > 0 {
                newsGroupPointer -= 1
                newsGroupCollectionView?.reloadData()
                tableView.reloadData()
            }
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
            initTableViewAndHeader()
            print("init Table View Header")
        }else{
            tableView.reloadData()
            imageGalleryCollectionView?.reloadData()
            print("reload Table View Header")
        }
        removeLoadingScreen()
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
        if collectionView == self.imageGalleryCollectionView {
            let content = viewModel.newsByGroup[newsGroupPointer]
            if content.count >= 5 {
                return 5
            }else{
                return content.count
            }
        }
        return 5
    }
    
    //返回每个单元格视图
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.newsGroupCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                NewsGroupCellID, for: indexPath) as! NewsGroupCollectionViewCell
            //设置内部显示的图片
            cell.titleLabel.text = newsGroups[indexPath.row]
            cell.titleLabel.textColor = .gray
            if indexPath.row == newsGroupPointer {
                cell.titleLabel.textColor = .black
            }else{
                cell.titleLabel.textColor = .gray
            }
            //获取重用的单元格
            return cell
        }else{
            let content = (viewModel.newsByGroup[newsGroupPointer])[indexPath.row]
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
        if collectionView == self.newsGroupCollectionView {
            tableView.reloadData()
        }else if collectionView == self.imageGalleryCollectionView {
            let content = (viewModel.newsByGroup[newsGroupPointer])[indexPath.row]
            webViewLink = content.source!
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
        
        if collectionView == self.newsGroupCollectionView {
//            newsGroupPointer = indexPath.row
//            tableView.reloadData()
        }else if collectionView == self.imageGalleryCollectionView {
        
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
        let content = (viewModel.newsByGroup[newsGroupPointer])[indexPath.row+5]
        webViewLink = content.source!
//        print(webViewLink)
        let webView = storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebViewController
        webView.mainViewController = self
        show(webView, sender: self)
    }
}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = (viewModel.newsByGroup[newsGroupPointer])[indexPath.row+5]
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
        let content = viewModel.newsByGroup[newsGroupPointer]
        if content.count > 5 {
            pagerView.numberOfPages = 5
        }else{
            pagerView.numberOfPages = content.count
        }
        pagerView.currentPage = 0
        pagerView.tag = 400
        returnUIView.addSubview(pagerView)
//        returnUIView.backgroundColor = .yellow
        return returnUIView
//        return imageGalleryCollectionView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
//        let horizontalCenter = width / 2
        
        if let pageControlViewWithTag = self.tableView.viewWithTag(400) as? UIPageControl {
            pageControlViewWithTag.currentPage = Int(offSet) / Int(width)
            print(pageControlViewWithTag.currentPage)
        }else{
            //在一開始畫面初始化的時候會綁定不到，進入這行
            print("Can't bind pager")
        }
    }
    
//    private func tableView(tableView: UITableView,
//                   heightForHeaderInSection section: Int) -> CGFloat {
//        return 100
//    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if newsGroupPointer != 0 {
            let content = viewModel.newsByGroup[newsGroupPointer]
            if content.count > 5 {
                return content.count - 5
            }else{
                return 0
            }
        }
        //減五的原因是前面五則新聞方放在header裡面的CollectionView
        return viewModel.contents.count - 5
    }
}
