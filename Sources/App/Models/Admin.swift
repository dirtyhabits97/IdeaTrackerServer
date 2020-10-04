import Vapor
import Fluent

final class Admin: Model, Content {
    
    // MARK: - Properties
    
    static let schema: String = "admin"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "password")
    var password: String
    
    // MARK: - Lifecycle
    
    init() { }
    
    init(id: UUID? = nil, name: String, password: String) {
        self.id = id
        self.name = name
        self.password = password
    }
    
}
