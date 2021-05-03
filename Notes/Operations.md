# Operations

* **Operation** - responsible for single sync task, abstract and not used directly
* **BlockOperation** - system defined operation subclass

Set up Block
>```
>let blockOperation = BlockOperation {
>    print("Executing")
>}

>`let queue = OperationQueue()`

>`queue.addOperation(blockOperation)`

Or More Directly 

>```
>queue.addOperation {
>    print("Executing")
>}

Using dependencies
> `queue.addOperations([contentImportOperation, contentImportOperation2], waitUntilFinished: true)`

Custom Operation Class
>```
>final class ContentImportOperation: Operation {
>    let itemProvider: NSItemProvider
>    
>    init(itemProvider: NSItemProvider) {
>        self.itemProvider = itemProvider
>        super.init()
>    }
>    
>    override func main() {
>        guard !isCancelled else { return }
>        print("Importing Content")
>        //TODO
>    }
>}

Operation States 
* Ready
* Executing
* Finished
* Canceled

Can only execute once. When using custom implementations need to manually check the cancel state
