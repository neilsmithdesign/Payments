//
//  AppStore.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import StoreKit

public final class AppStore: NSObject, PaymentsProcessing {
    
    
    // MARK: Interface
    public convenience init(configuration: AppStoreConfiguration, transactionObserver: SKPaymentTransactionObserver? = nil, productsRequest: ProductsRequest? = nil) {
        let controller = AppStoreController(
            productIdentifiers: configuration.productIdentifiers,
            transactionObserver: transactionObserver,
            productsRequest: productsRequest,
            simulatesAskToBuy: configuration.simulateAskToBuy
        )
        self.init(
            controller: controller,
            configuration: configuration,
            transactionObserver: transactionObserver,
            productsRequest: productsRequest
        )
    }
    
    init(controller: AppStoreController, configuration: AppStoreConfiguration, transactionObserver: SKPaymentTransactionObserver? = nil, productsRequest: ProductsRequest? = nil) {
        self.configuration = configuration
        self.receiptValidator = configuration.receiptValidator
        self.receiptLoader = configuration.receiptLoader
        self.storeController = controller
    }
    
    public weak var observer: PaymentsObserving?

    
    // MARK: Read only
    public private (set) var availableProducts: Set<Product> = []

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
    
    public func verifyPurchases() {
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
    
    public func add(observer: Any, forPaymentEvent kind: PaymentEventKind, selector: Selector) {
        NotificationCenter.default.addObserver(
            observer,
            selector: selector,
            name: kind.notification,
            object: nil
        )
    }
    
    public func remove(observer: Any, forPaymentEvent kind: PaymentEventKind) {
        NotificationCenter.default.removeObserver(observer, name: kind.notification, object: nil)
    }
    
}


// MARK: - Load products
public extension AppStore {
    
    func loadProducts() {
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

    public func purchase(_ product: Product) {
        storeController.purchase(product) { [weak self] result in
            self?.handle(payment: result)
        }
    }
    
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
            self.observer?.didCompletePurchase(self)
            PaymentEvent.Payment.Complete.notify(with: productIdentifier)
        }
    }
    
    private func didRestorePurchases(for productIdentifier: ProductIdentifier) {
        onMainThread {
            self.observer?.didRestorePurchases(self)
            PaymentEvent.Payment.Restored.notify(with: productIdentifier)
        }
    }
    
    private func paymentWasDeferred(for productIdentifier: ProductIdentifier) {
        let alert = PaymentDeferredAlert.standardMessage(for: productIdentifier)
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

public struct PaymentDeferredAlert {
    
    public let title: String
    public let message: String
    public let productIdentifier: String
    
    static func standardMessage(for productIdentifier: String) -> PaymentDeferredAlert {
        return .init(
            title: "Waiting For Approval",
            message: "Thank you! You can continue to use the app whilst your purchase is pending approval from your family organizer.",
            productIdentifier: productIdentifier
        )
    }
    
}
