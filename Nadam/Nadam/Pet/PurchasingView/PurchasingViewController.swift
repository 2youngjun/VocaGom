//
//  PurchasingViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/10/02.
//

import UIKit

enum Clothes {
    case closet
    case accessory
    case shirt
    case pants
    case shoes
}

struct closetItem {
    var imageString: String
}

class PurchasingViewController: UIViewController {
    
    //MARK: Variable
    var clothes: Clothes = .closet
    var accessoryList = [Accessory]()
    var closetList = [closetItem]()
    
    //MARK: IBOutlet Variable
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var buttonBackgroundView: UIView!
    
    @IBOutlet weak var buttonBackgroundViewTopConstant: NSLayoutConstraint!
    
    @IBOutlet var clothesButtonCollection: [UIButton]!
    @IBOutlet weak var closetButton: UIButton!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var shirtButton: UIButton!
    @IBOutlet weak var pantButton: UIButton!
    @IBOutlet weak var shoesButton: UIButton!
    
    
    @IBOutlet weak var bearWidth: NSLayoutConstraint!
    @IBOutlet weak var bearHeight: NSLayoutConstraint!
    
    @IBOutlet weak var pantsImage: UIImageView!
    @IBOutlet weak var shoesImage: UIImageView!
    @IBOutlet weak var shirtImage: UIImageView!
    @IBOutlet weak var accessoryImage: UIImageView!
    @IBOutlet var clothesHeightCollection: [NSLayoutConstraint]!
    @IBOutlet var clothesWidthCollection: [NSLayoutConstraint]!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: IBOutlet Function
    @IBAction func tapBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapClothesButton(_ sender: UIButton) {
        if sender.isSelected {
            return
        } else {
            self.clothesButtonCollection.forEach { button in
                button.isSelected = button == sender ? true : false
            }
        }
        
        self.configureButtonState(buttonCollection: self.clothesButtonCollection)
        
        if sender.tag == 0 {
            self.clothes = .closet
            self.initializeCloset()
            self.collectionView.reloadData()
        } else if sender.tag == 1 {
            self.clothes = .accessory
            self.collectionView.reloadData()
        } else if sender.tag == 2 {
            self.clothes = .shirt
            self.collectionView.reloadData()
        } else if sender.tag == 3 {
            self.clothes = .pants
            self.collectionView.reloadData()
        } else {
            self.clothes = .shoes
            self.collectionView.reloadData()
        }
        
    }
    
    @IBOutlet weak var testPointButton: UIButton!
    @IBAction func tapPlusPoint(_ sender: UIButton) {
        var point = UserDefaults.standard.object(forKey: "point") as? Int
        if point == nil {
            point = 0
        }
        point! += 100
        UserDefaults.standard.set(point, forKey: "point")
        testPointButton.setTitle("\(String(describing: point))", for: .normal)

        print(point!)
    }
    func testPoint() {
        let point = UserDefaults.standard.object(forKey: "point") as? Int
        testPointButton.setTitle("\(String(describing: point))", for: .normal)
    }
    
    //MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.testPoint()
        self.styleFunction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshBearImagePoint()
        self.accessoryList = CoreDataManager.shared.initializeAccessoryList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(UserDefaults.standard.object(forKey: "accessory") as? String ?? "")
        print(self.accessoryImage.image ?? UIImage())
    }
    
    //MARK: Style Function
    private func refreshBearImagePoint() {
        let pants = UserDefaults.standard.object(forKey: "pants") as? String
        self.pantsImage.image = pants == nil ? UIImage() : UIImage(named: "\(String(describing: pants))")

        let shoes = UserDefaults.standard.object(forKey: "shoes") as? String
        self.shoesImage.image = shoes == nil ? UIImage() : UIImage(named: "\(String(describing: shoes))")
        
        let shirt = UserDefaults.standard.object(forKey: "shirt") as? String
        self.shirtImage.image = shirt == nil ? UIImage() : UIImage(named: "\(String(describing: shirt))")
        
        let accessory = UserDefaults.standard.object(forKey: "accessory") as? String
        self.accessoryImage.image = accessory == nil ? UIImage() : UIImage(named: "\(accessory ?? "")")
        
        let point = UserDefaults.standard.object(forKey: "point") as? Int
        self.pointLabel.text = point == nil ? String("0") : String(point ?? 0)
    }
    
    private func styleFunction() {
        self.view.backgroundColor = UIColor.NColor.background
        self.configureNavigationLabel()
        self.configureCollectionView()
        self.configureButtonsBackgroundView()
        self.configureButtons()
        self.configureBearImage()
    }
    
    private func configureNavigationLabel() {
        self.pointLabel.font = UIFont.NFont.noSearchedTextFont
        self.navigationTitle.font = UIFont.NFont.addWordNavigationTitle
    }
    
    private func configureButtonsBackgroundView() {
        self.buttonBackgroundView.backgroundColor = UIColor.NColor.white
        self.buttonBackgroundViewTopConstant.constant = UIScreen.main.bounds.height * 0.4
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.NColor.backgroundBrown
    }
    
    private func configureButtons() {
        self.closetButton.tag = 0
        self.accessoryButton.tag = 1
        self.shirtButton.tag = 2
        self.pantButton.tag = 3
        self.shoesButton.tag = 4
        
        self.closetButton.isSelected = true
        // isNeed?
        self.configureButtonState(buttonCollection: self.clothesButtonCollection)
    }
    
    private func configureBearImage() {
        self.bearWidth.constant = UIScreen.main.bounds.width * 0.5
        self.bearHeight.constant = UIScreen.main.bounds.height * 0.3
        
        self.clothesWidthCollection.forEach { width in
            width.constant = self.bearWidth.constant
        }
        self.clothesHeightCollection.forEach { height in
            height.constant = self.bearHeight.constant
        }
    }
    
    // Changing button image/backgroundColor by state
    private func configureButtonState(buttonCollection: [UIButton]) {
        var selectedTag = 0
        
        self.clothesButtonCollection.forEach { button in
            if button.isSelected {
                selectedTag = button.tag
            }
        }
        self.clothesButtonCollection.forEach { button in
            if button.tag == selectedTag {
                button.setImage(UIImage(named: "tab\(selectedTag)_fill"), for: .selected)
                button.backgroundColor = UIColor.NColor.backgroundBrown
            } else {
                button.setImage(UIImage(named: "tab\(selectedTag)"), for: .selected)
                button.backgroundColor = UIColor.NColor.white
            }
        }
    }
    
    //MARK: Alert
    private func alertBuyingClothes(accessory: Accessory) {
        let alert = UIAlertController(title: "구매하시겠습니까?", message: "\(accessory.price) 젤리가 필요합니다.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .destructive) { _ in
            alert.dismiss(animated: true)
        }
        let confirm = UIAlertAction(title: "확인", style: .default) { _ in
            var point = UserDefaults.standard.object(forKey: "point") as? Int
            if point! > Int(accessory.price) {
                point! -= Int(accessory.price)
                accessory.isBought = true
                UserDefaults.standard.set(point, forKey: "point")
                CoreDataManager.shared.saveContext()
                self.collectionView.reloadData()
            } else {
                self.alertNotEnoughPoint()
            }
        }
        
        [cancel, confirm].forEach(alert.addAction(_:))
        self.present(alert, animated: true)
    }
    
    private func alertAlreadyBought(accessory: Accessory) {
        let alert = UIAlertController(title: "착용하시겠습니까?", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        let confirm = UIAlertAction(title: "확인", style: .default) { _ in
            let accessoryImage = String(describing: accessory.imageName!)
            print(accessoryImage)
            self.accessoryImage.image = UIImage(named: "bear-\(accessoryImage)")
            UserDefaults.standard.set("bear-\(accessoryImage)", forKey: "accessory")
            
//            let accessoryImage = UserDefaults.standard.object(forKey: "accessory") as? String ?? ""
//            print(accessoryImage)
//            self.accessoryImage.image = UIImage(named: "bear-\(accessoryImage)")
        }
        [cancel, confirm].forEach(alert.addAction(_:))
        self.present(alert, animated: true)
    }
    
    private func alertNotEnoughPoint() {
        let alert = UIAlertController(title: "젤리가 부족합니다.", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "확인", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
}

extension PurchasingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.clothes {
        case .closet:
            return 0
        case .accessory:
            return CoreDataManager.shared.countAccessory()

        case .shirt:
            return 0

        case .pants:
            return 0

        case .shoes:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PurchasingCell", for: indexPath) as? PurchasingCell else { return UICollectionViewCell() }
        
        switch self.clothes {
        case .closet:
            return cell
        case .accessory:
            let accessory = self.accessoryList[indexPath.row]
            cell.purchasingImage.image = UIImage(named: "\(accessory.imageName ?? "")")
            cell.purchasingLabel.text = String("\(accessory.price)")
            cell.alreadyBoughtImage.isHidden = accessory.isBought ? false : true
            return cell

        case .shirt:
            return cell

        case .pants:
            return cell

        case .shoes:
            return cell
        }
    }
    
    private func initializeCloset() {
        self.accessoryList.forEach { accessory in
            var item = closetItem(imageString: "")
            if accessory.isBought {
                item.imageString = accessory.imageName!
                self.closetList.append(item)
            }
        }
    }
}

extension PurchasingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.clothes {
        case .closet:
            print("not yet")

        case .accessory:
            let accessory = self.accessoryList[indexPath.row]
            if accessory.isBought == true {
                self.alertAlreadyBought(accessory: accessory)
            } else {
                self.alertBuyingClothes(accessory: accessory)
            }
        case .shirt:
            print("not yet")
            
        case .pants:
            print("not yet")

        case .shoes:
            print("not yet")

        }
    }
    
    
}

extension PurchasingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 50) / 4, height: (UIScreen.main.bounds.width - 50) / 4 + 25)
    }
}
