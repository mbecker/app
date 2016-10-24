//
//  TabBarController.swift
//  app
//
//  Created by Mats Becker on 10/24/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let viewController = ViewController()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)!
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        // Add UIViewControlles to TabBar
        viewController.tabBarItem = UITabBarItem(title: "Park", image: UIImage(named: "picnicTable"), selectedImage: UIImage(named: "picnicTable"))
        self.setViewControllers([viewController], animated: false)
        
        
        // Set TabBar style
        self.tabBar.unselectedItemTintColor = UIColor.flatBlack()
        self.tabBar.tintColor = UIColor.flatRed()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set TabBar stlye
        self.tabBar.backgroundImage = UIImage.colorForNavBar(color: UIColor.white)        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
