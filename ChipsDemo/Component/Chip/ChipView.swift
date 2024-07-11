import Foundation
import UIKit
import Combine
import SnapKit

protocol ChipView: UIView {
    associatedtype Configuration
    
    var textLimit: Int { get }
    var chipsPublisher: AnyPublisher<[String], Never> { get }
    var exceededLimitPublisher: AnyPublisher<Bool, Never> { get }
    
    func config(with configuration: Configuration)
    func isCharacterCountExceedingLimit(inputText: String, currentChips: [String]) -> Bool
}

extension ChipView {
    func isCharacterCountExceedingLimit(inputText: String, currentChips: [String]) -> Bool {
        if inputText.isEmpty { return false }
        
        let stringWithoutCommas = inputText.replacingOccurrences(of: ",", with: "")
        let currentTotalLength = currentChips.joined(separator: ",").count

        if (currentTotalLength + stringWithoutCommas.count + 1) <= textLimit {
            return false
        }
        return true
    }
}
