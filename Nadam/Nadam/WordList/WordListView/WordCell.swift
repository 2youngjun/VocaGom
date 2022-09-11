//
//  WordCell.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/12.
//

import UIKit

class WordCell: UICollectionViewCell {
    
    @IBOutlet weak var wordName: UILabel!
    @IBOutlet weak var wordMeaning: UILabel!
    @IBOutlet weak var starButton: UIButton!
    
    // required init 생성자를 통해 storyboard 에서 빌드될 때 객체를 정의할 수 있다.
}
