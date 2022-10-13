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
    
    @IBOutlet weak var bearImageWidth: NSLayoutConstraint!
    @IBOutlet weak var bearImageHeight: NSLayoutConstraint!
    @IBOutlet var clothesWidthCollection: [NSLayoutConstraint]!
    @IBOutlet var clothesHeightCollection: [NSLayoutConstraint]!
    
    @IBOutlet weak var pantsImage: UIImageView!
    @IBOutlet weak var shirtImage: UIImageView!
    @IBOutlet weak var accessoryImage: UIImageView!
    
    //MARK: IBOutlet Function
    @IBAction func tapPurchasingButton(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "PurchasingView", bundle: nil)
        guard let purchasingViewController = storyBoard.instantiateViewController(withIdentifier: "PurchasingViewController") as? PurchasingViewController else { return }
        self.navigationController?.pushViewController(purchasingViewController, animated: true)
    }
    
    //MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleFunction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshBearImagePoint()
    }
    
    private func refreshBearImagePoint() {
        let pants = UserDefaults.standard.object(forKey: "pants") as? String
        self.pantsImage.image = pants == nil ? UIImage() : UIImage(named: "\(pants ?? "")")
        
        let shirt = UserDefaults.standard.object(forKey: "shirt") as? String
        self.shirtImage.image = shirt == nil ? UIImage() : UIImage(named: "\(shirt ?? "")")
        
        let accessory = UserDefaults.standard.object(forKey: "accessory") as? String
        self.accessoryImage.image = accessory == nil ? UIImage() : UIImage(named: "\(accessory ?? "")")
        
        let point = UserDefaults.standard.object(forKey: "point") as? Int
        self.pointLabel.text = point == nil ? String("0") : String(point ?? 0)
    }
    
    
    //MARK: Style Function
    private func styleFunction() {
        self.configurePointLabel()
        self.configureMainImage()
    }

    private func configurePointLabel() {
        self.pointLabel.font = UIFont.NFont.noSearchedTextFont
        self.view.backgroundColor = UIColor.NColor.background
    }
    
    private func configureMainImage() {
        self.bearImageWidth.constant = UIScreen.main.bounds.width * 0.6
        self.bearImageHeight.constant = UIScreen.main.bounds.height * 0.4
        
        self.clothesWidthCollection.forEach { width in
            width.constant = self.bearImageWidth.constant
        }
        self.clothesHeightCollection.forEach { height in
            height.constant = self.bearImageHeight.constant
        }
    }
}
