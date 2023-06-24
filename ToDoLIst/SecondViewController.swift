//
//  SecondViewController.swift
//  TodoList
//
//  Created by Кирилл Казаков on 24.06.2023.
//

import UIKit

class SecondViewContoller: UIViewController {
    
    let button = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        button.setTitle("ТЕСТ", for: .normal)
    }
}
