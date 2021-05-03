//: [Previous](@previous)
//: # Operations

import Foundation
//: [Next](@next)


let blockOperation = BlockOperation {
    print("Executing")
}

let queue = OperationQueue()
queue.addOperation(blockOperation)

//: Can also use queue Directly
queue.addOperation {
    print("Implied Block")
}

//: Custom Import Override
final class ContentImportOperation: Operation {
    let itemProvider: NSItemProvider
    
    init(itemProvider: NSItemProvider) {
        self.itemProvider = itemProvider
        super.init()
    }
    
    override func main() {
        guard !isCancelled else { return }
        print("Importing Content")
        //TODO
    }
}

let fileURL = URL(fileURLWithPath: "")
let contentImportOperation = ContentImportOperation(itemProvider: NSItemProvider(contentsOf: fileURL)!)
contentImportOperation.completionBlock = {
    print("Complete")
}
queue.addOperation(contentImportOperation)
//: Can add multiple
//queue.addOperations([contentImportOperation, contentImportOperation2], waitUntilFinished: true)
//: ## Dependencies
