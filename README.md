Payments is a light weight framework for handling common StoreKit transactions on iOS.


## Note
Although I use this code in my personal projects, it is not intended to be used as a library. It is for illustration purposes only. However, please feel free to browse the source for inspiration.


## Installation

Install as a dependency with the Swift Package Manager using the URL: `https://github.com/neilsmithdesign/Payments.git`
Be sure to use from version `0.3.0` onwards.
In Xcode 11, you can do so by going to `File` > `Swift Packages` > `Add Package Dependency...`


## Get Started

### Configure for your app

```swift

// 1: Declare the url on your server for remote receipt validation
let url = URL(string: "https://...")

// 2: Create a configuration
let config = AppStoreConfiguration(
    environment: .production,
    receiptConfiguration: .appStore(validation: .remote(url), bundle: .main),
    productIdentifiers: ["YOUR_PRODUCT_IDENTIFIERS"]
)

// 3: Create an instance of AppStore and pass in your configuration
let appStore = AppStore(configuration: config)

```

### Observering changes

You can get notified of updates from StoreKit two different ways. Firstly, with an observer (via the delegate pattern). 

```swift

class MyObservingClass: PaymentsObserving {

    let appStore: AppStore
    
    init() {
    
        // ...
    
        // Assign your observer
        appStore.observer = self
        
        
        // Perform an action
        appStore.loadProducts()
        
    }

    // Receive update via protocol method
    func payments(_ payments: PaymentsProcessing, didLoad products: Set<Product>) {
        
        // do something with products...
        
    }
 
 
}

```

See `PaymentsObserving.swift` for all observer protocol methods.

You can also assign subscribers to individual notifications related to each of these observer methods. These are broadcast by NotificationCenter. Use the convenience API anywhere in your app

```swift

class MyProductListModel {

    init() {
        
        // Add your observation for a single event
        AppStore.add(observer: self, forPaymentEvent: .loadProductsSucceeded, selector(didLoadProducts(_:)))
    
    }
    
    
    @objc private func didLoadProducts(_ notification: Notification) {
    
        // Use the convenience type for obtaining content from the notification 
        guard let products = PaymentEvent.LoadProducts.Succeeded.init(notification)?.content else { return }
        
        // do something with products...
    
    }

}


```

See `PaymentsEvent.swift` and `PaymentsEventKind.swift` for all possible notifications.


### Remote receipt validation

To perform remote receipt validation, provide a URL (on your own server) to send the encoded app receipt data to. After validating with Apple, respond with JSON which can be parsed into an instance of `AppStoreReceipt`.  See `AppStoreReceipt.swift` and `InAppPurchaseReceipt.swift` for JSON keys and decoding approach. These two types expect JSON in the same form that is supplied by Apple ([see here](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html))


```swift

// during configuration
let config = AppStoreConfiguration(
    environment: .production,
    receiptConfiguration: .appStore(validation: .remote(url, MyDecodableType.self), bundle: .main),
    productIdentifiers: ["YOUR_PRODUCT_IDENTIFIERS"]
) 


// at app launch
appStore.validateReceipt()


// your observer
func payments(_ payments: PaymentsProcessing, didValidate receipt: AppStoreReceipt) {
    
    // do something with the receipt
    
}

```

### Local receipt validation

You can specify if you'd like to perform receipt validation locally, however, you will have to provide your own implementation with a type that conforms to `ReceiptValidatingLocally`.

If you would like to see an example implementaiton, I have created [one here](https://github.com/neilsmithdesign/PaymentsExample).

IMPORTANT NOTE: the example implementation does not guarantee your app will be immune from attacks to circumvent your receipt validation logic. Always take concerted steps to obfuscate your code when validating receipts locally. The exmaple is for learning purposes only. 


### Make purchases

```swift

// initiate a payment
appStore.purchase(selectedProduct)

// ...payment flow and user confirmation

// your observer 
func payments(_ payments: PaymentsProcessing, didCompletePurchaseForProductWith identifier: ProductIdentifier) {
    
    // do something in response to a successful purchase 
    
}


```

