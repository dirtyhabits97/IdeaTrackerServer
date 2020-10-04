import Vapor
import Fluent

final class AdminToken: Model, Content {
    
    // MARK: - Properties
    
    static let schema: String = "admin_tokens"
    
    @ID
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Parent(key: "adminId")
    var admin: Admin
    
    // MARK: - Lifecycle
    
    init() { }
    
    init(
        id: UUID? = nil,
        value: String,
        adminId: Admin.IDValue
    ) {
        self.id = id
        self.value = value
        self.$admin.id = adminId
    }
    
}

extension AdminToken: ModelTokenAuthenticatable {
    
    static let valueKey = \AdminToken.$value
    static let userKey = \AdminToken.$admin
    
    var isValid: Bool { true } // TODO: make this expire
    
}
