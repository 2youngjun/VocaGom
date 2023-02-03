//
//  Protocol+.swift
//  Nadam
//
//  Created by 이영준 on 2023/02/03.
//

import UIKit

// 카메라 촬영 이미지 전달
protocol CameraPictureDelegate: AnyObject {
    func sendCameraPicture(picture: UIImage)
}

// 이미지의 단어 중 선택한 단어 전달
protocol SendWordNameDelegate: AnyObject {
    func sendWord(wordName: String)
}
