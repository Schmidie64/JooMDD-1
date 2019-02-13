package de.thm.icampus.joomdd.ejsl.ressourceTransformator

import de.thm.icampus.joomdd.ejsl.eJSL.EJSLModel
import de.thm.icampus.joomdd.ejsl.eJSL.CMSExtension
import de.thm.icampus.joomdd.ejsl.eJSL.Feature
import de.thm.icampus.joomdd.ejsl.eJSL.DetailsPage
import de.thm.icampus.joomdd.ejsl.eJSL.DetailPageField
import de.thm.icampus.joomdd.ejsl.eJSL.SimpleHTMLTypes
import de.thm.icampus.joomdd.ejsl.eJSL.Attribute
import de.thm.icampus.joomdd.ejsl.eJSL.DatatypeReference
import de.thm.icampus.joomdd.ejsl.eJSL.EJSLFactory
import de.thm.icampus.joomdd.ejsl.eJSL.SimpleHTMLTypeKinds
import de.thm.icampus.joomdd.ejsl.eJSL.StandardTypes
import de.thm.icampus.joomdd.ejsl.eJSL.Page
import de.thm.icampus.joomdd.ejsl.eJSL.IndexPage
import de.thm.icampus.joomdd.ejsl.eJSL.Entity
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import de.thm.icampus.joomdd.ejsl.eJSL.Reference
import de.thm.icampus.joomdd.ejsl.eJSL.Type
import java.util.Iterator
import de.thm.icampus.joomdd.ejsl.eJSL.InternalLink
import de.thm.icampus.joomdd.ejsl.eJSL.StandardTypeKinds
import de.thm.icampus.joomdd.ejsl.eJSL.HTMLTypes
import de.thm.icampus.joomdd.ejsl.eJSL.KeyValuePair
import de.thm.icampus.joomdd.ejsl.eJSL.DynamicPage
import de.thm.icampus.joomdd.ejsl.eJSL.StaticPage
import de.thm.icampus.joomdd.ejsl.eJSL.Link
import de.thm.icampus.joomdd.ejsl.eJSL.ContextLink
import de.thm.icampus.joomdd.ejsl.eJSL.LinkParameter

/**
 * this class transforme and complete the ejsl model for the generator.
 * the big points are: 
 * -Solving of the mutilple reference between two entities 
 * -the copy from  attribute of a entity to the tablecolumn an filters of a page.
 * -Parsing of attribute type
 */
class RessourceTransformer {
	EJSLModel modelInstance
	CMSExtension cmsextension
	Feature featurs
	new (EJSLModel model){
		modelInstance = model
		
		cmsextension = model.ejslPart as CMSExtension
		featurs = cmsextension.feature
		
	}
	def dotransformation(){
		featurs.entities.forEach[t | t.name = Util.slugify(t.name)]
		featurs.pages.forEach[t | t.name = Util.slugify(t.name)]
		for(Entity ent: featurs.entities){
			completeAttributeOfEntity(ent)
		}
		for(Entity ent: featurs.entities){
    		completeReferenceOfEntity(ent)
    		setReferenceAttribute(ent)
    	}
    	
    	
		createMappingsTable(featurs.entities)
		formatEntitiesAttribute(featurs.entities)
		completeDetailsPage();
		completeIndexPage();
		
		var JoomlaTranformator jt = new JoomlaTranformator(modelInstance)
		jt.completeCMSExtension
		completePage(featurs.pages)
		
	}
	/**
	 * Create a primary attribute, when it is not exist,
	 * replace the id symbol with the primary keys,
	 * complete the reference with the new generated primary keys or the keys pair
	 * and create many attributes for the joomla specified generator
	 * @param Entity ent contains a entity
	 */
	private def completeAttributeOfEntity(Entity ent) {
		if(!ent.havePrimaryAttribute()){
			
			var Attribute id = EJSLFactory.eINSTANCE.createAttribute
			id.name = "id"
			var StandardTypes typeid = EJSLFactory.eINSTANCE.createStandardTypes
			typeid.type =  StandardTypeKinds.INTEGER
			typeid.notnull = true
			typeid.autoincrement = true
			id.type = typeid
			id.isprimary = true
			ent.attributes.add(id)
			
		}
		for(Attribute attr: ent.attributes){
			 if(attr.id){
			 	attr.withattribute = ent.searchIdAttribute
			 	attr.id = false;
			 }
		}
		
		
		}
		/**
	 * Search an return if the entity have a primary keys
	 * @param Entity entity contains a entity
	 * 
	 */
	private def Attribute searchIdAttribute(Entity entity){
		for(Attribute e: entity.attributes){
			if(e.name.equalsIgnoreCase("id") || e.name.equalsIgnoreCase("^id") || e.isIsprimary)
			return e
		}
		return null
	}
	

	/**
	 * Check if the entity contains a attribute
	 * @param Entity entity        contains a entity
	 * @param String attributeNam  contains a attribute name
	 */
	private def boolean haveAttribute(Entity entity, String attributeName){
		for(Attribute e: entity.attributes){
			if(e.name.equals(attributeName))
			return true
		}
		return false
	}
	
	/**
	 * replace the id symboile in the unique keys definition with a id object
	 * and create the attribute pair of an referenced attribute in the reference entity
	 * @param Entity ent contains a entity
	 */
	private def void  completeReferenceOfEntity(Entity ent) {
		
		for(Reference ref : ent.references){
			
			for(Attribute refatt : ref.attributerefereced){
				if(!refatt.isprimary && !refatt.isunique && refatt.withattribute === null && !refatt.id){
					var Attribute idref = this.searchIdAttribute(ref.entity);
					refatt.isunique = true;
					refatt.id = true;
					if(idref=== null){
						refatt.id= true;
						
					}else{
						refatt.withattribute = idref
					}
					
				}
			}
			if(ref.id){
				var Attribute id = ref.entity.searchIdAttribute
				if( id !== null){
				ref.attributerefereced.add(id)
				ref.id=false
				if(	ref.attributerefereced.size > 1){
					if(getAttributeReference(ent, ref.entity, id ) === null){
						ref.attribute.add(setNewGenAttribute(ent,ref, id))
					}
				}
				
				}
			}
			
			
		}
	}
	/**
	 * Complete the reference of an entity , when the attribute are unique with an other.
	 * @param Entity ent contains a Entity
	 */
	def void setReferenceAttribute( Entity ent){
		for(Reference ref:ent.references){
			var Entity referenceEntity = ref.entity
			var EList<Attribute> newAttribute = new BasicEList<Attribute>
			for(Attribute attr: ref.attribute){
				var Attribute uniqWith = attr.withattribute
				if(uniqWith !== null && !ref.attribute.contains(uniqWith)){
					newAttribute.add(uniqWith)
				}
			}
			ref.attribute.addAll(newAttribute.filter[t | !containsAttribute(t, ref.attribute)])
			
			
			var EList<Attribute> newReferenceArttibute = new BasicEList<Attribute>
			for(Attribute attrRef: ref.attributerefereced){
				var Attribute uniqWith = attrRef.withattribute
				if(uniqWith !== null ){
					var Attribute attr = getAttributeReference(ent, referenceEntity,uniqWith)
					if(attr === null){
					 var Attribute refAttrEnt = setNewGenAttribute(ent, ref, uniqWith)
					 var Attribute hereAttr = ref.attribute.get(ref.attributerefereced.indexOf(attrRef))
					 hereAttr.isunique = true;
					 hereAttr.withattribute = refAttrEnt
					 
					newReferenceArttibute.add(uniqWith)
					}else{
						newReferenceArttibute.add(uniqWith)
					}
				}
			}
			ref.attributerefereced.addAll(newReferenceArttibute.filter[t | !this.containsAttribute(t,ref.attributerefereced)])
			
			}
		
	}
	
	def Boolean containsAttribute(Attribute attribute, EList<Attribute> list) {
		
		for(Attribute attr: list){
			if(attr.name.equalsIgnoreCase(attribute.name))
			return true
		}
		return false
	}
	
	/**
	 * Create a new attribute and complete a reference.
	 * @param Entity    ent      contains a entity
	 * @param Reference ref      contains a refrence
	 * @param Attribute attrRef  contains a attribute to clone
	 */
	def Attribute setNewGenAttribute(Entity ent, Reference ref, Attribute attrRef){
		var Entity referenceEntity = ref.entity
		var Attribute newAttribute = EJSLFactory.eINSTANCE.createAttribute
					newAttribute.name = referenceEntity.name.toString.toLowerCase + "_" + attrRef.name.toLowerCase
					newAttribute.type =  Util.copyType(attrRef.type)
					ent.attributes.add(newAttribute)
					ref.attribute.add(newAttribute)
										
					return newAttribute
	}
	
	
	/**
	 * check a attribute if the a attribute to clone already exist in the referenced attribute.
	 * @param Entity    ent               contains the origin entity
	 * @param Entity    referencedEntity  contains the referenced entity
	 * @param Attribute referenced        contains to referenced attribute
	 */
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
	
	/**
	 * Complete the context Links of a dynamic page, add the id key and refrenced attribute
	 * @param EList<Page> pageList contains a list of page
	 */
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
	
	/**
	 * Complete the the contextlink, when the link have a id, it replace it with the id object of the entity
	 * @param ContextLink link        contains a Link
	 * @param Entity      fromEntity  contains the start entity
	 * @param Entity      toEntity    contain the target entity
	 */
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
	/**
	 * searchs and returns the attribute, that have a reference to the id.
	 * @param Entity fromEntity  contains the start entity
	 * @param Entity toEntity    contains the target entity
	 */
	def Attribute searchReferenceOfID(Entity fromEntity,Entity toEntity) {
		var Attribute id = searchIdAttribute(toEntity)
		for(Reference ref: fromEntity.references){
			var Attribute result = getAttributeReference(fromEntity, toEntity,id)
			if(result != null)
			return result
		}
		return null
	}
	
	/** 
	 * Check if the entity have a primary keys
	 * @param Entity entity contains a entity
	 */
	private def boolean havePrimaryAttribute(Entity entity){
		for(Attribute e: entity.attributes){
			if(e.isIsprimary)
			return true
		}
		return false
	}
	def formatEntitiesAttribute(EList<Entity> list) {
		for(Entity ent: list){
			ent.name = Util.slugify(ent.name)
			for(Attribute attr: ent.attributes){
			   attr.name = Util.slugify(attr.name)
			   var type = attr.type.getType()
			   if(attr.isIsprimary && type.equalsIgnoreCase("text")){
			   	var StandardTypes typeid = EJSLFactory.eINSTANCE.createStandardTypes
				typeid.type =  StandardTypeKinds.INTEGER
				typeid.notnull = true
				typeid.autoincrement = true
			   	 attr.type =  typeid
			   }}
		}
	}
	
	def String getType(Type type){
		switch(type){
			DatatypeReference:{
				var DatatypeReference dt = type as DatatypeReference
				return dt.type.name
				
			} 
			 StandardTypes:{
			 	var StandardTypes dt = type as StandardTypes
			 	return dt.type.getName()
			 }
		}
	}
	
	def completeIndexPage() {
			for(Page page: featurs.pages.filter[t | t instanceof IndexPage]){
			var IndexPage dp = page as IndexPage
			completeColUmnAndFilterList(dp)
		}
	}
	
	def completeDetailsPage(){
		
		for(Page page: featurs.pages.filter[t | t instanceof DetailsPage && (t as DetailsPage).tablecolumns.empty && (t as DetailsPage).editfields.empty]){
			var DetailsPage dp = page as DetailsPage
			completeTableColumnAndEditedFields(dp)
			for(DetailPageField field: dp.editfields){
				if(field.htmltype == null){
				  field.htmltype = parseAttributeType(field.attribute).htmltype
				    
				   println(field.attribute+ " Html Type  "+field.htmltype + " -> " + parseAttributeType(field.attribute).htmltype)
				}
			}
		}
	}
	
	private def completeTableColumnAndEditedFields(DetailsPage page) {

		if(page.editfields.empty && page.tablecolumns.empty){
			for(Attribute attr: page.entities.get(0).attributes){
				page.tablecolumns.add(attr)
				
				page.editfields.add(parseAttributeType(attr))
			}
		}
	}
	private def completeColUmnAndFilterList(IndexPage page) {		
		if(page.filters.empty && !page.tablecolumns.empty){
			for(Attribute attr: page.tablecolumns){
				page.filters.add(attr)
			}
		}
		if(!page.filters.empty && page.tablecolumns.empty){
			
			for(Attribute attr: page.filters){
				page.tablecolumns.add(attr)
			}
		}
		if(page.filters.empty&& page.tablecolumns.empty){
			for(Attribute attr: page.entities.get(0).attributes){
				if((page.entities.get(0).references.filter[t | !t.attribute.contains(attr) && t.upper != 1]).size ==0)
				page.tablecolumns.add(attr)
				page.filters.add(attr)
			}
		}
	}
	
	
	
   
	def void createMappingsTable(EList<Entity> entitiesList){ 
		
		var EList<Entity> newEntity = new BasicEList<Entity>()
		for(Entity ent: entitiesList){
			var EList<Reference> toDeleteReference = new BasicEList<Reference>()
			var EList<Reference>toAddReference = new BasicEList<Reference>()
			for(Reference ref: ent.references){
				 if(ref.entity.haveReferenTo(ent,ref.upper)){
				 	if(!ref.entity.existingReferenceBetweenEntity(ent,newEntity)){
				 		var String mappingEntityName =  ent.name + "" + ref.entity.name
				 	
				 		var Entity mappingEntity = EJSLFactory.eINSTANCE.createEntity
				 		mappingEntity.name = mappingEntityName
				 		var EList<Attribute> attributeFromEntity = new BasicEList<Attribute>
				 		var EList<Attribute> copy_attributeFromEntity = new BasicEList<Attribute>
				 		var EList<Attribute> to_rename_attributeFromEntity = new BasicEList<Attribute>
				 		var EList<Attribute> attributeToEntity = new BasicEList<Attribute>
				 		var EList<Attribute> copy_attributeToEntity = new BasicEList<Attribute>
				 	    var EList<Attribute> to_rename_attributeToEntity = new BasicEList<Attribute>
				 		
				 		attributeFromEntity.addAll(ref.entity.references.filter[t | t.entity.name == ent.name].get(0).attributerefereced)
				 		to_rename_attributeToEntity.addAll(ref.entity.references.filter[t | t.entity.name == ent.name].get(0).attribute)
				 		attributeToEntity.addAll(ref.attributerefereced)
				 		to_rename_attributeFromEntity.addAll(ref.attribute);
				 		copy_attributeFromEntity.addAll(copyAttribute( ent,attributeFromEntity))
				 		mappingEntity.attributes.addAll(copy_attributeFromEntity)
				 		copy_attributeToEntity.addAll(copyAttribute( ref.entity,attributeToEntity))
				 		renameOldReference(to_rename_attributeFromEntity, copy_attributeToEntity)
				 		renameOldReference(to_rename_attributeToEntity, copy_attributeFromEntity)
				 		mappingEntity.attributes.addAll(copy_attributeToEntity)
				 		ent.attributes.removeAll(ref.attribute)
				 		ref.entity.attributes.removeAll(ref.entity.references.filter[t | t.entity.name == ent.name].get(0).attribute)
				 		mappingEntity.references.addAll(solveReference(ref,mappingEntity,ent,ref.entity))
				 		newEntity.add(mappingEntity)
				 		println("generateMappingsTable " + mappingEntityName)
				 		deleteReferenceToEntity(ref.entity, ent,mappingEntity)
				 		toDeleteReference.add(ref)
				 		toAddReference.add(createNewReverseReference(mappingEntity, ent,ref))
				 		completeAttributeOfEntity(mappingEntity);
				 		var IndexPage pageList = createNewExtendedIndexPageForExtensions(mappingEntity)
				 		var DetailsPage pageDetails = createNewExtendedDetailsPageForExtensions(mappingEntity)
				 		createLinktoPage(pageList,pageDetails)
				 		featurs.pages.add(pageList)
				 		featurs.pages.add(pageDetails)
				 	}
				 }
			}
			if(!toDeleteReference.isEmpty)
			ent.references.removeAll(toDeleteReference)
			
			if(!toAddReference.isEmpty)
			ent.references.addAll(toAddReference)
			
		}
		entitiesList.addAll(newEntity)
		
	}
	
	 def void renameOldReference(EList<Attribute> torenameAttribute, EList<Attribute> newAttribute) {
		
		
		for( Page page: featurs.pages.filter[t | t instanceof  DynamicPage]){
			var DynamicPage dynPage = page as DynamicPage
			for(Attribute attr : torenameAttribute){
				if(dynPage.filters.contains(attr)){
					var Attribute newAttr = newAttribute.get(torenameAttribute.indexOf(attr))
					dynPage.filters.remove(attr)
					dynPage.filters.add(newAttr)
				}
				if(dynPage.tablecolumns.contains(attr)){
					var Attribute newAttr = newAttribute.get(torenameAttribute.indexOf(attr))
					dynPage.tablecolumns.remove(attr)
					dynPage.tablecolumns.add(newAttr)
				}
			}
		}
		
	}
	
	
	
	private def EList<Reference> solveReference(Reference reference, Entity mappingEntity,Entity fromEntity,Entity toEntity ) {
		var Reference nRef =  EJSLFactory.eINSTANCE.createReference
		nRef.attribute.addAll(mappingEntity.attributes.filter[t | isAttributeOfEntity(t,fromEntity.name)])
		nRef.entity = fromEntity
		nRef.attributerefereced.addAll(toEntity.references.filter[t | t.entity.name == fromEntity.name].get(0).attributerefereced)
		nRef.lower = "1"
		nRef.upper = "1"
		var Reference mRef =  EJSLFactory.eINSTANCE.createReference
		mRef.attribute.addAll(mappingEntity.attributes.filter[t | isAttributeOfEntity(t,toEntity.name)])
		mRef.entity = toEntity
		mRef.attributerefereced.addAll(reference.attributerefereced)
		mRef.lower = "1"
		mRef.upper = "1"
		var EList<Reference> result = new BasicEList<Reference>()
		result.add(nRef)
		result.add(mRef)
		return result
		
	}
	
	private def isAttributeOfEntity(Attribute attribute, String entityName) {
		if(attribute.name.startsWith(entityName.toLowerCase + "_"))
		return true
		
		return false
	}
	
	
	
	private def EList<Attribute> copyAttribute( Entity fromEntity, EList<Attribute> attributeOldList) {
		var EList<Attribute> result = new BasicEList<Attribute>
		for(Attribute attribute: attributeOldList){
		
		var Attribute newAttr = EJSLFactory.eINSTANCE.createAttribute
		newAttr.name = fromEntity.name.toLowerCase + "_" + attribute.name
		newAttr.type = Util.copyType(attribute.type)
		newAttr.id = attribute.id
		newAttr.isunique = attribute.isunique
		newAttr.preserve = attribute.preserve
		if(!this.containsAttribute(newAttr,result)){
		result.add(newAttr)

			if(attribute.id && attribute.withattribute === null){
				var Attribute newID = EJSLFactory.eINSTANCE.createAttribute
				newID.name = fromEntity.name.toLowerCase + "_" + "id"
				var StandardTypes typeid = EJSLFactory.eINSTANCE.createStandardTypes
				typeid.type =  StandardTypeKinds.INTEGER
				typeid.notnull = true
				newID.type = typeid
				newAttr.withattribute =  newID;
				if( !this.containsAttribute(newID,result))
				result.add(newID)
				
			}
			if(attribute.withattribute !== null){
				var Attribute newUniq = EJSLFactory.eINSTANCE.createAttribute
				newUniq.name = fromEntity.name.toLowerCase + "_" + attribute.withattribute.name
				newUniq.type = Util.copyType(attribute.withattribute.type)
				newAttr.withattribute = newUniq;
				if( !this.containsAttribute(newUniq,result))
				result.add(newUniq)
				
			}
			
		}
        }
        
		return result
	}

	
	
	private def boolean existingReferenceBetweenEntity(Entity to, Entity from,EList<Entity> newEntityList){
		var String mappingNameForward =  to.name + "" + from.name
		var String mappingNameReverse= from.name + "" +  to.name
		if(newEntityList.size ==0 )
		return false
		for(Entity ent: newEntityList){
			if(ent.name.equals(mappingNameForward) || ent.name.equals(mappingNameReverse))
			return true
		}
		return false
		
	}
	private def boolean deleteReferenceToEntity(Entity to, Entity from, Entity newEntity){
		var Reference newref = EJSLFactory.eINSTANCE.createReference
		var Reference oldRef = to.references.filter[t | t.entity.name == from.name].get(0)
		newref.attribute.addAll(from.references.filter[t | t.entity.name == to.name].get(0).attributerefereced)
		newref.attributerefereced.addAll(newEntity.attributes.filter[t | isAttributeOfEntity(t,to.name)])
		newref.entity = newEntity
		newref.lower = "1"
		newref.upper = "-1"
		to.references.remove(oldRef)
		to.references.add(newref)
		return false
		
	}
	private def Reference createNewReverseReference(Entity from, Entity to, Reference oldref){
		var Reference newref = EJSLFactory.eINSTANCE.createReference
		newref.attribute.addAll(to.attributes.filter[t | isContainInMappingEntity(t.name,to.name,from)])
		newref.entity= from
		newref.attributerefereced.addAll(from.attributes.filter[t | isAttributeOfEntity(t, to.name)])
		newref.lower = "1"
		newref.upper = "-1"
		return newref
	}
	
	def boolean isContainInMappingEntity(String attributeName, String toEntityname, Entity mappingEntity) {
		
		if(mappingEntity.attributes.filter[t | t.name.toLowerCase.equalsIgnoreCase(toEntityname.toLowerCase() + "_"+attributeName)].size >0)
		   return true
		return false
	}
	
	private def boolean haveReferenTo(Entity to, Entity from, String upperValue){
		for(Reference ref : to.references){
			if(ref.entity.name == from.name && !upperValue.equalsIgnoreCase("1") && !ref.upper.equalsIgnoreCase("1"))
			return true
		}
		return false 
	}

	
	private def DetailPageField parseAttributeType(Attribute attribute) {
		var DetailPageField editField = EJSLFactory.eINSTANCE.createDetailPageField
		switch attribute.type{
			DatatypeReference :{
				var SimpleHTMLTypes result = EJSLFactory.eINSTANCE.createSimpleHTMLTypes
				result.htmltype = SimpleHTMLTypeKinds.get("Text_Field")
				editField.attribute = attribute
				editField.htmltype = result
				return editField
			}
			StandardTypes:{
				
				
				 
				return parsingType(attribute)
			}
		}
	}
	
	private def DetailPageField  parsingType(Attribute attribute) {
		var StandardTypes temptyp = attribute.type as StandardTypes
		var SimpleHTMLTypes result = EJSLFactory.eINSTANCE.createSimpleHTMLTypes
		var DetailPageField editField = EJSLFactory.eINSTANCE.createDetailPageField
		editField.attribute = attribute
			//	result.htmltype = SimpleHTMLTypeKinds.get(parsingType(temptyp))
		 
		switch (temptyp.type.getName()){
			case "Integer" :{
				result.htmltype = SimpleHTMLTypeKinds.get("Integer")
			}
			case "Boolean" :{
			result.htmltype = SimpleHTMLTypeKinds.get("Yes_No_Buttons")
				
			}
			case "Text" :{
				result.htmltype = SimpleHTMLTypeKinds.get( "Textarea")
			}
			case "Short_Text" :{
				result.htmltype = SimpleHTMLTypeKinds.get( "Text_Field")
			} 
			case "Time":{
				result.htmltype = SimpleHTMLTypeKinds.get( "Datepicker")
			    var KeyValuePair format = EJSLFactory.eINSTANCE.createKeyValuePair
			    format.name = "format"
			    format.value = "%H:%M:%S"
			  editField.attributes.add(format);
			    
				
			}
			case "Date":{
				result.htmltype = SimpleHTMLTypeKinds.get( "Datepicker")
				 var KeyValuePair format = EJSLFactory.eINSTANCE.createKeyValuePair
			    format.name = "format"
			    format.value = "%d-%m-%Y"
			    editField.attributes.add(format);
			}
			case "Datetime" :{
				result.htmltype = SimpleHTMLTypeKinds.get( "Datepicker")
					 var KeyValuePair format = EJSLFactory.eINSTANCE.createKeyValuePair
			    format.name = "format"
			    format.value = "%y-%m-%d %H:%M:%S"
			    editField.attributes.add(format);
				}
			case "Link" :{
				result.htmltype = SimpleHTMLTypeKinds.get( "Link")
			}
			case "Image":{
				result.htmltype = SimpleHTMLTypeKinds.get( "Imagepicker")
			}
			case "File" :{
				result.htmltype = SimpleHTMLTypeKinds.get( "Filepicker")
			}
			
		}
         editField.htmltype = result
		return editField
	}
	private def DetailsPage createNewExtendedDetailsPageForExtensions(Entity entity) {
		var DetailsPage detailsPage = EJSLFactory.eINSTANCE.createDetailsPage
		detailsPage.name = entity.name + "Details"
		detailsPage.entities.add(entity)
		detailsPage.tablecolumns.addAll(entity.attributes)		
		return detailsPage
	}
	
	
	
	private def IndexPage createNewExtendedIndexPageForExtensions(Entity entity) {
		var IndexPage dynPage = EJSLFactory.eINSTANCE.createIndexPage
		dynPage.name = entity.name + "List"
		dynPage.entities.add(entity)
		dynPage.tablecolumns.addAll(entity.attributes)	
		dynPage.filters.addAll(entity.attributes)	
		return dynPage
	}
	
	private def void createLinktoPage(IndexPage indexPage, DetailsPage detailsPage) {
		var InternalLink linktoDetailsPage = EJSLFactory.eINSTANCE.createInternalLink
		linktoDetailsPage.name = "Details"
		linktoDetailsPage.target = detailsPage
		linktoDetailsPage.linkedAttribute = indexPage.tablecolumns.get(0)
		indexPage.links.add(linktoDetailsPage)
		var InternalLink linktoIndexPage = EJSLFactory.eINSTANCE.createInternalLink
		linktoIndexPage.name = "Liste"
		linktoIndexPage.target = indexPage
		linktoIndexPage.linkedAttribute = detailsPage.tablecolumns.get(0)
		detailsPage.links.add(linktoIndexPage)

	}
	
	
	
}