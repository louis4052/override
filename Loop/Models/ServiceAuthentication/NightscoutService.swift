//
//  NightscoutService.swift
//  Loop
//
//  Created by Nate Racklyeft on 7/3/16.
//  Copyright © 2016 Nathan Racklyeft. All rights reserved.
//

import Foundation
import NightscoutUploadKit
import LoopKit
import LoopKitUI


// Encapsulates a Nightscout site and its authentication
class NightscoutService: ServiceAuthenticationUI {

    private var loggerManager: LoggerManager

    private var logger: Logger

    var credentialValues: [String?]

    var credentialFormFields: [ServiceCredential]

    let title: String = NSLocalizedString("Nightscout", comment: "The title of the Nightscout service")

    init(siteURL: URL?, APISecret: String?, loggerManager: LoggerManager) {

        self.loggerManager = loggerManager

        logger = loggerManager.logger(forCategory: "NightscoutService")

        credentialValues = [
            siteURL?.absoluteString,
            APISecret,
        ]

        credentialFormFields = [
            ServiceCredential(
                title: NSLocalizedString("Site URL", comment: "The title of the nightscout site URL credential"),
                placeholder: NSLocalizedString("https://mysite.azurewebsites.net", comment: "The placeholder text for the nightscout site URL credential"),
                isSecret: false,
                keyboardType: .URL
            ),
            ServiceCredential(
                title: NSLocalizedString("API Secret", comment: "The title of the nightscout API secret credential"),
                placeholder: nil,
                isSecret: false,
                keyboardType: .asciiCapable
            )
        ]

        verify { _, _ in }
    }

    // The uploader instance, if credentials are present
    private(set) var uploader: NightscoutUploader? {
        didSet {
            uploader?.errorHandler = { [weak self] (error: Error, context: String) -> Void in
                self?.logger.error("Error \(error), while \(context)")
            }
        }
    }

    var siteURL: URL? {
        if let URLString = credentialValues[0], !URLString.isEmpty {
            return URL(string: URLString)
        }

        return nil
    }

    var APISecret: String? {
        return credentialValues[1]
    }

    var isAuthorized: Bool = true

    func verify(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        guard let siteURL = siteURL, let APISecret = APISecret else {
            isAuthorized = false
            completion(false, nil)
            return
        }

        let logger = loggerManager.logger(forCategory: "NightscoutUploader")
        let uploader = NightscoutUploader(siteURL: siteURL, APISecret: APISecret, logger: logger)
        uploader.checkAuth { (error) in
            completion(true, error)
        }
        self.uploader = uploader
    }

    func reset() {
        isAuthorized = false
        uploader = nil
    }
}
