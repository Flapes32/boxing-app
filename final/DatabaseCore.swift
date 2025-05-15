//
//  DatabaseCore.swift
//  final
//
//  Created on 15.05.25.
//

import Foundation
import RealmSwift


class Database<Entity> where Entity: Object {
	
	// MARK: - Properties
	
	private let configuration: Realm.Configuration
	
	// MARK: - Lifecycle
	
	init() {
		self.configuration = Realm.Configuration.defaultConfiguration
	}
	
	// MARK: - Methods
	
	func write(block: () -> Void) {
		
		let realm = try! Realm(configuration: self.configuration)
		
		//TODO: - add autoreleasepool
		realm.refresh()
		
		if realm.isInWriteTransaction {
			block()
		} else {
			
			try! realm.write {
				block()
			}
		}
	}
	
	func save(_ entity: Entity, update: Bool = true) {
		let realm = try! Realm(configuration: self.configuration)
		
		realm.refresh()
		
		if realm.isInWriteTransaction {
			realm.add(entity, update: update ? .all : .error)
		} else {
			try! realm.write {
				realm.add(entity, update: update ? .all : .error)
			}
		}
	}
	
	func saveEntities(_ entitites: [Entity], update: Bool = true) {
		let realm = try! Realm(configuration: self.configuration)
		
		realm.refresh()
		
		try! realm.write {
			realm.add(entitites, update: update ? .all : .error)
		}
	}
	
	func deleteEntities(_ entities: Results<Entity>) {
		autoreleasepool {
			let realm = try! Realm(configuration: self.configuration)
			try! realm.write {
				realm.delete(entities)
			}
		}
	}
	
	func getEntity(id: String) -> Entity {
		let realm = try! Realm(configuration: self.configuration)
		guard let entity = realm.object(ofType: Entity.self, forPrimaryKey: id) else { return Entity() }
		return entity
	}
	
	func getEntities(filter: NSPredicate) -> Results<Entity> {
		let realm = try! Realm(configuration: self.configuration)
		return realm.objects(Entity.self).filter(filter)
	}
	
	func updateEntity(_ entity: Entity, block: (Entity) -> Void) {
		autoreleasepool {
			let realm = try! Realm(configuration: self.configuration)
			realm.refresh()
			
			guard !entity.isInvalidated else { return }
			
			if realm.isInWriteTransaction {
				block(entity)
			} else {
				try! realm.write {
					block(entity)
				}
			}
		}
	}
	
	func updateEnties(_ entites: [Entity], block: (Entity) -> ()) {
		autoreleasepool {
			let realm = try! Realm(configuration: self.configuration)
			
			realm.refresh()
			
			if realm.isInWriteTransaction {
				entites.forEach({ block($0) })
			} else {
				try! realm.write {
					entites.forEach({ block($0) })
				}
			}
		}
	}
	
	func update(_ entity: Entity, with dictionary: [String: Any?]) {
		autoreleasepool {
			do {
				let realm = try! Realm(configuration: self.configuration)
				try realm.write {
					guard !entity.isInvalidated else { return }
					for (key, value) in dictionary {
						entity.setValue(value, forKey: key)
					}
				}
			} catch {
				print(error)
			}
		}
	}
	
	
	func delete(_ entity: Entity) {
		let realm = try! Realm(configuration: self.configuration)
		try! realm.write {
			guard !entity.isInvalidated else { return }
			realm.delete(entity)
		}
	}
	
	func checkIfOwnerExists() -> Bool {
		let realm = try! Realm(configuration: self.configuration)
		return realm.objects(Entity.self).count > 0 ? true : false
	}
	
	// MARK: - Getting data
	
	func getAllEntities() -> Results<Entity> {
		let realm = try! Realm(configuration: self.configuration)
		return realm.objects(Entity.self)
	}
	
	func getRealm() -> Realm {
		return try! Realm(configuration: self.configuration)
	}
	
	static func logout() {
		let realm = Database().getRealm()
		
		try! realm.write {
			realm.deleteAll()
		}
	}
}
