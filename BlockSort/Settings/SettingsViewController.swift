//
//  SettingsViewController.swift
//  BlockSort
//
//  Created by VladyslavMac on 15.04.2022.
//

import UIKit
import Combine
import StoreKit

final class SettingsViewController: UIViewController {
	
	var resetIsConfirmed = false
	
	var request: SKProductsRequest!
	var products = [SKProduct]()
	
	var visualEffectView: UIVisualEffectView!
	
	var centralStackView: UIStackView!
	var adsOnButton: UIButton!
	var restoreButton: UIButton!
	var soundOnOffButton: UIButton!
	var shareButton: UIButton!
	var resetLevelButton: UIButton!
	var removeAdsButton: UIButton!
	var activityControl: UIActivityIndicatorView!
	var priceLabel: UILabel!
	var dismissButton: UIButton!
	
	override var prefersStatusBarHidden: Bool { true }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupVisualEffectView()
		setupCentralStack()
		setupRestoreButton()
		setupRemoveAdsButton()
		
		if !AppState.shared.adsAreOn() {
			restoreButton.isHidden = true
			adsOnButton.isHidden = true
			removeAdsButton.isHidden = true
			priceLabel.isHidden = true
			view.layoutIfNeeded()
		} else {
			validate()
			adsOnButton.isHidden = true
			restoreButton.isHidden = true
			removeAdsButton.isHidden = true
			StoreObserver.shared.finishedCallback = finishedCallback
		}
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(failedPurchasing),
			name: Notification.Name("com.blocksort.failedpuchasing"),
			object: nil)
	}
	
	func setupVisualEffectView() {
		visualEffectView = UIVisualEffectView(frame: view.bounds)
		visualEffectView.effect = UIBlurEffect(style: .systemThinMaterialDark)
		view.addSubview(visualEffectView)
	}
	
	func setupRemoveAdsButton() {
		removeAdsButton = UIButton()
		removeAdsButton.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: .semibold)
		removeAdsButton.setTitle(LocalizedString(key: .settingsPricing), for: .normal)
		removeAdsButton.titleLabel?.numberOfLines = 0
		removeAdsButton.titleLabel?.textAlignment = .center
		removeAdsButton.backgroundColor = .clear
		removeAdsButton.setTitleColor(.white, for: .normal)
		removeAdsButton.translatesAutoresizingMaskIntoConstraints = false
		removeAdsButton.addTarget(self, action: #selector(toggleAds), for: .touchUpInside)
		view.addSubview(removeAdsButton)
		
		priceLabel = UILabel()
		priceLabel.textColor = .white
		priceLabel.text = ""
		priceLabel.isHidden = true
		priceLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(priceLabel)
		
		activityControl = UIActivityIndicatorView(style: .medium)
		activityControl.color = .white
		activityControl.hidesWhenStopped = true
		activityControl.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(activityControl)
		
		NSLayoutConstraint.activate([
			removeAdsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			removeAdsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			removeAdsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
			removeAdsButton.heightAnchor.constraint(equalToConstant: 50),
			priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			priceLabel.topAnchor.constraint(equalTo: removeAdsButton.bottomAnchor),
			activityControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			activityControl.topAnchor.constraint(equalTo: removeAdsButton.bottomAnchor),
			activityControl.widthAnchor.constraint(equalToConstant: 20),
			activityControl.heightAnchor.constraint(equalToConstant: 20)
		])
		
		dismissButton = UIButton()
		dismissButton.setPreferredSymbolConfiguration(.init(pointSize: 28), forImageIn: .normal)
		dismissButton.setImage(.init(systemName: "multiply.circle.fill"), for: .normal)
		dismissButton.tintColor = .white
		dismissButton.backgroundColor = .clear
		dismissButton.setTitleColor(.white, for: .normal)
		dismissButton.translatesAutoresizingMaskIntoConstraints = false
		dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
		view.addSubview(dismissButton)
		
		NSLayoutConstraint.activate([
			dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
		])
	}
	
	func setupCentralStack() {
		
		let adsString = LocalizedString(key: .settingsAds)
		let soundString = LocalizedString(key: .settingsSound)
		let onString = LocalizedString(key: .settingsOn)
		let offString = LocalizedString(key: .settingsOff)
		
		let warningLabel = UILabel()
		warningLabel.text = LocalizedString(key: .settingsWarning)
		warningLabel.textColor = .gray
		warningLabel.font = .systemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
		
		adsOnButton = UIButton()
		adsOnButton.setTitle("\(adsString): \(onString)", for: .normal)
		adsOnButton.setTitleColor(.white, for: .normal)
		adsOnButton.addTarget(self, action: #selector(toggleAds), for: .touchUpInside)
		
		soundOnOffButton = UIButton()
		soundOnOffButton.setTitle("\(soundString): \(AppState.shared.soundsAreOn() ? onString : offString)", for: .normal)
		soundOnOffButton.setTitleColor(.white, for: .normal)
		soundOnOffButton.addTarget(self, action: #selector(toggleSound), for: .touchUpInside)
		
		shareButton = UIButton()
		shareButton.setTitle(LocalizedString(key: .settingsShare), for: .normal)
		shareButton.addTarget(self, action: #selector(shareWithFriends), for: .touchUpInside)
		
		resetLevelButton = UIButton()
		resetLevelButton.setTitle(LocalizedString(key: .settingsReset), for: .normal)
		resetLevelButton.setTitleColor(.red, for: .normal)
		resetLevelButton.addTarget(self, action: #selector(resetLevel), for: .touchUpInside)
		
		centralStackView = UIStackView(arrangedSubviews: [adsOnButton, soundOnOffButton, shareButton, resetLevelButton, warningLabel])
		centralStackView.axis = .vertical
		centralStackView.spacing = 30
		centralStackView.setCustomSpacing(0, after: resetLevelButton)
		centralStackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(centralStackView)
		
		NSLayoutConstraint.activate([
			centralStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			centralStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}
	
	func setupRestoreButton() {
		restoreButton = UIButton()
		restoreButton.setTitle(LocalizedString(key: .settingsRestore), for: .normal)
		restoreButton.setTitleColor(.white, for: .normal)
		restoreButton.translatesAutoresizingMaskIntoConstraints = false
		restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
		view.addSubview(restoreButton)
		NSLayoutConstraint.activate([
			restoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			restoreButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
		])
	}
	
	@objc func failedPurchasing() {
		let controller = UIAlertController(
			title: "Warning", message: "Could not purchase this item. Check your internet connection", preferredStyle: .alert)
		controller.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
		present(controller, animated: true, completion: nil)
	}
	
	@objc func toggleAds() {
		guard SKPaymentQueue.canMakePayments() else { return }
		guard let firstProduct = products.first else { return }
		buyNoAds(product: firstProduct)
	}
	
	@objc func toggleSound() {
		
		let soundString = LocalizedString(key: .settingsSound)
		let onString = LocalizedString(key: .settingsOn)
		let offString = LocalizedString(key: .settingsOff)
		
		let soundsIsOn = AppState.shared.soundsAreOn()
		AppState.shared.setSoundsState(isOn: !soundsIsOn)
		soundOnOffButton.setTitle("\(soundString): \(!soundsIsOn ? onString : offString)", for: .normal)
	}
	
	@objc func resetLevel() {
		if resetIsConfirmed {
			AppState.shared.setLevel(1)
			NotificationCenter.default.post(
				name: Notification.Name("com.blocksort.didResetProgress"),
				object: nil
			)
			resetLevelButton.setTitle(LocalizedString(key: .settingsReset), for: .normal)
			resetIsConfirmed = false
		} else {
			resetLevelButton.setTitle(LocalizedString(key: .settingsConfirm), for: .normal)
			resetIsConfirmed = true
		}
	}
	
	@objc func restore() {
		StoreObserver.shared.restore()
	}
	
	@objc func dismissSelf() {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func shareWithFriends() {
		guard let url = URL(string: "https://apps.apple.com/us/app/elements-system/id1618912865") else { return }
		let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
		if let popOverController = controller.popoverPresentationController {
			popOverController.sourceView = shareButton
		}
		present(controller, animated: true, completion: nil)
	}
}

extension SettingsViewController {
	func validate() {
		activityControl.startAnimating()
		let productIdentifiers = Set(["com.blockssort.noads"])
		request = SKProductsRequest(productIdentifiers: productIdentifiers)
		request.delegate = self
		request.start()
	}
	func buyNoAds(product: SKProduct) {
		guard SKPaymentQueue.canMakePayments() else { return }
		let payment = SKPayment(product: product)
		SKPaymentQueue.default().add(payment)
	}
	func finishedCallback() {
		UIView.animate(withDuration: 0.3) { [unowned self] in
			restoreButton.alpha = 0
			adsOnButton.alpha = 0
			removeAdsButton.alpha = 0
			priceLabel.alpha = 0
		} completion: { [unowned self] _ in
			restoreButton.isHidden = true
			adsOnButton.isHidden = true
			removeAdsButton.isHidden = true
			priceLabel.isHidden = true
		}
	}
}

extension SettingsViewController: SKProductsRequestDelegate {
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		if !response.products.isEmpty {
			products = response.products
			if let firstProduct = products.first {
				DispatchQueue.main.async { [unowned self] in
					priceLabel.text = "$ \(firstProduct.price)"
					activityControl.stopAnimating()
					priceLabel.isHidden = false
					restoreButton.isHidden = false
					adsOnButton.isHidden = false
					removeAdsButton.isHidden = false
				}
			}
		}
//		for invalidIdentifier in response.invalidProductIdentifiers {
//		}
	}
	
	func request(_ request: SKRequest, didFailWithError error: Error) {
		print("FAILED")
	}
}
