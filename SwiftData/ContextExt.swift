import Foundation
import SwiftData
import OSLog

extension ModelContext {
    /// 所有指定的model
    func all<T: PersistentModel>() throws -> [T] {
        try self.fetch(FetchDescriptor<T>())
    }
    
    /// 分页的方式查询model
    func paginate<T: PersistentModel>(page: Int, descriptor: FetchDescriptor<T>? = nil, pageSize: Int = 10) throws -> [T] {
        let offset = (page-1) * pageSize
        var fetchDescriptor: FetchDescriptor<T>
        
        if let descriptor = descriptor {
            fetchDescriptor = descriptor
        } else {
            fetchDescriptor = FetchDescriptor<T>()
        }
        
        fetchDescriptor.fetchLimit = pageSize
        fetchDescriptor.fetchOffset = offset
        
        return try fetch(fetchDescriptor)
    }

    /// 获取指定条件的数量
    func getCount<T: PersistentModel>(for predicate: Predicate<T>) throws -> Int {
        try fetchCount(FetchDescriptor<T>(predicate: predicate))
    }

    /// 按照指定条件查询多个model
    func get<T: PersistentModel>(for predicate: Predicate<T>) throws -> [T] {
        try fetch(FetchDescriptor<T>(predicate: predicate))
    }

    /// 某个model的总条数
    func count<T>(for model: T.Type) throws -> Int where T: PersistentModel {
        try fetchCount(FetchDescriptor<T>(predicate: .true))
    }
    
    func insertAndSave(_ model: any PersistentModel) throws {
        insert(model)
        try save()
    }
    
    func destroy<T>(for model: T.Type) throws where T: PersistentModel {
        try delete(model: T.self)
    }
}
