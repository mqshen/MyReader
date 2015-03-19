/// The union operator for two `SetType`s.
infix operator ∪ {}

/// The intersection operator for two `SetType`s.
infix operator ∩ {}

/// A `SetType` is a type of collection that contains only a single instance of a given value. The order of the set is
/// also not guaranteed.
public protocol SetType : SequenceType {
    typealias ItemType : Equatable
    
    /// Creates an empty `Set` instance.
    init()
    
    //
    // MARK: Immutable Set Operations
    //
    
    /// Returns `true` iff the current `SetType` contains all of the members of `set`.
    func isSubsetOfSet(set: Self) -> Bool
    
    /// Returns `true` iff the current `SetType` contains the given `item`.
    func contains(item: ItemType) -> Bool
    
    /// Returns `true` iff there are no items contained in the current `SetType` instance.
    var isEmpty: Bool { get }
    
    /// Returns the number of items in the current `Set` instance.
    var size: Int { get }
    
    //
    // MARK: Mutable Set Operations
    //
    
    /// Adds `item` to the current `SetType` instance, if `item` is not already present.
    mutating func add(item: ItemType) -> Self
    
    /// Removes `item` from the current `SetType` instance.
    mutating func remove(item: ItemType) -> Self
    
    /// Removes all of the items from the `SetType` instance.
    mutating func removeAll() -> Self
    
    //
    // MARK: Operators to implement
    //
    
    /**
    * Takes two `SetType` instances and generates a new `SetType` instance that contains
    * only the unique values between the two sets.
    */
    func ∪(rhs: Self, lhs: Self) -> Self
    
    /**
    * Takes two `SetType` instances and generates a new `SetType` instance that contains
    * only the common values between the two sets.
    */
    func ∩(rhs: Self, lhs: Self) -> Self
}
