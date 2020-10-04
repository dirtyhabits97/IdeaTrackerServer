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
