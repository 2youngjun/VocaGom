//
//  Nadam+Font.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/05.
//

import UIKit

enum GmarketSansWeight: String {
    case bold = "GmarketSansTTFBold"
    case light = "GmarketSansTTFLight"
    case medium = "GmarketSansTTFMedium"
}

private let customFonts: [UIFont.TextStyle: UIFont] = [
    .largeTitle: UIFont(name: "GmarketSansTTFBold", size: 24)!,
    .title1: UIFont(name: "GmarketSansTTFBold", size: 20)!,
    .title2: UIFont(name: "GmarketSansTTFMedium", size: 18)!,
    .title3: UIFont(name: "GmarketSansTTFBold", size: 17)!,
    .headline: UIFont(name: "GmarketSansTTFMedium", size: 17)!,
    .body: UIFont(name: "GmarketSansTTFMedium", size: 16)!,
    .callout: UIFont(name: "GmarketSansTTFLight", size: 15)!,
    .subheadline: UIFont(name: "GmarketSansTTFMedium", size: 15)!,
    .footnote: UIFont(name: "GmarketSansTTFLight", size: 12)!,
    .caption1: UIFont(name: "GmarketSansTTFMedium", size: 14)!,
    .caption2: UIFont(name: "GmarketSansTTFMedium", size: 12)!
]

extension UIFont {
    // 기기 폰트 사이즈 대응하도록 Scale 조정
    private static func NadamFont(forTextStyle style: UIFont.TextStyle) -> UIFont {
        let customFont = customFonts[style]!
        let metrics = UIFontMetrics(forTextStyle: style)
        let scaledFont = metrics.scaledFont(for: customFont)

        return scaledFont
    }
    
    // 필요한 폰트 종류는 여기에 추가하기
    enum NFont {
        static var addWordNavigationTitle: UIFont{ UIFont.NadamFont(forTextStyle: .headline) }
        static var addWordButtonLabel: UIFont{ UIFont.NadamFont(forTextStyle: .subheadline) }
        static var wordListTitleLabel: UIFont{ UIFont.NadamFont(forTextStyle: .title1) }
    }
}
