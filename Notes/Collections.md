# Collections

Check if a set value was inserted by using `.inserted`
>`let wasInserted = mySet.insert(value).inserted`

## Conformance To Collection

>```
>struct EnumMap<Enum: Hashable & CaseIterable, Value> {
>    private var indexes = [Index]()
>    private var values = [Enum: Value]()
>    
>    init(resolver: (Enum) -> Value) {
>        for (offset, key) in Enum.allCases.enumerated() {
>            indexes.append(Index(offset: offset, key: key))
>            values[key] = resolver(key)
>        }
>    }
>}

>```
>extension EnumMap {
>    struct Index: Comparable {
>        static func <(lhs: Index, rhs: Index) -> Bool {
>            lhs.offset < rhs.offset
>        }
>    
>        fileprivate var offset: Int
>        fileprivate var key: Enum? = nil
>    }
>    
>    typealias Element = (key: Enum, value: Value)
>}

>```
>extension EnumMap: Collection {
>    var startIndex: Index { indexes.first! }
>    var endIndex: Index { Index(offset: indexes.count)}
>    
>    subscript(index: Index) -> Element {
>        guard let key = index.key else {
>            preconditionFailure("Attempted to subscript EnumMap with an invalid index")
>        }
>        return (key, values[key]!)
>    }
>    
>    func index(after index: Index) -> Index {
>        let offset = index.offset + 1
>        
>        guard offset < indexes.count else { return endIndex }
>        return indexes[offset]
>    }
>}