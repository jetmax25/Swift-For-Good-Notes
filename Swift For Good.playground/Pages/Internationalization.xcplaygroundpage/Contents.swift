//: [Previous](@previous)

import Foundation
import UIKit

enum LocalizationKey: String, CaseIterable {
    case title_examples
    case title_languages
    case title_dates_times
}

extension LocalizationKey {
    var localizedString: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}

extension UILabel {
    func setLocalizedText(_ localizationKey: LocalizationKey) {
        self.text = localizationKey.localizedString
    }
}

//: [Next](@next)
