//
//  ViewController.swift
//  HRSwiftTest
//
//  Created by ZhangHeng on 15/9/11.
//  Copyright © 2015年 ZhangHeng. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    var list:NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        list = NSMutableArray.init(array: []) as NSMutableArray
        
        let btn:UIButton = UIButton(type: UIButtonType.RoundedRect)
        btn.frame = CGRectMake(20, 60, 60, 30)
        btn.setTitle("test", forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.redColor()
        btn.addTarget(self, action: NSSelectorFromString("doSomeThing"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btn)
        
        let table:UITableView = UITableView(frame: CGRectMake(0, 90, self.getScreenSize().width, self.getScreenSize().height-90), style: UITableViewStyle.Plain)
        self.view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = UITableViewCellSeparatorStyle.None
        
        table.registerClass(HRCustomTableCell.classForCoder(), forCellReuseIdentifier: "myCell")
        
//        Alamofire.request(.POST, "http://121.40.189.170:8081/apis/login", parameters: ["lname": "18602716460","lpwd":"123456"])
//            .response { request, response, data, error in
//                do {
//                    let object:AnyObject! = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
//                    print(object)
//                } catch let aError as NSError {
//                    if error != nil {
//                        print(aError)
//                    }
//                }
//        }
        Alamofire.request(.GET, "http://zstest.aliapp.com/API/getSceneList",parameters:nil).response{request, response, data, error in
            do {
                let object:AnyObject! = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                print(object["InfoList"])
                let count = object.objectForKey("InfoList")!.count
                for(var i = 0; i < count;i++){
                    let itemDic:NSDictionary = (object["InfoList"] as! NSArray)[i] as! NSDictionary;
                    let item:HRTestItem = HRTestItem.init(itemDic as! Dictionary<String, AnyObject>)
                    self.list!.addObject(item)
                }
                
                table.reloadData()
            } catch let aError as NSError {
                if error != nil {
                    print(aError)
                }
            }
        }
        
//        Alamofire.request(.GET, "http://121.40.189.170:8081/apis/getprotype", parameters: ["pid":"1"]).response{request, response, data, error in
//            print(request)
//            let array:NSMutableArray = [].mutableCopy() as! NSMutableArray
//            do {
//                let object:AnyObject! = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
//                let count = object.objectForKey("types")!.count
//                for(var i = 0; i < count;i++){
//                    let dicObj:NSDictionary = object.objectForKey("types")!.objectAtIndex(i) as! NSDictionary
//                    let item:HRSelectItem! = HRSelectItem.init(dicObj as! Dictionary<String, AnyObject>)
//                    array.addObject(item)
//                }
//            } catch let aError as NSError {
//                if error != nil {
//                    print(aError)
//                }
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func doSomeThing(){
        print("fuck swift", terminator: "")
    }
    
    func getScreenSize()->CGSize{
        return UIScreen.mainScreen().bounds.size
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:HRCustomTableCell = tableView.dequeueReusableCellWithIdentifier("myCell") as! HRCustomTableCell
        
        let item:HRTestItem = (self.list?.objectAtIndex(indexPath.row))! as! HRTestItem
        
        cell.title?.text = item.SceneName as? String
        cell.iconImage.sd_setImageWithURL(NSURL.init(string: item.DesignerPicSrc! as String))
        cell.sign.text = item.DesignerPicSrc as? String
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.list?.count)!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

