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

// 테스트 결과 전달
protocol SendTestWordResultDelegate: AnyObject {
    func sendTestWordResult(wordTests: [TestWords])
}

// 정답/오답 단어 결과창 전달
protocol SendResultWordDelegate: AnyObject {
    func sendTestWordDelegate(resultWord: [TestWords], color: UIColor, titleText: String)
}
