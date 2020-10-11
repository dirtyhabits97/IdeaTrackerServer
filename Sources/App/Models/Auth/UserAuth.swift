import Vapor
import Fluent

// MARK: - Basic

extension User: ModelAuthenticatable {
    
    static let usernameKey: KeyPath<User, Field<String>> = \User.$username
    static let passwordHashKey: KeyPath<User, Field<String>> = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
    
}

// MARK: - Bearer

extension User {
    
    func generateToken() throws -> UserToken {
        try UserToken(
            value: [UInt8].random(count: 16).base64,
            userId: self.requireID()
        )
    }
    
}
