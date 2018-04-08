
import UIKit

final class Observable<T> {
    init(_ value: T) {
        self.value = value
    }
    
    var value: T {
        didSet {
            changeHandlers.forEach({ $0.handler(value) })
        }
    }
    
    typealias ChangeHandler = ((T) -> Void)
    private var changeHandlers: [(identifier: Int, handler: ChangeHandler)] = []
    
    /**
     Adds observer to the value.
     - parameter initial: The handler is run immediately with initial value.
     - parameter handler: The handler to execute when value changes.
     - returns: Identifier of the observer.
     */
    @discardableResult func observe(initial: Bool = false, handler: @escaping ChangeHandler) -> Int {
        let identifier = UUID().uuidString.hashValue
        changeHandlers.append((identifier, handler))
        guard initial else { return identifier }
        handler(value)
        return identifier
    }
    
    /**
     Removes observer to the value.
     - parameter observer: The observer to remove.
     */
    func removeObserver(_ observer: Int) {
        changeHandlers = changeHandlers.filter({ $0.identifier != observer })
    }
}

final class Pantry {
    let jams = Observable([Jam(flavour: .apple)])
    
    func add(jam: Jam) {
        jams.value.append(jam)
    }
}

struct Jam {
    enum Flavour: String {
        case apple, orange
    }
    
    let flavour: Flavour
    
    init(flavour: Flavour) {
        self.flavour = flavour
    }
}

let pantry = Pantry()
print("Adding count and contents observers.")
let observer = pantry.jams.observe { (jams) in
    print("Pantry now has \(jams.count) jars of jam.")
}
pantry.jams.observe(initial: true) { (jams) in
    let contents = jams.map({ $0.flavour.rawValue }).joined(separator: ", ")
    print("Jams in pantry: \(contents)")
}
print("Adding jam to pantry.")
pantry.add(jam: Jam(flavour: .orange))

print("Removing count observer.")
pantry.jams.removeObserver(observer)
print("Adding jam to pantry.")
pantry.add(jam: Jam(flavour: .apple))
