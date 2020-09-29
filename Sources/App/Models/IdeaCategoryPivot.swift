import Vapor
import Fluent

final class IdeaCategoryPivot: Model {
    
    // MARK: - Properties
    
    static let schema: String = "idea-category-pivot"
    
    @ID
    var id: UUID?
    
    @Parent(key: "ideaId")
    var idea: Idea
    
    @Parent(key: "categoryId")
    var category: Category
    
    // MARK: - Lifecycle
    
    init() { }
    
    init(id: UUID? = nil, idea: Idea, category: Category) throws {
        self.id = id
        self.$idea.id = try idea.requireID()
        self.$category.id = try category.requireID()
    }
    
}
