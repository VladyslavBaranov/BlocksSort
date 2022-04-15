//
//  SettingsViewController.swift
//  BlockSort
//
//  Created by VladyslavMac on 15.04.2022.
//

import UIKit

final class SettingsViewController: UIViewController {
	
	var visualEffectView: UIVisualEffectView!
	var removeAdsButton: UIButton!
	var dismissButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		visualEffectView = UIVisualEffectView(frame: view.bounds)
		visualEffectView.effect = UIBlurEffect(style: .systemMaterial)
		view.addSubview(visualEffectView)
		
		setupRemoveAdsButton()
	}
	
	func setupRemoveAdsButton() {
		removeAdsButton = UIButton()
		removeAdsButton.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: .semibold)
		removeAdsButton.setTitle("Remove ads & Infinite reloads", for: .normal)
		removeAdsButton.backgroundColor = .clear
		removeAdsButton.setTitleColor(.white, for: .normal)
		removeAdsButton.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(removeAdsButton)
		
		NSLayoutConstraint.activate([
			removeAdsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			removeAdsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			removeAdsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
			removeAdsButton.heightAnchor.constraint(equalToConstant: 50)
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
	
	@objc func dismissSelf() {
		dismiss(animated: true, completion: nil)
	}
}
