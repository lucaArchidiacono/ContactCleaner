//
//  Alert.swift
//  ContactCleaner
//
//  Created by Luca Archidiacono on 29.09.22.
//

import Foundation

struct Alert {
	var title: String = "Something went wrong"
	var message: String = "Previous action lead to an error."
	var buttonTitle: String? = nil
	var buttonAction: (() -> Void)? = nil
}
