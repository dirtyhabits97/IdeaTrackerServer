import Vapor
import Fluent

final class UserToken: Model, Content {
    
    // MARK: - Properties
    
    static let schema: String = "user_tokens"
    
    @ID
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Parent(key: "userId")
    var user: User
    
    // MARK: - Lifecycle
    
    init() { }
    
    init(
        id: UUID? = nil,
        value: String,
        userId: User.IDValue
    ) {
        self.id = id
        self.value = value
        self.$user.id = userId
    }
    
}

extension UserToken: ModelTokenAuthenticatable {
    
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user
    
    var isValid: Bool { true } // TODO: make this expire
    
}
