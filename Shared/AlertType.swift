//
//  AlertType.swift
//  ContactCleaner
//
//  Created by Luca Archidiacono on 29.09.22.
//

import Foundation

enum AlertType {
	case info(Alert)
	case warning(Alert)
	case error(ContactError)

	enum ContactError: Error {
		case fetchingFailed(Alert)
		case accessRestricted(Alert)
		case undefined
	}
}
