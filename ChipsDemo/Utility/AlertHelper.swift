import Foundation
import UIKit

enum APIError: Error {
    case trainingFinished(title: String, message: String)
    case formNotFound(title: String, message: String)
    case formExists(title: String, message: String)
    case lackOfOJT(title: String, message: String)
    case changeRequestExists(title: String, message: String)
    case formIsDeleting(title: String, message: String)
    case trainingExists(title: String, message: String)
    case trainingFlightExist(title: String, message: String)
    case sector2FlightNotFound(title: String, message: String)
    case ineligibleforSignature(title: String, message: String)
    case noInternet
    case unknownError(title: String, message: String)
    case requestTimeout
    case draftUnreadable
    case userRoleNotFound
    case currentRoadmapNotFound
    case draftAndNetworkUnavailable
    case dataEmpty

    var title: String {
        switch self {
        case .trainingFinished(let title, _):
            return title
        case .formNotFound(let title, _):
            return title
        case .formExists(let title, _):
            return title
        case .lackOfOJT(let title, _):
            return title
        case .changeRequestExists(let title, _):
            return title
        case .formIsDeleting(let title, _):
            return title
        case .trainingExists(let title, _):
            return title
        case .trainingFlightExist(let title, _):
            return title
        case .ineligibleforSignature(let title, _):
            return title
        case .noInternet:
            return "No Internet"
        case .unknownError(let title, _):
            return title
        case .requestTimeout:
            return "The Request Timed out."
        case .draftUnreadable:
            return "#Draft Unreadable"
        case .userRoleNotFound:
            return "#userRoleNotFound"
        case .currentRoadmapNotFound:
            return "#currentRoadmapNotFound"
        case .draftAndNetworkUnavailable:
            return "Draft And Network Unavailable"
        case .dataEmpty:
            return "#Data Empty"
        case .sector2FlightNotFound(title: let title, _):
            return title
        }
    }

    var message: String {
        switch self {
        case .trainingFinished(_, let message):
            return message
        case .formNotFound(_, let message):
            return message
        case .formExists(_, let message):
            return message
        case .lackOfOJT(_, let message):
            return message
        case .changeRequestExists(_, let message):
            return message
        case .formIsDeleting(_, let message):
            return message
        case .trainingExists(_, let message):
            return message
        case .trainingFlightExist(_, let message):
            return message
        case .ineligibleforSignature(_, let message):
            return message
        case .noInternet:
            return "Your action has not completed but saved as draft.\nPlease check your internet setting and try again."
        case .unknownError(_, let message):
            return message
        case .requestTimeout:
            return "An error occurred while processing. Please try again or contact ITD."
        case .draftUnreadable:
            return "#Broken draft detected."
        case .userRoleNotFound:
            return "#userRoleNotFound"
        case .currentRoadmapNotFound:
            return "#currentRoadmapNotFound"
        case .draftAndNetworkUnavailable:
            return "Please check network connection."
        case .dataEmpty:
            return "#Data from API is empty."
        case .sector2FlightNotFound(title: _, message: let message):
            return message
        }
    }
}

struct AlertHelper {
    private init() {}

    static func showNoInternetAlert(error: APIError, settingHandler: (() -> Void)?, tryAgainHandler: (() -> Void)?) {
        let settingAction = UIAlertAction(title: "Setting", style: .default) { _ in
            settingHandler?()
        }

        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { _ in
            tryAgainHandler?()
        }

        showAlert(title: error.title, message: error.message, actions: [settingAction, tryAgainAction])
    }

    static func showFailedAlert(error: APIError, tryAgainHandler: (() -> Void)?) {
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)

        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { _ in
            tryAgainHandler?()
        }

        showAlert(title: error.title, message: error.message, actions: [closeAction, tryAgainAction])
    }

    static func showOKAlert(error: APIError) {
        let closeAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        showAlert(title: error.title, message: error.message, actions: [closeAction])
    }

    static func showOKAlert(title: String? = nil, message: String) {
        let closeAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        showAlert(title: title, message: message, actions: [closeAction])
    }

    static func showErrorDetectedAlert(message: String) {
        let title = "Error Detected"
        let closeAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        showAlert(title: title, message: message, actions: [closeAction])
    }

    static func showThisActionNeedApprovalAlert(message: String, submitHandler: (() -> Void)?) {
        let title = "This Action Need Approval"
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            submitHandler?()
        }
        submitAction.setValue(UIColor.red, forKey: "titleTextColor")

        showAlert(title: title, message: message, actions: [cancelAction, submitAction])
    }

    static func showNewFormAlert(message: String, addHandler: (() -> Void)?) {
        let title = "New Form"
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            addHandler?()
        }

        showAlert(title: title, message: message, actions: [cancelAction, addAction])
    }

    static func showNoOJTRecordsAlert(error: APIError, addHandler: (() -> Void)?) {
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            addHandler?()
        }

        showAlert(title: error.title, message: error.message, actions: [cancelAction, addAction])
    }

    static func showRejectChangingRequestAlert(message: String, rejectHandler: (() -> Void)?) {
        let title = "Reject Changing Request?"
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let rejectAction = UIAlertAction(title: "Reject", style: .default) { _ in
            rejectHandler?()
        }

        showAlert(title: title, message: message, actions: [cancelAction, rejectAction])
    }

    static func showApproveChangingRequestAlert(message: String, rejectHandler: (() -> Void)?) {
        let title = "Approve Changing Request?"
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let approveAction = UIAlertAction(title: "Approve", style: .default) { _ in
            rejectHandler?()
        }

        showAlert(title: title, message: message, actions: [cancelAction, approveAction])
    }

    static func showRejectDeletingRequestionAlert(message: String, rejectHandler: (() -> Void)?) {
        let title = "Reject Deleting Request"
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let rejectAction = UIAlertAction(title: "Reject", style: .default) { _ in
            rejectHandler?()
        }

        showAlert(title: title, message: message, actions: [cancelAction, rejectAction])
    }

    static func showApproveDeletingRequestionAlert(message: String, approveHandler: (() -> Void)?) {
        let title = "Approve Deleting Request"
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let approveAction = UIAlertAction(title: "Approve", style: .default) { _ in
            approveHandler?()
        }

        showAlert(title: title, message: message, actions: [cancelAction, approveAction])
    }

    static func showReasonWillBeCleared(message: String, uncheckHandler: (() -> Void)?) {
        let title = "Reason Will Be Cleared."
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let uncheckAction = UIAlertAction(title: "Uncheck", style: .default) { _ in
            uncheckHandler?()
        }

        showAlert(title: title, message: message, actions: [cancelAction, uncheckAction])
    }

    static func showDebugAlert(error: APIError, popHandler: (() -> Void)?) {
        let popAction = UIAlertAction(title: "OK", style: .default) { _ in
            popHandler?()
        }

        showAlert(title: error.title, message: error.message, actions: [popAction])
    }

    static func showAlert(title: String?, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alertController.view.tintColor = UIColor.colorWithHexString(hexStr: "#7E5B42")

        for action in actions {
            alertController.addAction(action)
        }

        if let topViewController = UIViewController.topViewController {
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
}


