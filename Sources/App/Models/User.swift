import Vapor
import Fluent

final class User: Model, Content {
    
    // MARK: - Properties
    
    static let schema: String = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$user)
    var ideas: [Idea]
    
    // MARK: - Lifecycle
    
    init() { }
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
}
