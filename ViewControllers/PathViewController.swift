//
//  PathViewController.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 24.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import UIKit

class PathViewController: UIViewController {

    @IBOutlet weak var pathView: UIView!
    var path = [Int]()
    private var indent = 16
    private var currentY = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentY = indent
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
