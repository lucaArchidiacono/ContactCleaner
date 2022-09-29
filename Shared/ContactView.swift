//
//  ContactView.swift
//  ContactCleaner
//
//  Created by Luca Archidiacono on 29.09.22.
//

import SwiftUI

struct ContactView: View {
	let contact: Contact
	
    var body: some View {
		Text(contact.fullName)
    }
}

struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView(contact: Contact(
			fullName: "Luca Archidiacono",
			phoneNumbers: ["0786728990"],
			emails: ["john.doe@mail.com"]))
    }
}
