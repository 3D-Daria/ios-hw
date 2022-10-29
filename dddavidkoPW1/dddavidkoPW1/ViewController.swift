//
//  ViewController.swift
//  dddavidkoPW1
//
//  Created by Daria D on 17.09.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var views: [UIView]!
    @IBOutlet weak var changeColorButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        changeColor(button: changeColorButton)
    }

    @IBAction func changeColorButtonPressed(_ sender: Any) {
        let button = sender as? UIButton
        changeColor(button: button)
    }
    
    func changeColor(button: UIButton?){
        button?.isEnabled = false
        var set = Set<UIColor>()
        while (set.count < views.count) {
            set.insert(
                UIColor(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1),
                    alpha: 1
                )
            )
        }
        
        UIView.animate(withDuration: 1, animations: {
            for view in self.views {
                view.layer.cornerRadius = .random(in: 10...70)
                view.backgroundColor = set.popFirst()
            }
        }) { complition in
            button?.isEnabled = true
        }
    }
}

