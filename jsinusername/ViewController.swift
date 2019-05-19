//
//  ViewController.swift
//  jsinusername
//
//  Created by 劉十六 on 2019/5/18.
//  Copyright © 2019 Ting. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var userinageView: UIImageView!
    
    var infoTableViewController:InfoTableViewController?
    var userapi = "https://gis.taiwan.net.tw/XMLReleaseALL_public/activity_C_f.json"
    let reachability = Reachability(hostName: "www.apple.com")
    lazy var sessiin = { return URLSession(configuration: .default)
    }()
    var session = URLSession(configuration: .default)
    
    var isDownloading = false
    
    @IBAction func makeNewUser(_ sender: UIBarButtonItem) {
        if isDownloading == false {
            downloadWithURLSession(webAddress: userapi)
        }
        
    }
    func downloadWithURLSession(webAddress:String) {
        if let url =  URL(string: webAddress){ //
            if interneOK() == true {
                let task  = session.dataTask(with: url) { (data, response, error) in
                    
                    if error != nil {
                        DispatchQueue.main.async {
                            
                            self.popAlert(withTitle: "Sorry", AndMessage: error!.localizedDescription)
                        }
                        self.isDownloading = false
                        return
                    }
                    if let  dowloadedData = data{
                        do{
                            let downloadedDate = try Data(contentsOf: url)
                            let json = try JSONSerialization.jsonObject(with: downloadedDate, options: [])
                            DispatchQueue.main.async {
                                self.parseJSON(json: json)
                            }
                        }
                        catch{
                            DispatchQueue.main.async {
                                self.popAlert(withTitle: "Sorry", AndMessage: error.localizedDescription)
                            }
                        }
                    } else {
                        self.isDownloading = false
                    }
                }
                task.resume()
                isDownloading = true
            }else {
                
                popAlert(withTitle: "沒有網路", AndMessage: "請再試一次")
                
            }
        }
        else {
            
            popAlert(withTitle: "抱歉", AndMessage: "目前沒辦法產出隨機活動")
        }
        
    }
    
    func interneOK() -> Bool {
        //＝＝0就是沒有網路 回傳flase
        if reachability?.currentReachabilityStatus().rawValue == 0 {
            return false
        }
        else{
            return true
        }
    }
    
    
    func popAlert(withTitle title:String,AndMessage message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //創造警告控制器
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: nil))
        present(alert,animated: true,completion: nil)
        // 推出警告控制器
    }
    
    override func viewDidLoad() {
        navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 0.67, green: 0.3, blue: 0.157, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        super.viewDidLoad()
        downloadWithURLSession(webAddress:userapi)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moinfo"{
            infoTableViewController =  segue.destination as? InfoTableViewController
        }
    }
    func parseJSON(json:Any){
        if let okJson = json as? [String:Any]{
            if let loadedImageAddresss = okJson["XML_Head"] as? [String:Any]{
                if  let infoinfoDic = loadedImageAddresss["Infos"] as? [String:Any]{
                    if  let  infoinfoDic = infoinfoDic["Info"] as? [[String:Any]]{
                        
                        var key = Int.random(in: 0...100)
                        let infoArray = infoinfoDic[key]
                        
                        let loadedName = infoArray["Name"] as? String
                        let loadedEmail =  infoArray["Add"] as? String
                        let loadedPhone = infoArray["Description"] as? String
                        let imageDictionary = infoArray["Picture1"] as? String
                        let loadedUser = User(name: loadedName, email: loadedEmail, Phone: loadedPhone, image: imageDictionary)
                        settingInfo(userss: loadedUser)
                    }
                    else {
                        self.isDownloading = false
                    }
                } else {
                    self.isDownloading = false
                }
            }
        }
    }
    
    
    func settingInfo(userss:User) {
        infoTableViewController?.add.text =  userss.Phone
        infoTableViewController?.Name.text = userss.name
        infoTableViewController?.address.text = userss.email
        if let  imageAddress = userss.image {
            // 把網址轉成ＵＲＬf let imageAddress = user.image{
            if let imageURL = URL(string: imageAddress){
                let task = session.downloadTask(with: imageURL, completionHandler: {
                    (url, response, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.popAlert(withTitle: "Soory", AndMessage: error!.localizedDescription)
                        }
                        self.isDownloading = false
                        return
                    }
                    if let okURL = url {
                        do {
                            let downloadImage = UIImage(data: try Data(contentsOf: okURL))
                            DispatchQueue.main.async {
                                self.userinageView.image = downloadImage
                                self.isDownloading = false
                                // 正確的話開始下載圖片
                            }
                        }
                        catch{
                            DispatchQueue.main.async {
                                self.popAlert(withTitle: "Sorry", AndMessage: error.localizedDescription)
                                self.isDownloading = false
                            }
                            
                        }
                    }
                })
                task.resume()            }
            else {
                self.isDownloading = false
            }
        } else {
            self.isDownloading = false
        }
        
    }
}

