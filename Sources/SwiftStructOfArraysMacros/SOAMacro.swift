import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct SOAMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        do {
            return try expand(declaration: declaration)
        } catch {
            context.addDiagnostics(from: error, node: node)
            return []
        }
    }

    static func expand(declaration: DeclSyntaxProtocol) throws(SOAError) -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw .notStruct
        }

        let nestedTypeIdentifiers = structDecl.getNestedTypeDecls()
            .map { $0.typeIdentifier }

        let variableDecls = structDecl.getVariableDecls().lazy
            .flatMap { $0.toFlatBindings() }
            .filter { !($0.isStatic || $0.isAccessor) }
            .map { $0.toFullType(baseTypeId: structDecl.name.text, nestedTypeIds: nestedTypeIdentifiers) }

        let soaStructDecl = StructDeclSyntax(name: .identifier("\(structDecl.name.text)SOA")) {
            variableDecls.map { $0.toArrayType() }

            generateInitDecls(for: structDecl, variableDecls: variableDecls)
        }

        return [DeclSyntax(soaStructDecl)]
    }

    private static func generateInitDecls(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> [DeclSyntax] {
        return [
            generateSequenceInitDecl(for: structDecl, variableDecls: variableDecls),
            generateRepeatingInitDecl(for: structDecl, variableDecls: variableDecls),
        ]
    }

    private static func generateSequenceInitDecl(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> DeclSyntax {
        let signature = FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax {
                FunctionParameterSyntax(
                    firstName: .wildcardToken(),
                    secondName: .identifier("sequence"),
                    type: SomeOrAnyTypeSyntax(
                        someOrAnySpecifier: .keyword(.some),
                        constraint: IdentifierTypeSyntax(
                            name: .identifier("Sequence"),
                            genericArgumentClause: GenericArgumentClauseSyntax {
                                GenericArgumentSyntax(
                                    argument: .type(TypeSyntax(IdentifierTypeSyntax(name: .identifier(structDecl.name.text)))),
                                )
                            }
                        )
                    )
                )
            }
        )

        let codeBlock = CodeBlockSyntax {
            variableDecls.map { variableDecl in
                let expr = InfixOperatorExprSyntax(
                    leftOperand: variableDecl.selfDeclReferenceExpr,
                    operator: AssignmentExprSyntax(),
                    rightOperand: FunctionCallExprSyntax(
                        calledExpression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(baseName: .identifier("sequence")),
                            declName: DeclReferenceExprSyntax(baseName: .identifier("map"))
                        ),
                        leftParen: nil,
                        arguments: LabeledExprListSyntax { },
                        rightParen: nil,
                        trailingClosure: ClosureExprSyntax {
                            let expr = MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(baseName: .dollarIdentifier("$0")),
                                declName: DeclReferenceExprSyntax(baseName: .identifier(variableDecl.nameIdentifier))
                            )
                            CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
                        }
                    )
                )
                return CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
            }
        }
        return DeclSyntax(
            InitializerDeclSyntax(
                leadingTrivia: .newlines(2),
                signature: signature,
                body: codeBlock
            )
        )
    }

    private static func generateRepeatingInitDecl(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> DeclSyntax {
        let signature = FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax {
                FunctionParameterSyntax(
                    firstName: .identifier("repeating"),
                    secondName: .identifier(structDecl.name.text.lowercased()),
                    type: TypeSyntax(IdentifierTypeSyntax(name: .identifier(structDecl.name.text)))
                )
                FunctionParameterSyntax(
                    firstName: .identifier("count"),
                    type: TypeSyntax(IdentifierTypeSyntax(name: .identifier("Int")))
                )
            }
        )

        let codeBlock = CodeBlockSyntax {
            variableDecls.map { variableDecl in
                let expr = InfixOperatorExprSyntax(
                    leftOperand: variableDecl.selfDeclReferenceExpr,
                    operator: AssignmentExprSyntax(),
                    rightOperand: FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(baseName: .identifier("Array")),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax {
                            LabeledExprSyntax(
                                label: .identifier("repeating"),
                                colon: .colonToken(),
                                expression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(baseName: .identifier(structDecl.name.text.lowercased())),
                                    declName: DeclReferenceExprSyntax(baseName: .identifier(variableDecl.nameIdentifier))
                                )
                            )
                            LabeledExprSyntax(
                                label: .identifier("count"),
                                colon: .colonToken(),
                                expression: DeclReferenceExprSyntax(baseName: .identifier("count"))
                            )
                        },
                        rightParen: .rightParenToken()
                    )
                )
                return CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
            }
        }

        return DeclSyntax(
            InitializerDeclSyntax(
                leadingTrivia: .newlines(2),
                signature: signature,
                body: codeBlock
            )
        )
    }
}
