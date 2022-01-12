//
//  ViewController.swift
//  XBExtensionKit
//
//  Created by 1258658427@qq.com on 01/11/2022.
//  Copyright (c) 2022 1258658427@qq.com. All rights reserved.
//

import UIKit
class ViewController: UIViewController, StoryboardLoadable {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ViewController.loadStoryboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

