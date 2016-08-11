package de.thm.icampus.joomdd.ejsl.ressourceTransformator

import org.eclipse.emf.common.util.EList
import de.thm.icampus.joomdd.ejsl.eJSL.Entity
import de.thm.icampus.joomdd.ejsl.eJSL.EJSLModel
import de.thm.icampus.joomdd.ejsl.eJSL.CMSExtension
import de.thm.icampus.joomdd.ejsl.eJSL.Attribute
import de.thm.icampus.joomdd.ejsl.eJSL.EJSLFactory
import de.thm.icampus.joomdd.ejsl.eJSL.StandardTypes
import de.thm.icampus.joomdd.ejsl.eJSL.StandardTypeKinds
import de.thm.icampus.joomdd.ejsl.eJSL.Reference
import org.eclipse.emf.common.util.BasicEList
import de.thm.icampus.joomdd.ejsl.eJSL.Type
import de.thm.icampus.joomdd.ejsl.eJSL.DatatypeReference
import de.thm.icampus.joomdd.ejsl.eJSL.Page
import de.thm.icampus.joomdd.ejsl.eJSL.DetailsPage
import de.thm.icampus.joomdd.ejsl.eJSL.IndexPage
import de.thm.icampus.joomdd.ejsl.eJSL.Link
import de.thm.icampus.joomdd.ejsl.eJSL.ContextLink
import de.thm.icampus.joomdd.ejsl.eJSL.LinkParameter
import de.thm.icampus.joomdd.ejsl.eJSL.StaticPage
import de.thm.icampus.joomdd.ejsl.eJSL.DynamicPage
import de.thm.icampus.joomdd.ejsl.eJSL.Datatype

class JoomlaTranformator {
	
	EJSLModel instance
	CMSExtension cmsExtension
	EList<Entity> entityList
	
	
	
	new(EJSLModel model){
		this.instance = model
		
		
	}
	

	
	def void completeCMSExtension(){
		
		switch(instance.ejslPart){
			CMSExtension:{
				cmsExtension = instance.ejslPart as CMSExtension
				entityList = cmsExtension.feature.entities
				completeEntity()
				completePage(cmsExtension.feature.pages)
			}
		}
	}
	

	 private def void completeEntity(){
    	
    	for(Entity ent: entityList){
    		completeAttributeOfEntity(ent)
    	}
    	for(Entity ent: entityList){
    		completeReferenceOfEntity(ent)
    		setReferenceAttribute(ent)
    	}
    	
    }
	
	private def completeAttributeOfEntity(Entity ent) {
		if(!ent.havePrimaryAttribute()){
			
			var Attribute id = EJSLFactory.eINSTANCE.createAttribute
			id.name = "id"
			var StandardTypes typeid = EJSLFactory.eINSTANCE.createStandardTypes
			typeid.type =  StandardTypeKinds.INTEGER
			typeid.notnull = true
			typeid.autoincrement = true
			id.type = typeid
			ent.attributes.add(id)
			id.isprimary = true
			
		}
		if(!haveAttribute(ent,"asset_id" )){
		var Attribute asset_id = EJSLFactory.eINSTANCE.createAttribute
			asset_id.name = "asset_id"
			var StandardTypes type_asset_id = EJSLFactory.eINSTANCE.createStandardTypes
			type_asset_id.type =  StandardTypeKinds.INTEGER
			type_asset_id.notnull = true
			type_asset_id.^default = "0"
			asset_id.type = type_asset_id
			ent.attributes.add(asset_id)
		}
		if(!haveAttribute(ent,"state")){				
		var Attribute state = EJSLFactory.eINSTANCE.createAttribute
			state.name = "state"
			var StandardTypes type_state = EJSLFactory.eINSTANCE.createStandardTypes
			type_state.type =  StandardTypeKinds.BOOLEAN
			type_state.notnull = true
			state.type = type_state
      		ent.attributes.add(state)	
		}
		if(!haveAttribute(ent,"ordering")){		
		var Attribute ordering = EJSLFactory.eINSTANCE.createAttribute
			ordering.name = "ordering"
			var StandardTypes type_ordering = EJSLFactory.eINSTANCE.createStandardTypes
			type_ordering.type =  StandardTypeKinds.INTEGER
			type_ordering.notnull = true
			ordering.type = type_ordering
			ent.attributes.add(ordering)
		}
		if(!haveAttribute(ent,"checked_out_time")){	
		var Attribute checked_out_time = EJSLFactory.eINSTANCE.createAttribute
			checked_out_time.name = "checked_out_time"
			var StandardTypes type_checked_out_time= EJSLFactory.eINSTANCE.createStandardTypes
			type_checked_out_time.type =  StandardTypeKinds.DATETIME
			type_checked_out_time.notnull = true
			type_checked_out_time.^default = "0000-00-00 00:00:00"
			checked_out_time.type = type_checked_out_time
			ent.attributes.add(checked_out_time)
		}
		if(!haveAttribute(ent,"checked_out")){	
		var Attribute checked_out = EJSLFactory.eINSTANCE.createAttribute
			checked_out.name = "checked_out"
			var StandardTypes type_checked_out = EJSLFactory.eINSTANCE.createStandardTypes
			type_checked_out.type =  StandardTypeKinds.INTEGER
			type_checked_out.notnull = true
			checked_out.type = type_checked_out
			ent.attributes.add(checked_out)
		}	
		if(!haveAttribute(ent,"created_by")){	
		var Attribute created_by = EJSLFactory.eINSTANCE.createAttribute
			created_by.name = "created_by"
			var StandardTypes type_created_by = EJSLFactory.eINSTANCE.createStandardTypes
			type_created_by.type =  StandardTypeKinds.INTEGER
			type_created_by.notnull = true
			created_by.type = type_created_by
			ent.attributes.add(created_by)
		}
		if(!haveAttribute(ent,"published")){	
		var Attribute published = EJSLFactory.eINSTANCE.createAttribute
			published.name = "published"
			var StandardTypes type_published = EJSLFactory.eINSTANCE.createStandardTypes
			type_published.type =  StandardTypeKinds.BOOLEAN
			published.type = type_published
			ent.attributes.add(published)
		}
		if(!haveAttribute(ent,"params")){	
		var Attribute params = EJSLFactory.eINSTANCE.createAttribute
			params.name = "params"
			var StandardTypes type_params = EJSLFactory.eINSTANCE.createStandardTypes
			type_params.type =  StandardTypeKinds.TEXT
			params.type = type_params
			ent.attributes.add(params)}
		
		for(Attribute attr: ent.attributes){
			 if(attr.id){
			 	attr.withattribute = ent.searchIdAttribute
			 }
		}
	}
	
	private def Attribute searchIdAttribute(Entity entity){
		for(Attribute e: entity.attributes){
			if(e.name.equalsIgnoreCase("id") || e.name.equalsIgnoreCase("^id") || e.isIsprimary)
			return e
		}
	}
	
	private def boolean havePrimaryAttribute(Entity entity){
		for(Attribute e: entity.attributes){
			if(e.isIsprimary)
			return true
		}
		return false
	}
	private def boolean haveAttribute(Entity entity, String attrinuteName){
		for(Attribute e: entity.attributes){
			if(e.name.equals(attrinuteName))
			return true
		}
		return false
	}
	
	private def void  completeReferenceOfEntity(Entity ent) {
		
		for(Reference ref : ent.references){
			if(ref.id){
				var Attribute id = ref.entity.searchIdAttribute
				if( id != null){
				ref.attributerefereced.add(id)
				ref.id=false
				if(	ref.attributerefereced.size > 1){
					if(getAttributeReference(ent, ref.entity, id ) == null){
						ref.attribute.add(setNewGenAttribute(ent,ref, id))
					}
				}
				
				}
			}
		}
	}
	
	def void setReferenceAttribute( Entity ent){
		for(Reference ref:ent.references){
			var Entity referenceEntity = ref.entity
			var EList<Attribute> newAttribute = new BasicEList<Attribute>
			for(Attribute attr: ref.attribute){
				var Attribute uniqWith = attr.withattribute
				if(uniqWith != null && !ref.attribute.contains(uniqWith)){
					newAttribute.add(uniqWith)
				}
			}
			ref.attribute.addAll(newAttribute)
			
			
			var EList<Attribute> newReferenceArttibute = new BasicEList<Attribute>
			for(Attribute attrRef: ref.attributerefereced){
				var Attribute uniqWith = attrRef.withattribute
				if(uniqWith != null ){
					var Attribute attr = getAttributeReference(ent, referenceEntity,uniqWith)
					if(attr==null){
					setNewGenAttribute(ent, ref, uniqWith)
					newReferenceArttibute.add(uniqWith)
					}else{
						newReferenceArttibute.add(uniqWith)
					}
				}
			}
			ref.attributerefereced.addAll(newReferenceArttibute)
			
			}
		
	}
	def Attribute setNewGenAttribute(Entity ent, Reference ref, Attribute attrRef){
		var Entity referenceEntity = ref.entity
		var Attribute newAttribute = EJSLFactory.eINSTANCE.createAttribute
					newAttribute.name = referenceEntity.name.toString.toLowerCase + "_" + attrRef.name.toLowerCase
					newAttribute.type =  Util.copyType(attrRef.type)
					ent.attributes.add(newAttribute)
					ref.attribute.add(newAttribute)					
					return newAttribute
	}
	
	
	
	def Attribute getAttributeReference(Entity ent, Entity referencedEntity, Attribute referenced){
		for(Attribute a:ent.attributes ){
			if(a.name.equalsIgnoreCase(referencedEntity.name.toString.toLowerCase +  "_"+ referenced.name))
			return a;
		}
		for(Reference ref:ent.references ){
			
			if(ref.entity.name == referencedEntity.name && ref.attributerefereced.filter[t | t.name.equalsIgnoreCase(referenced.name)].size>0 ){
				var int index = ref.attributerefereced.indexOf(referenced)	
				return ref.attribute.get(index)
			}
		}
		return null
	}
def void completePage(EList<Page> pageList){
	for(Page pg: pageList.filter[t | !(t instanceof StaticPage)]){
		var Entity fromEnt = null
		switch pg{
			DynamicPage:{
				var DynamicPage fromDynPage = pg as DynamicPage
				fromEnt = fromDynPage.entities.get(0)
			for(Link lk : pg.links.filter[t | t instanceof ContextLink]){
			var ContextLink ctLink = lk as ContextLink
			if(ctLink.target instanceof DynamicPage){
				var DynamicPage toDynPage =  ctLink.target as DynamicPage
				var Entity toEnt = toDynPage.entities.get(0) 
				if(ctLink.linkparameters.size != 0)
				completeContextLink(ctLink, fromEnt, toEnt )
			}
			}
		}
			
	  }
	
	}
}
	
	def void completeContextLink(ContextLink link, Entity fromEntity, Entity toEntity) {
		
		for(LinkParameter lkParam: link.linkparameters){
			if(lkParam.id){
				if(fromEntity.name != toEntity.name){
					lkParam.attvalue = searchReferenceOfID(fromEntity, toEntity)
				}else{
					lkParam.attvalue = searchIdAttribute(fromEntity)
				}
				lkParam.id = false
			}
			
		}
	}
	
	def Attribute searchReferenceOfID(Entity fromEntity,Entity toEntity) {
		var Attribute id = searchIdAttribute(toEntity)
		for(Reference ref: fromEntity.references){
			var Attribute result = getAttributeReference(fromEntity, toEntity,id)
			if(result != null)
			return result
		}
		return null
	}
	
	
}
