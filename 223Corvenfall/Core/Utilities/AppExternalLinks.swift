import Foundation

enum AppExternalLinks {
    case privacyPolicy
    case termsOfService

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://www.termsfeed.com/live/4ad2bd36-2f13-4a0c-852a-ee3c6ca65169"
        case .termsOfService:
            return "https://www.termsfeed.com/live/304977fd-e0ce-4518-bb24-326e8ced3fc7"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
