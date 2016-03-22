package myriadLands.components
{
	import myriadLands.actions.GateCombatAction;
	import myriadLands.combat.CombatManager;
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityInternal;
	import myriadLands.entities.EntityState;
	import myriadLands.entities.Squad;
	import myriadLands.events.CombatEvent;
	import myriadLands.events.EntityEvent;
	
	use namespace EntityInternal;
	
	public class CombatComponent {
		
		protected var _entity:Entity;
		protected var _cbtMgr:CombatManager;
		
		public function CombatComponent(entity:Entity, cbtMgr:CombatManager) {
			_entity = entity;
			if (_entity is Squad)
				_entity.parentEntity = null;
			_entity.state = EntityState.IN_COMBAT;
			_cbtMgr = cbtMgr;
			entity.setActions([GateCombatAction.ID]);
			_cbtMgr.addEventListener(CombatEvent.ON_ROUND_ENDED, onRoundEnded, false, 0, true);
			_entity.addEventListener(EntityEvent.ENTITY_DIED, onEntityDeath, false, 0, true);
		}
		
		public function destroy():void {
			//Retutn to original state, or vault if is dead
			if (_entity.lif <= 0) {
				if (_entity is Squad) {
					(_entity as Squad).detachUnits();
					_entity.parentEntity = null;
				}
				//_entity.state =  EntityState.IN_VAULT;
				_entity.faction.addToVault(_entity);
			} else
				_entity.state =  EntityState.IN_WORLD_MAP;
			//Destroy
			_cbtMgr.removeEventListener(CombatEvent.ON_ROUND_ENDED, onRoundEnded);
			_entity.removeEventListener(EntityEvent.ENTITY_DIED, onEntityDeath);
			_entity = null;
			_cbtMgr = null;
		}
		
		//EVENTS
		protected function onRoundEnded(e:CombatEvent):void {
			//Means tha is there not place on terrain, or dead
			if (_entity.parentEntity == null) return;
			_entity.setAttibute("act", _entity.act + _entity.actrg);
			(_entity.parentEntity as CombatGround).combatMapTile.addAnimatedText("+ " + String(_entity.actrg), "IncreaseActInfo");
		}
		
		protected function onEntityDeath(e:EntityEvent):void {
			//modify entity
			//var combatGround:CombatGround = e.entity.parentEntity as CombatGround;
			(e.entity.parentEntity as CombatGround).entityOn = null;
			//inform combat manager
			_cbtMgr.entityDied(e.entity);
		}
	}
}