//
//  Contacct.swift
//  ContactCleaner
//
//  Created by Luca Archidiacono on 29.09.22.
//

import Foundation

struct Contact: Identifiable {
	var id = UUID()
	var fullName: String
	let phoneNumbers: [String]
	let emails: [String]
}
