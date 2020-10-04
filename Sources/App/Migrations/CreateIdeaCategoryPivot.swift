import Fluent

struct CreateIdeaCategoryPivot: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(IdeaCategoryPivot.schema)
            .id()
            .field("ideaId", .uuid, .required, .references(Idea.schema, "id", onDelete: .cascade))
            .field("categoryId", .uuid, .required, .references(Category.schema, "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(IdeaCategoryPivot.schema).delete()
    }
    
}
