import Fluent

struct CreateAdminToken: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AdminToken.schema)
            .id()
            .field("value", .string, .required)
            .unique(on: "value")
            .field("adminId", .uuid, .required, .references(Admin.schema, "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AdminToken.schema).delete()
    }
    
}
