/**
* This is an implementation the `Set` protocol that is backed by a `Dictionary`. There is no guarantee for the order
* of the items within the `HashSet` at anytime during the instance's lifetime.
*
* This class performs at the same performance as the `Dictionary for all operations, other than traversal.
*/
public struct HashSet<T: Hashable> : SetType {
    private var data : Dictionary<T, Int>
    
    /// The starting index value for the set.
    public var startIndex: Int { return 0 }
    
    /// The last index value for the set.
    public var endIndex: Int { return data.count }
    
    public init() {
        data = [T:Int]()
    }
    
    public func isSubsetOfSet(set: HashSet<T>) -> Bool {
        for item in data.keys {
            if set.contains(item) == false {
                return false
            }
        }
        return true
    }
    
    public func contains(item: T) -> Bool {
        return data[item] == nil ? false : true
    }
    
    
    public var isEmpty: Bool {
        return data.count == 0
    }
    
    public var size: Int {
        return data.count
    }
    
    public mutating func add(item: T) -> HashSet<T> {
        if data[item] == nil {
            data[item] = 1
        }
        return self
    }
    
    public mutating func remove(item: T) -> HashSet<T> {
        data.removeValueForKey(item)
        return self
    }
    
    public mutating func removeAll() -> HashSet<T> {
        data.removeAll(keepCapacity: false)
        return self
    }
}

/// Returns a new `Set` that contains the unique values of both `rhs` and `lhs`.
public func ∪<T>(rhs: HashSet<T>, lhs: HashSet<T>) -> HashSet<T> {
    var union = rhs
    for item in lhs {
        union.add(item.0)
    }
    
    return union
}

/// Returns a new `Set` that contains the common values between both `rhs` and `lhs`.
public func ∩<T>(rhs: HashSet<T>, lhs: HashSet<T>) -> HashSet<T> {
    var intersect = HashSet<T>()
    for item in rhs {
        if lhs.contains(item.0) {
            intersect.add(item.0)
        }
    }
    
    return intersect
}

extension HashSet : SequenceType {
    public func generate() -> GeneratorOf<T> {
        var keyGenerator = self.data.keys.generate()
        return GeneratorOf<T> {
            if let key = keyGenerator.next() {
                return key
            }
            else {
                return .None
            }
        }
    }
}

//extension HashSet : ArrayLiteralConvertible {
//    public static func convertFromArrayLiteral(elements: T...) -> HashSet<T> {
//        var set = HashSet<T>()
//        
//        for element in elements {
//            set.add(element)
//        }
//        
//        return set
//    }
//}
