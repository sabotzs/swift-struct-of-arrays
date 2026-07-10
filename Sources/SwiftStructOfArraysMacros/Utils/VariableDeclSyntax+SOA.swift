import SwiftSyntax
import SwiftSyntaxBuilder

extension VariableDeclSyntax {
    func toFlatBindings() -> [VariableDeclSyntax] {
        let specifier: Keyword = self.bindingSpecifier.tokenKind == .keyword(.let) ? .let : .var
        var typelessIds: [IdentifierPatternSyntax] = []

        return self.bindings.flatMap { binding -> [VariableDeclSyntax] in
            guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                return []
            }

            guard var typeAnnotation = binding.typeAnnotation else {
                typelessIds.append(identifier)
                return []
            }

            typeAnnotation.trailingTrivia = .backslashes(0)
            typelessIds.append(identifier)
            defer { typelessIds.removeAll() }

            return typelessIds.map {
                var name = PatternSyntax($0)
                name.leadingTrivia = .space
                return VariableDeclSyntax(
                    modifiers: self.modifiers,
                    specifier,
                    name: name,
                    type: typeAnnotation
                )
            }
        }
    }

    func toFullType(baseTypeId: String, nestedTypeIds: [String]) -> VariableDeclSyntax {
        guard bindings.count == 1 else {
            fatalError("Expected VariableDeclSyntax with single variable.")
        }

        guard let identifier = self.bindings.first?.pattern.as(IdentifierPatternSyntax.self) else {
            fatalError("Variable declaration does not have an identifier")
        }

        guard let type = bindings.first?.typeAnnotation?.type else {
            fatalError("Variable declaration does not have a type annotation")
        }

        guard nestedTypeIds.contains("\(type)") else {
            return self
        }

        let fullType = MemberTypeSyntax(
            baseType: IdentifierTypeSyntax(name: .identifier(baseTypeId)),
            name: .identifier("\(type)"))

        return VariableDeclSyntax(
            modifiers: modifiers,
            .var,
            name: PatternSyntax(identifier),
            type: TypeAnnotationSyntax(type: fullType)
        )
    }

    func toArrayType() -> VariableDeclSyntax {
        guard bindings.count == 1 else {
            fatalError("Expected VariableDeclSyntax with single variable.")
        }

        guard let identifier = self.bindings.first?.pattern.as(IdentifierPatternSyntax.self) else {
            fatalError("Variable declaration does not have an identifier")
        }

        guard let type = bindings.first?.typeAnnotation?.type else {
            fatalError("Variable declaration does not have a type annotation")
        }

        return VariableDeclSyntax(
            modifiers: modifiers,
            .var,
            name: PatternSyntax(identifier),
            type: TypeAnnotationSyntax(type: ArrayTypeSyntax(element: type))
        )
    }

    var isStatic: Bool {
        modifiers.first { $0.name.tokenKind == .keyword(.static) } != nil
    }

    var isAccessor: Bool {
        guard bindings.count == 1 else {
            fatalError("Expected VariableDeclSyntax with single variable.")
        }

        return bindings.first!.accessorBlock != nil
    }
}
