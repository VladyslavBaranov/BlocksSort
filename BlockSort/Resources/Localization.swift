//
//  Localization.swift
//  BlockSort
//
//  Created by VladyslavMac on 16.04.2022.
//

import Foundation

enum LocalizationKey: String {
	case mainLevel = "main_level"
	case mainWatchAd = "main_watch_ad"

	case settingsOn = "settings_on";
	case settingsOff = "settings_off";
	case settingsRestore = "settings_restore"
	case settingsAds = "settings_ads"
	case settingsSound = "settings_sound"
	case settingsShare = "settings_share"
	case settingsReset = "settings_reset"
	case settingsWarning = "settings_warning"
	case settingsPricing = "settings_pricing"
	case settingsConfirm = "settings_confirm"
}

func LocalizedString(key: LocalizationKey) -> String {
	NSLocalizedString(key.rawValue, comment: "")
}
