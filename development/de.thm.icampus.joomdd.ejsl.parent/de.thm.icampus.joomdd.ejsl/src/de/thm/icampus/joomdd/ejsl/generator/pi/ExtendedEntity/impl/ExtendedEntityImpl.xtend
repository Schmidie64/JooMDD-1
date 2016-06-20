package de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.impl

import de.thm.icampus.joomdd.ejsl.eJSL.impl.EntityImpl
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedEntity
import de.thm.icampus.joomdd.ejsl.eJSL.Entity
import org.eclipse.emf.common.util.EList
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedAttribute
import org.eclipse.emf.common.util.BasicEList
import de.thm.icampus.joomdd.ejsl.eJSL.Attribute
import de.thm.icampus.joomdd.ejsl.generator.pi.util.PlattformIUtil
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedReference
import de.thm.icampus.joomdd.ejsl.eJSL.Feature
import de.thm.icampus.joomdd.ejsl.eJSL.Reference
import java.util.LinkedList

class ExtendedEntityImpl extends EntityImpl implements ExtendedEntity {

	Entity instance
	EList<ExtendedAttribute> extendedAttributeList
	EList<ExtendedAttribute> extendedParentAttributeList
	EList<ExtendedAttribute> allAttribute
	EList<ExtendedReference> extendedReference
	EList<ExtendedReference> allReferenceToEntity
	EList<ExtendedAttribute> allRefactoryAttribute
	EList<ExtendedReference> allRefactoryReference
	

	new(Entity entity) {
		entity.name = PlattformIUtil.slugify(entity.name)
		this.name = entity.name
		this.supertype = entity.supertype
		this.attributes = entity.attributes
		this.references = entity.references
		instance = entity
		this.preserve = entity.preserve
		initListen()

	}

	override getExtendedAttributeList() {
		return extendedAttributeList

	}

	override getExtendedParentAttributeList() {
		return extendedParentAttributeList
	}

	override getInstance() {
		return instance

	}

	override getAllattribute() {
		return allAttribute
	}

	def void initListen() {
		extendedAttributeList = new BasicEList<ExtendedAttribute>
		allAttribute = new BasicEList<ExtendedAttribute>
		allReferenceToEntity = new BasicEList<ExtendedReference>
		extendedReference = new BasicEList<ExtendedReference>
		extendedAttributeList.addAll(this.attributes.map[t|new ExtendedAttributeImpl(t)])
		extendedParentAttributeList = searchAttributeParent()

		allAttribute.addAll(extendedAttributeList)
		allAttribute.addAll(extendedParentAttributeList)
		extendedReference.addAll(references.map[t|new ExtendedReferenceImpl(t, this.instance)])
		var EList<Entity> allEntity = (instance.eContainer as Feature).entities
		for (Entity ent : allEntity) {
			if (ent.references != null) {
				var Iterable<Reference> listRef = ent.references.filter[t|t.entity.name == instance.name]
				for (Reference ref : listRef)
				    if(ref.upper.equals("1"))
					allReferenceToEntity.add(new ExtendedReferenceImpl(ref, ent))

			}
		}
	
		allRefactoryAttribute = new BasicEList<ExtendedAttribute>
		allRefactoryReference = new BasicEList<ExtendedReference>
		allRefactoryAttribute.addAll(extendedAttributeList.filter[t | !t.preserve])
		allRefactoryReference.addAll(extendedReference.filter[t | !t.preserve])
		
	    

	}
	
	

	def EList<ExtendedAttribute> searchAttributeParent() {
		var EList<ExtendedAttribute> result = new BasicEList<ExtendedAttribute>
		var Entity parent = this.supertype

		while (parent != null) {
			result.addAll(parent.attributes.map[t|new ExtendedAttributeImpl(t)])
			parent = parent.supertype

		}

		return result
	}

	override boolean haveIdAttribute() {
		for (attr : extendedAttributeList) {
			if (attr.name.toLowerCase.equalsIgnoreCase("id")) {
				attr.name = "id"
				return true
			}
		}
		return false
	}

	override putNewAttributeInEntity(Attribute e) {
		attributes.add(e)
		allAttribute.add(new ExtendedAttributeImpl(e))
	}

	override searchIdAttribute() {
		for (attr : extendedAttributeList) {
			if (attr.name.toLowerCase.equalsIgnoreCase("id")) {
				return attr
			}
		}
		return null;
	}

	override getExtendedReference() {
		return extendedReference
	}

	override getallReferenceToEntity() {
		return allReferenceToEntity
	}

	override getAttributeByName(String name) {
		for (ExtendedAttribute attr : extendedAttributeList) {
			if (attr.name.equalsIgnoreCase(name))
				return attr;
		}
		return null
	}
	
	
	
	override getRefactoryAttribute() {
		return allRefactoryAttribute
	}
	
	override getRefactoryReference() {
		return allRefactoryReference
	}
	
	override isAutomatedGenerated() {
		if(name.startsWith("mappingMDD") && references.size == 2){
			return true
		}
		return false
	}

}
