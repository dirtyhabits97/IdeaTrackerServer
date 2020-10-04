import Vapor
import Fluent

// MARK: - Basic

extension Admin: ModelAuthenticatable {
    
    static let usernameKey = \Admin.$username
    static let passwordHashKey = \Admin.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
    
}

// MARK: - Bearer

extension Admin {
    
    func generateToken() throws -> AdminToken {
        try AdminToken(
            value: [UInt8].random(count: 16).base64,
            adminId: self.requireID()
        )
    }
    
}
