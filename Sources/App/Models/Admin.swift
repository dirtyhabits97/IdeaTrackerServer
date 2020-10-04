import Vapor
import Fluent

final class Admin: Model, Content {
    
    // MARK: - Properties
    
    static let schema: String = "admin"
    
    @ID
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    // MARK: - Lifecycle
    
    init() { }
    
    init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
    
}
