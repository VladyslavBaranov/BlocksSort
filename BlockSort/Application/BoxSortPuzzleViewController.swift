//
//  BoxSortPuzzleViewController.swift
//  BlockSort
//
//  Created by Vladyslav Baranov on 10.04.2022.
//

import UIKit
import SceneKit
import StoreKit
import GoogleMobileAds

final class BoxSortPuzzleViewController: UIViewController {
    
	override var prefersStatusBarHidden: Bool {
		true
	}

	var reloadCount = AppState.shared.adsAreOn() ? 2 : .max
	var rewardedAd: GADRewardedAd!
	var bannerView: GADBannerView!
	
    private var stepBackButton: UIButton!
    private var reloadButton: UIButton!
	private var settingsButton: UIButton!
    private var levelLabel: UILabel!
	private var reloadCountLabel: UILabel!
    private var puzzleSceneView: BoxSortPuzzleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		BlockColumn.audioSource = SCNAudioSource(named: "putSound.mp3")
		BlockColumn.audioSource.load()
		
		let config = BlockColumnPoolConfiguration()
		
        puzzleSceneView = BoxSortPuzzleView(frame: view.frame)
		puzzleSceneView.pool = BlockColumnPool.createPool(
			colorCount: config.colorCount,
			emptyPlatformsCount: config.emptyColumnsCount,
			mode: config.mode,
			delegate: self
		)
		puzzleSceneView.resetPool()
        puzzleSceneView.allowsCameraControl = true
        puzzleSceneView.autoenablesDefaultLighting = true
        puzzleSceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(puzzleSceneView)
        
        let anim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        anim.toValue = 1
        anim.fromValue = 0
        anim.duration = 2
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        puzzleSceneView.layer.add(anim, forKey: nil)
        
        NSLayoutConstraint.activate([
            puzzleSceneView.topAnchor.constraint(equalTo: view.topAnchor),
            puzzleSceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            puzzleSceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            puzzleSceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        setupUIControls()
		
		if AppState.shared.adsAreOn() {
			setupBannerAd()
			loadRewardedAds()
		}
    }
    
    func setupUIControls() {
        stepBackButton = UIButton()
        stepBackButton.setImage(UIImage(systemName: "arrowshape.turn.up.left.fill"), for: .normal)
        stepBackButton.setPreferredSymbolConfiguration(.init(pointSize: 35), forImageIn: .normal)
        stepBackButton.tintColor = .white
        stepBackButton.translatesAutoresizingMaskIntoConstraints = false
        stepBackButton.addTarget(self, action: #selector(stepBack), for: .touchUpInside)
        view.addSubview(stepBackButton)
        NSLayoutConstraint.activate([
            stepBackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stepBackButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ])
        
        reloadButton = UIButton()
        reloadButton.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        reloadButton.setPreferredSymbolConfiguration(.init(pointSize: 35), forImageIn: .normal)
        reloadButton.tintColor = .white
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        view.addSubview(reloadButton)
        NSLayoutConstraint.activate([
            reloadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            reloadButton.leadingAnchor.constraint(equalTo: stepBackButton.trailingAnchor, constant: 10)
        ])
		
		if AppState.shared.adsAreOn() {
			reloadCountLabel = UILabel()
			reloadCountLabel.text = "2"
			reloadCountLabel.textColor = .yellow
			reloadCountLabel.font = .systemFont(ofSize: 14, weight: .medium)
			reloadCountLabel.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(reloadCountLabel)
			NSLayoutConstraint.activate([
				reloadCountLabel.centerXAnchor.constraint(equalTo: reloadButton.centerXAnchor),
				reloadCountLabel.topAnchor.constraint(equalTo: reloadButton.bottomAnchor, constant: 5)
			])
		}
		
        levelLabel = UILabel()
		levelLabel.text = "\(LocalizedString(key: .mainLevel)) \(AppState.shared.getLevel())"
        levelLabel.font = UIFont(name: "ChalkboardSE-Regular", size: 30)
        levelLabel.textColor = .white
        levelLabel.textAlignment = .center
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(levelLabel)
        
        NSLayoutConstraint.activate([
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
		
		settingsButton = UIButton()
		settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
		settingsButton.setPreferredSymbolConfiguration(.init(pointSize: 35), forImageIn: .normal)
		settingsButton.tintColor = .white
		settingsButton.translatesAutoresizingMaskIntoConstraints = false
		settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
		view.addSubview(settingsButton)
		
		NSLayoutConstraint.activate([
			settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
		])
    }
	
	func setupBannerAd() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(reload),
			name: Notification.Name("com.blocksort.didResetProgress"),
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(hideAds),
			name: Notification.Name("com.blocksort.adsDidBecomeUnavailable"),
			object: nil
		)
		bannerView = GADBannerView(adSize: GADAdSizeFullBanner)
		bannerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(bannerView)
		NSLayoutConstraint.activate([
			bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
		
		bannerView.adUnitID = AdMobUnits.releaseBannerID
		bannerView.rootViewController = self
		bannerView.delegate = self
		bannerView.alpha = 0
		bannerView.load(GADRequest())
	}
	
	func loadRewardedAds() {
		let request = GADRequest()
		GADRewardedAd.load(
			withAdUnitID: AdMobUnits.releaseRewardedID,
			request: request) { ad, error in
				if error != nil {
					return
				}
				self.rewardedAd = ad
				self.rewardedAd.fullScreenContentDelegate = self
			}
	}
    
    @objc func stepBack() {
        puzzleSceneView.pool.undoLast()
    }
    
    @objc func reload() {
		if reloadCount == 0 {
			if rewardedAd != nil {
				rewardedAd.present(
					fromRootViewController: self) {
						self.reloadCount = 2
						self.reloadCountLabel.text = "2"
					}
			}
		} else {
			levelLabel.text = "\(LocalizedString(key: .mainLevel)) \(AppState.shared.getLevel())"
			let config = BlockColumnPoolConfiguration()
			puzzleSceneView.pool = BlockColumnPool.createPool(
				colorCount: config.colorCount,
				emptyPlatformsCount: config.emptyColumnsCount,
				mode: config.mode,
				delegate: self
			)
			puzzleSceneView.resetPool()
			reloadCount -= 1
		}
		
		if reloadCount == 0 {
			reloadCountLabel.text = LocalizedString(key: .mainWatchAd)
		} else {
			reloadCountLabel.text = "\(reloadCount)"
		}
    }
	
	@objc func openSettings() {
		let vc = SettingsViewController()
		vc.modalPresentationStyle = .overCurrentContext
		present(vc, animated: true, completion: nil)
	}
	
	@objc func hideAds() {
		reloadCount = Int.max
		AppState.shared.turnOffAds()
		UIView.animate(withDuration: 0.3) {
			self.bannerView.alpha = 0
			self.reloadCountLabel.alpha = 0
		} completion: { _ in
			self.bannerView.removeFromSuperview()
			self.reloadCountLabel.removeFromSuperview()
		}
	}
}

extension BoxSortPuzzleViewController: BlockColumnPoolDelegate {
	func didSetLevel(_ level: Int) {
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [unowned self] in
			levelLabel.text = "\(LocalizedString(key: .mainLevel)) \(level)"
			let config = BlockColumnPoolConfiguration()
			puzzleSceneView.pool = BlockColumnPool.createPool(
				colorCount: config.colorCount,
				emptyPlatformsCount: config.emptyColumnsCount,
				mode: config.mode,
				delegate: self
			)
			puzzleSceneView.resetPool()
		}
	}
}

extension BoxSortPuzzleViewController: GADBannerViewDelegate {
	func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
		bannerView.alpha = 0
		UIView.animate(withDuration: 1) {
			bannerView.alpha = 1
		}
	}
}

extension BoxSortPuzzleViewController: GADFullScreenContentDelegate {
	func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
		loadRewardedAds()
	}
}
