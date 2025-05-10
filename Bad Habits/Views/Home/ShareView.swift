//
//  ShareView.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 09/05/25.
//

import CloudKit
import SwiftUI

struct CloudSharingView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer

    func makeCoordinator() -> CloudSharingCoordinator {
        CloudSharingCoordinator(share: share)
    }
    
    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
        controller.modalPresentationStyle = .formSheet
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) { }
}

final class CloudSharingCoordinator: NSObject, UICloudSharingControllerDelegate {
    
    let share: CKShare
    
    init(share: CKShare) {
        self.share = share
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        share[CKShare.SystemFieldKey.title] as? String
    }
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        assertionFailure(error.localizedDescription)
    }
    
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) { }
}
