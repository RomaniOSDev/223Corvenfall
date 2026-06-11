import Foundation

enum AppExternalLinks {
    case privacyPolicy
    case termsOfService

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://corvenfall223.site/privacy/270"
        case .termsOfService:
            return "https://corvenfall223.site/terms/270"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
