import Vapor
import Fluent

final class Category: Model, Content {
    
    // MARK: - Properties
    
    static let schema: String = "categories"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    // MARK: - Lifecycle
    
    init() { }
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }

}
