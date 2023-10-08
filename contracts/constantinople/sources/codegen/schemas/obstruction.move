module constantinople::obstruction_schema {
    use std::ascii::{String, string};
    use sui::tx_context::TxContext;
    use sui::table::{Self, Table};
    use constantinople::entity_key;
    use constantinople::events;
    use constantinople::world::{Self, World};
  
    // Systems
	friend constantinople::rpg_system;

	/// Entity does not exist
	const EEntityDoesNotExist: u64 = 0;

	const NAME: vector<u8> = b"obstruction";

	public fun id(): address {
		entity_key::from_bytes(NAME)
	}

	// value
	struct ObstructionData has copy , drop, store {
		value: bool
	}

	public fun new(value: bool): ObstructionData {
		ObstructionData {
			value
		}
	}

	struct SchemaMetadata has store {
		name: String,
		data: Table<address, ObstructionData>
	}

	public fun register(_obelisk_world: &mut World, ctx: &mut TxContext) {
		world::add_schema<SchemaMetadata>(_obelisk_world, NAME, SchemaMetadata {
			name: string(NAME),
			data: table::new<address, ObstructionData>(ctx)
		});
	}

	public(friend) fun set(_obelisk_world: &mut World, _obelisk_entity_key: address, value: bool) {
		let _obelisk_schema = world::get_mut_schema<SchemaMetadata>(_obelisk_world, id());
		let _obelisk_data = new(value);
		if(table::contains<address, ObstructionData>(&_obelisk_schema.data, _obelisk_entity_key)) {
			*table::borrow_mut<address, ObstructionData>(&mut _obelisk_schema.data, _obelisk_entity_key) = _obelisk_data;
		} else {
			table::add(&mut _obelisk_schema.data, _obelisk_entity_key, _obelisk_data);
		};
		events::emit_set(string(NAME), _obelisk_entity_key, _obelisk_data)
	}


	public fun get(_obelisk_world: &World ,_obelisk_entity_key: address): bool {
  		let _obelisk_schema = world::get_schema<SchemaMetadata>(_obelisk_world, id());
  		assert!(table::contains<address, ObstructionData>(&_obelisk_schema.data, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow<address, ObstructionData>(&_obelisk_schema.data, _obelisk_entity_key);
		(
			_obelisk_data.value
		)
	}


	public(friend) fun remove(_obelisk_world: &mut World, _obelisk_entity_key: address) {
		let _obelisk_schema = world::get_mut_schema<SchemaMetadata>(_obelisk_world, id());
		assert!(table::contains<address, ObstructionData>(&_obelisk_schema.data, _obelisk_entity_key), EEntityDoesNotExist);
		table::remove(&mut _obelisk_schema.data, _obelisk_entity_key);
		events::emit_remove(string(NAME), _obelisk_entity_key)
	}

	public fun contains(_obelisk_world: &World, _obelisk_entity_key: address): bool {
		let _obelisk_schema = world::get_schema<SchemaMetadata>(_obelisk_world, id());
		table::contains<address, ObstructionData>(&_obelisk_schema.data, _obelisk_entity_key)
	}

}