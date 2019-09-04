//
//  AppDelegate.swift
//  NewsReader
//
//  Created by 胡仁恩 on 2019/8/29.
//  Copyright © 2019 alexHu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        getData()
        // File Manager
        let fileManager = FileManager.default
        // 建立儲存新聞圖片檔案的資料夾路徑 NSHomeDirectory + "/Library/Caches/images"
        let imageCacheDirectory = NSHomeDirectory() + "/Library/Caches/images"
        // !fileManager.fileExists(atPath: imageCacheDir)
        // 表示此資料夾不存在，情況為第一次開啟App，或資料夾被刪除了。
        if !fileManager.fileExists(atPath: imageCacheDirectory) {
            try! fileManager.createDirectory(atPath: imageCacheDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        //Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    @objc
    private func getData() {
        DataManager.shared.getNewsData { (contents) in
            //save local
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GetData"), object: self, userInfo: ["contents": contents])
        }
        print("gd")
        
    }
}

