import Vapor
import Fluent

final class Idea: Model, Content {
    
    // MARK: - Properties
    
    static let schema: String = "ideas"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Parent(key: "userId")
    var user: User
    
    @Siblings(
        through: IdeaCategoryPivot.self,
        from: \.$idea,
        to: \.$category
    )
    var categories: [Category]
    
    // MARK: - Lifecycle
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String,
        description: String,
        userId: User.IDValue
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.$user.id = userId
    }
    
}
