import Vapor
import Fluent

final class Category: Model, Content {
    
    // MARK: - Properties
    
    static let schema: String = "categories"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Siblings(
        through: IdeaCategoryPivot.self,
        from: \.$category,
        to: \.$idea
    )
    var ideas: [Idea]
    
    // MARK: - Lifecycle
    
    init() { }
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }

}
