import Vapor
import Fluent

final class User: Model, Content {
    
    // MARK: - Properties
    
    static let schema: String = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    @Children(for: \.$user)
    var ideas: [Idea]
    
    // MARK: - Lifecycle
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String,
        username: String,
        password: String
    ) {
        self.id = id
        self.name = name
        self.password = password
    }
    
}

// MARK: - Validations

extension User: Validatable {
    
    static func validations(_ validations: inout Validations) {
        validations.add(
            "name", as: String.self,
            is: .ascii
        )
        validations.add(
            "username", as: String.self,
            is: .alphanumeric && .count(3...)
        )
        validations.add(
            "password", as: String.self,
            is: .count(8...)
        )
    }
    
}
