//: [Previous](@previous)

import Foundation
import UIKit

//: Specialized Enum Dict Without Optionals
struct EnumMap<Enum: Hashable & CaseIterable, Value> {
    private var indexes = [Index]()
    private var values = [Enum: Value]()
    
    init(resolver: (Enum) -> Value) {
        for (offset, key) in Enum.allCases.enumerated() {
            indexes.append(Index(offset: offset, key: key))
            values[key] = resolver(key)
        }
    }
}

//: Create an Index struct before conforming to Collection
extension EnumMap {
    struct Index: Comparable {
        static func <(lhs: Index, rhs: Index) -> Bool {
            lhs.offset < rhs.offset
        }
    
        fileprivate var offset: Int
        fileprivate var key: Enum? = nil
    }
    
    typealias Element = (key: Enum, value: Value)
}

//: Conform To Collection

extension EnumMap: Collection {
    var startIndex: Index { indexes.first! }
    var endIndex: Index { Index(offset: indexes.count)}
    
    subscript(index: Index) -> Element {
        guard let key = index.key else {
            preconditionFailure("Attempted to subscript EnumMap with an invalid index")
        }
        return (key, values[key]!)
    }
    
    func index(after index: Index) -> Index {
        let offset = index.offset + 1
        
        guard offset < indexes.count else { return endIndex }
        return indexes[offset]
    }
}

extension EnumMap {
    subscript(key: Enum) -> Value {
        get { values[key]! }
        set { values[key] = newValue }
    }
}

//: ## Example

enum TextStyle: CaseIterable {
    case title
    case subtitle
    case sectionTitle
    case body
    case comment
}

let fonts = EnumMap<TextStyle, UIFont> { type in
    switch type {
    
    case .title: return .preferredFont(forTextStyle: .headline)
    case .subtitle: return .preferredFont(forTextStyle: .subheadline)
    case .sectionTitle: return .preferredFont(forTextStyle: .title2)
    case .body: return .preferredFont(forTextStyle: .body)
    case .comment: return .preferredFont(forTextStyle: .footnote)
    }
}

let test = fonts[.body]

//: [Next](@next)
