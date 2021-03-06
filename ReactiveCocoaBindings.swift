import Foundation

// So I expect the ReactiveCocoa fellows to figure out a replacement API for the RAC macro.
// Currently, I don't see one there, so we'll use this solution until an official one exists.

// Pulled from http://www.scottlogic.com/blog/2014/07/24/mvvm-reactivecocoa-swift.html

public struct RAC  {
    var target: NSObject
    var keyPath: String
    var nilValue: AnyObject?
    
    public init(_ target: NSObject, _ keyPath: String, nilValue: AnyObject? = nil) {
        self.target = target
        self.keyPath = keyPath
        self.nilValue = nilValue
    }
    
    func assignSignal(signal : RACSignal) -> RACDisposable {
        return signal.setKeyPath(self.keyPath, onObject: self.target, nilValue: self.nilValue)
    }
}

infix operator <~ {
    associativity right
    precedence 90
}

public func <~ (rac: RAC, signal: RACSignal) -> RACDisposable {
    return signal ~> rac
}

public func ~> (signal: RACSignal, rac: RAC) -> RACDisposable {
    return rac.assignSignal(signal)
}

public func RACObserve(target: NSObject, keyPath: String) -> RACSignal {
    return target.rac_valuesForKeyPath(keyPath, observer: target)
}

public func RACOptionalObserve(target: NSObject?, keyPath: String) -> RACSignal? {
    return target?.rac_valuesForKeyPath(keyPath, observer: target)
}

extension RACSignal {

    func reactNextAs<T>(nextClosure:(T) -> ()) -> () {
        subscribeNext {
            (next: AnyObject!) -> () in
            nextClosure(next as! T)
        }
    }
    
    func reactNext(nextClosure:() -> ()) -> () {
        subscribeNext {
            (next: AnyObject!) -> () in
            nextClosure()
        }
    }
}

extension RACStream {

    func filterAs<T>(block: (T) -> Bool) -> Self {
        return filter({(value: AnyObject!) in
            if let casted = value as? T {
                return block(casted)
            }
            return false
        })
    }

    func mapAs<T, U: AnyObject>(block: (T) -> U) -> Self {
        return map({(value: AnyObject!) in
            if let casted = value as? T {
                return block(casted)
            }
            return nil
        })
    }
}
