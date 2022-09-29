//
//  ErrorView.swift
//  ContactCleaner
//
//  Created by Luca Archidiacono on 29.09.22.
//

import SwiftUI

struct ErrorView: View {
	let title: String
	let message: String
	var buttonTitle: String? = nil
	var buttonAction: (() -> Void)? = nil

	var body: some View {
		VStack {
			Text(title)
				.font(.title)
			Text(message)
				.font(.callout)
				.multilineTextAlignment(.center)
				.padding(.bottom, 40).padding()
			if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
				Button(action: buttonAction, label: {
					Text(buttonTitle).bold()
				})
			}
		}
	}
}

#if DEBUG
//struct ErrorView_Previews: PreviewProvider {
//	static var previews: some View {
//		ErrorView(error: .undefined, buttonAction: { })
//	}
//}
#endif
