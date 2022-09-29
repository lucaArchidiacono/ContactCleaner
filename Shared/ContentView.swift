//
//  ContentView.swift
//  Shared
//
//  Created by Luca Archidiacono on 28.09.22.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject private var viewModel = ContentViewModel()

	@State private var multiSelection = Set<UUID>()

    var body: some View {
		switch viewModel.state {
		case .idle:
			Color.clear.onAppear {
				if !viewModel.isAccessGranted {
					viewModel.requestAccess()
				} else {
					viewModel.fetchContacts()
				}
			}
		case .loading:
			ProgressView()
		case .loaded(let contacts):
			NavigationView {
				List(contacts, selection: $multiSelection) { contact in
					NavigationLink(destination: ContactView(contact: contact)) {
						Text("\(contact.fullName)")
					}
				}
				.navigationTitle("Contacts")
				.toolbar { EditButton() }
			}
		case .failed(let alertType):
			switch alertType {
			case .info(let alert):
				ErrorView(title: alert.title, message: alert.message)
			case .warning(let alert):
				ErrorView(title: alert.title, message: alert.message)
			case .error(let errorType):
				showError(error: errorType)
			}
		}
	}

	private func showError(error: AlertType.ContactError) -> ErrorView {
		switch error {
		case .fetchingFailed(let alert):
			return ErrorView(
				title: alert.title,
				message: alert.message,
				buttonTitle: alert.buttonTitle) {
					viewModel.fetchContacts()
				}
		case .accessRestricted(let alert):
			return ErrorView(
				title: alert.title,
				message: alert.message,
				buttonTitle: alert.buttonTitle) {
					UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
				}
		case .undefined:
			return ErrorView(
				title: "Something went wrong",
				message: "Previous action lead to an error.")
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
