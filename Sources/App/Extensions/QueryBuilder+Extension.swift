import Fluent

extension QueryBuilder {
    // MARK: Filter
    
    @discardableResult
    public func filter<Field>(
        _ field: KeyPath<Model, Field>,
        _ method: DatabaseQuery.Filter.Method,
        _ value: DatabaseQuery.Value
    ) -> Self
        where Field: FieldProtocol, Field.Model == Model
    {
        self.filter(
            .path(Model.path(for: field), schema: Model.schema),
            method,
            value
        )
    }
}
