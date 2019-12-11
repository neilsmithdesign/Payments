//
//  AppStore.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import StoreKit

/// The AppStore is the main public interface for StoreKit related interactions
/// Validate the receipt, load in-app purchase products and make or restore purchases.
public final class AppStore: NSObject, PaymentsProcessing {
    
    
    // MARK: Interface
    
    /**
     Use your AppStoreConfiguration to initialize an AppStore instance.
     */
    public convenience init(configuration: AppStoreConfiguration) {
        let controller = AppStoreController(
            productIdentifiers: configuration.productIdentifiers,
            transactionObserver: configuration.transactionObserver,
            simulatesAskToBuy: configuration.simulateAskToBuy
        )
        self.init(
            controller: controller,
            configuration: configuration
        )
    }
    
    init(controller: AppStoreController, configuration: AppStoreConfiguration) {
        self.configuration = configuration
        self.receiptValidator = configuration.receiptValidator
        self.receiptLoader = configuration.receiptLoader
        self.storeController = controller
    }
    
    /// Assign an observer to be notified of receipt validation
    /// and App Store transaction events. All calls via the observer
    /// are dispatched on the main thread.
    public weak var observer: PaymentsObserving?

    
    // MARK: Read only
    
    /// When loaded, the available products a user can purchase in your app.
    public private (set) var availableProducts: Set<Product> = []

    /// Determines whether a user is authorized to make payments.
    public var canMakePayments: Bool {
        return storeController.canMakePayments
    }

    
    // MARK: Private
    private let storeController: StoreControlling

    private var productIdentifiers: Set<String> {
        return storeController.productIdentifiers
    }

    
    // MARK: Private
    private let configuration: AppStoreConfiguration
    private let receiptValidator: ReceiptValidating?
    private let receiptLoader: ReceiptLoading?
    private var receiptData: Data?
    
}


// MARK: - Receipt Verification
extension AppStore {
    
    
    /// Uses the supplied 'loader' and 'validator' to perform
    /// receipt validation. As receipt validation can be either
    /// local or remote, this method is asynchronous. If successful,
    /// the result is posted via the observer method:
    /// func payments(_ payments: PaymentsProcessing, didValidate receipt: AppStoreReceipt)
    /// Otherwise the error method is called
    public func validateReceipt() {
        guard let loader = receiptLoader else {
            return
        }
        loader.load(using: configuration.fileInspector) { [weak self] result in
            self?.handle(receiptLoading: result)
        }
    }
    
    private func handle(receiptLoading result: ReceiptLoadingResult) {
        switch result {
        case .success(let data):
            self.receiptData = data
            guard let validator = receiptValidator else {
                return
            }
            validator.validate(receipt: data) { [weak self] validationResult in
                self?.handle(validation: validationResult)
            }
        case .failure(let error):
            observer?.payments(self, didFailWith: .receiptError(.loading(error)))
        }
    }

    private func handle(validation result: ReceiptValidationResult) {
        switch result {
        case .success(let receipt):
            observer?.payments(self, didValidate: receipt)
        case .failure(let error):
            observer?.payments(self, didFailWith: .receiptError(.validation(error)))
        }
    }
    
}


// MARK: - Notifications
extension AppStore {
    
    /// Convenience method for observing a payment event
    public static func add(observer: Any, forPaymentEvent kind: PaymentEventKind, selector: Selector) {
        NotificationCenter.default.addObserver(
            observer,
            selector: selector,
            name: kind.notification,
            object: nil
        )
    }
    
    /// Convenience method for removing an observer of a payment event
    public static func remove(observer: Any, forPaymentEvent kind: PaymentEventKind) {
        NotificationCenter.default.removeObserver(observer, name: kind.notification, object: nil)
    }
    
}


// MARK: - Load products
extension AppStore {
        
    /// Loads the available products as configured in App Store Connect
    public func loadProducts() {
        storeController.loadProducts { [weak self] result in
            switch result {
            case .success(let products):
                self?.availableProducts = products
                self?.didLoad(products)
            case .failure(let error):
                self?.failedToLoadProducts(with: error)
            }
        }
    }
    
}


// MARK: - Purchases
extension AppStore {

    
    /// Initiates the payment flow for purchasing the supplied product
    /// The result is posted to the observer, and via the notification:
    /// 'PaymentEvent.Payment.Complete' if successful
    /// 'PaymentEvent.Payment.Restored' if purchase is a restoration
    /// 'PaymentEvent.Payment.Deferred' if purchase requries approval from someone (such as a parent)
    /// 'PaymentEvent.Payment.Failed' if there was an error whilst trying to process the payment
    public func purchase(_ product: Product) {
        storeController.purchase(product) { [weak self] result in
            self?.handle(payment: result)
        }
    }
    
    /// Initiates the purchase restoration process
    public func restorePreviousPurchases() {
        storeController.restorePurchases { [weak self] result in
            self?.handle(payment: result)
        }
    }
    
    private func handle(payment result: PaymentResult) {
        switch result {
        case .success(let identifier):
            self.didCompletePurchase(for: identifier)
        case .restored(let identifier):
            self.didRestorePurchases(for: identifier)
        case .deferred(let identifier):
            self.paymentWasDeferred(for: identifier)
        case .failure(let error):
            self.paymentFailed(with: PaymentsError(error))
        }
    }
    
}


// MARK: - Observer calls
extension AppStore {
    
    private func didLoad(_ products: Set<Product>) {
        onMainThread {
            self.observer?.payments(self, didLoad: products)
            PaymentEvent.LoadProducts.Succeeded.notify(with: products)
        }
    }
    
    private func failedToLoadProducts(with error: PaymentsError) {
        guard case PaymentsError.productLoadRequestFailed = error else { return }
        onMainThread {
            self.observer?.payments(self, didFailWith: error)
            PaymentEvent.LoadProducts.Failed.notify(with: error)
        }
    }
    
    private func cannotMakePayments() {
        onMainThread {
            self.observer?.userCannotMake(payments: self)
            PaymentEvent.CannotMakePayments.notify(with: nil)
        }
    }
    
    private func didCompletePurchase(for productIdentifier: ProductIdentifier) {
        onMainThread {
            self.observer?.payments(self, didCompletePurchaseForProductWith: productIdentifier)
            PaymentEvent.Payment.Complete.notify(with: productIdentifier)
        }
    }
    
    private func didRestorePurchases(for productIdentifier: ProductIdentifier) {
        onMainThread {
            self.observer?.payments(self, didRestorePurchaseForProductWith: productIdentifier)
            PaymentEvent.Payment.Restored.notify(with: productIdentifier)
        }
    }
    
    private func paymentWasDeferred(for productIdentifier: ProductIdentifier) {
        let alert = PaymentDeferredAlert.standardMessage(productIdentifier: productIdentifier)
        onMainThread {
            self.observer?.payments(self, paymentWasDeferred: alert)
            PaymentEvent.Payment.Deferred.notify(with: alert)
        }
    }
    
    private func paymentFailed(with error: PaymentsError) {
        onMainThread {
            self.observer?.payments(self, didFailWith: error)
            PaymentEvent.Payment.Failed.notify(with: error)
        }
    }
    
    private func onMainThread(_ closure: @escaping () -> Void) {
        DispatchQueue.main.async { closure() }
    }
    
}
