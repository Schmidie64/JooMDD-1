package de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.impl

import de.thm.icampus.joomdd.ejsl.eJSL.impl.ReferenceImpl
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedReference
import de.thm.icampus.joomdd.ejsl.eJSL.Reference
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedAttribute
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import de.thm.icampus.joomdd.ejsl.eJSL.Entity
import javax.naming.ldap.ExtendedRequest

class ExtendedReferenceImpl extends ReferenceImpl implements ExtendedReference {
	
	EList <ExtendedAttribute> extendedAttributes
	EList <ExtendedAttribute> referencedExtendedAttributes
	Entity toEntity
	Entity fromEntity
	Reference oldRef
	
	new(Reference e, Entity from){
		newInstance(e, from)
	}
	
	new(Reference e, Entity from, Reference oldRef){
        this.oldRef = oldRef
        newInstance(e, from)
    }
    
    def newInstance(Reference reference, Entity from) {
        setParentProperties(reference)
        
        toEntity = reference.entity
        
        if(from === null){
            fromEntity = reference.attribute.get(0).eContainer as Entity
        }else{
            fromEntity = from
        }
        
        initLists()
    }

    override setParentProperties(Reference reference) {
        this.attribute = reference.attribute
        this.attributerefereced = reference.attributerefereced
        this.entity = reference.entity
        this.preserve = reference.preserve
        this.upper = reference.upper
        this.lower = reference.lower
    }
	
	def initLists() {
		extendedAttributes = new BasicEList<ExtendedAttribute>()
		referencedExtendedAttributes = new BasicEList<ExtendedAttribute>()
		
		extendedAttributes.addAll( attribute.map[ a |
		    if (a instanceof ExtendedAttributeImpl) {
		        a
		    }
		    else {
                new ExtendedAttributeImpl(a)
		    }
		])
		
		referencedExtendedAttributes.addAll(attributerefereced.map[ refAttr |
		    if (refAttr instanceof ExtendedAttributeImpl) {
		        refAttr
		    }
		    else {
                new ExtendedAttributeImpl(refAttr)
		    }
		])
	}
	
	override getExtendedAttributes() {
		return this.extendedAttributes
	}
	
	override getReferencedExtendedAttributes() {
		return this.referencedExtendedAttributes
	}
	
	override getDestinationEntity() {
		return this.toEntity
	}
	override getSourceEntity() {
		return this.fromEntity
	}	
}