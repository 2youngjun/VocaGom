//
//  PetViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/10/02.
//

import UIKit

class PetViewController: UIViewController {

    //MARK: Variable
    
    
    //MARK: IBOutlet Variable
    @IBOutlet weak var pointImage: UIImageView!
    @IBOutlet weak var pointBackgroundView: UIView!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var purchasingButton: UIButton!
    
    //MARK: IBOutlet Function
    @IBAction func tapPurchasingButton(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "PurchasingView", bundle: nil)
        guard let purchasingViewController = storyBoard.instantiateViewController(withIdentifier: "PurchasingViewController") as? PurchasingViewController else { return }
        self.navigationController?.pushViewController(purchasingViewController, animated: true)
    }
    
    //MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configurePointLabel()
        self.view.backgroundColor = UIColor.NColor.background
    }
    
    //MARK: Style Function
    private func configurePointLabel() {
        self.pointLabel.font = UIFont.NFont.noSearchedTextFont
    }
    
    private func configurePointImage() {
        
    }
}
