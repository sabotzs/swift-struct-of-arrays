import SwiftDiagnostics

enum SOAError: Error, DiagnosticMessage {
    case notStructOrClass

    var message: String {
        switch self {
        case .notStructOrClass:
            "SOA macros can be only applied to structs and classes."
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "com.swift-struct-of-arrays", id: message)
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .notStructOrClass:
            .error
        }
    }
}
