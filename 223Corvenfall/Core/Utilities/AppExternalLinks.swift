import Foundation

enum AppExternalLinks {
    case privacyPolicy
    case termsOfService

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://canyon208workshop.site/privacy/242"
        case .termsOfService:
            return "https://canyon208workshop.site/terms/242"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
