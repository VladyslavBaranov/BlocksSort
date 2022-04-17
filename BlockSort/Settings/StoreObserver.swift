//
//  StoreObserver.swift
//  BlockSort
//
//  Created by VladyslavMac on 16.04.2022.
//

import StoreKit

extension Notification.Name {
	static let adsDidBecomeUnavailable = "com.blocksort.adsDidBecomeUnavailable"
	static let didResetProgress = "com.blocksort.didResetProgress"
}

final class StoreObserver: NSObject, SKPaymentTransactionObserver {
	
	static let shared = StoreObserver()
	
	var finishedCallback: (() -> ())?
	
	func restore() {
		SKPaymentQueue.default().restoreCompletedTransactions()
	}
	
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			switch transaction.transactionState {
			case .purchasing:
				break
			case .purchased:
				NotificationCenter.default.post(
					name: Notification.Name("com.blocksort.adsDidBecomeUnavailable"),
					object: nil
				)
				finishedCallback?()
				SKPaymentQueue.default().finishTransaction(transaction)
			case .failed:
				SKPaymentQueue.default().finishTransaction(transaction)
			case .restored:
				NotificationCenter.default.post(
					name: Notification.Name("com.blocksort.adsDidBecomeUnavailable"),
					object: nil
				)
				finishedCallback?()
				SKPaymentQueue.default().finishTransaction(transaction)
			case .deferred:
				break
			@unknown default:
				break
			}
		}
	}
}
