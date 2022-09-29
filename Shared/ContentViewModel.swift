//
//  ContentViewModel.swift
//  ContactCleaner
//
//  Created by Luca Archidiacono on 28.09.22.
//

import Contacts


final class ContentViewModel: ObservableObject {
	enum State {
		case idle
		case loading
		case failed(AlertType)
		case loaded([Contact])
	}

	@Published private(set) var state = State.idle

	private let contactStore: CNContactStore

	private(set) var isAccessGranted: Bool = {
		switch CNContactStore.authorizationStatus(for: .contacts) {
		case .authorized:
			return true
		default:
			return false
		}
	}()

	init() {
		self.contactStore = CNContactStore()
	}

	func requestAccess() {
		requestContactAccess { [weak self] isGranted, error in
			if !isGranted {
				guard let error = error else {
					self?.state = .failed(.error(.undefined))
					return
				}
				self?.state = .failed(.error(.accessRestricted(
					Alert(
						title: error.localizedDescription,
						message: "To use this app's functionality, please give this app access to contacts.",
						buttonTitle: "Ok")
				)))
			} else {
				self?.fetchContacts()
			}
		}
	}
	
	private func requestContactAccess(completion: @escaping ((Bool, Error?) -> Void)) {
		contactStore.requestAccess(for: .contacts) { isGranted, error in
			DispatchQueue.main.async {
				completion(isGranted, error)
			}
		}
	}

	func fetchContacts () {
		state = .loading
		
		let keysToFetch = [
			CNContactGivenNameKey, CNContactMiddleNameKey,
			CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey
		] as [CNKeyDescriptor]
		
		let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
		
		fetchRequest.mutableObjects = false
		fetchRequest.unifyResults = true
		fetchRequest.sortOrder = .userDefault
		
		fetchContacts(fetchRequest: fetchRequest) { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let contacts):
				let duplicates = self.findDuplicates(in: contacts)
				if duplicates.isEmpty {
					self.state = .failed(.info(
						Alert(title: "Yay! 🥳", message: "You dont have any duplicates in your Contacts.")
					))
				} else {
					self.state = .loaded(duplicates)
				}
			case .failure(let error):
				self.state = .failed(.error(.fetchingFailed(
					Alert(
						title: "Loading Contacts failed",
						message: error.localizedDescription,
						buttonTitle: "Retry"
					)
				)))
			}
		}
	}
	
	private func fetchContacts(
		fetchRequest: CNContactFetchRequest,
		completion: @escaping ((Result<[CNContact], Error>) -> Void))
	{
		DispatchQueue.global(qos: .background).async {
			do {
				var contacts = [CNContact]()
				try CNContactStore().enumerateContacts(with: fetchRequest) { contact, stop in
					contacts.append(contact)
				}
				DispatchQueue.main.async {
					completion(.success(contacts))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
	
	private func findDuplicates(in contacts: [CNContact]) -> [Contact] {
		var contact_set = Set<String>()
		return contacts.compactMap { contact in
			let fullName = self.buildFullName(
				firstName: contact.givenName,
				middleName: contact.middleName,
				lastName: contact.familyName)
			
			if contact_set.contains(fullName) {
				return Contact(
					fullName: fullName,
					phoneNumbers: contact.phoneNumbers.compactMap { $0.value.stringValue },
					emails: contact.emailAddresses.compactMap { String($0.value) })
			} else {
				contact_set.insert(fullName)
				return nil
			}
		}
	}

	private func buildFullName(firstName: String, middleName: String, lastName: String) -> String {
		var fullName = firstName
		if !middleName.isEmpty {
			fullName.append(" ")
			fullName.append(middleName)
		}
		if !lastName.isEmpty {
			fullName.append(" ")
			fullName.append(lastName)
		}
		return fullName
	}
}
