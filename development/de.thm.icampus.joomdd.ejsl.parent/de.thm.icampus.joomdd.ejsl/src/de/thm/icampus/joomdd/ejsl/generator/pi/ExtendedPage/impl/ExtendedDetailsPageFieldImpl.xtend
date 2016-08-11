package de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedPage.impl

import de.thm.icampus.joomdd.ejsl.eJSL.ComplexHTMLTypes
import de.thm.icampus.joomdd.ejsl.eJSL.DetailPageField
import de.thm.icampus.joomdd.ejsl.eJSL.SimpleHTMLTypes
import de.thm.icampus.joomdd.ejsl.eJSL.impl.DetailPageFieldImpl
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedAttribute
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.impl.ExtendedAttributeImpl
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedPage.ExtendedDetailPageField

class ExtendedDetailsPageFieldImpl extends DetailPageFieldImpl implements ExtendedDetailPageField {
	
	String type
	ExtendedAttribute extendedAttribute
	DetailPageField instance
	new(DetailPageField field) {
		instance = field
		this.attribute = field.attribute
		this.htmltype = field.htmltype
		extendedAttribute = new ExtendedAttributeImpl(this.attribute)
		this.options = field.options
		type = parseType()
	}
	
	def String parseType() {
			switch instance.htmltype{
				SimpleHTMLTypes:{
					var SimpleHTMLTypes type = instance.htmltype as SimpleHTMLTypes
					return type.htmltype.getName
				}
				ComplexHTMLTypes:{
					var ComplexHTMLTypes  type = instance.htmltype as ComplexHTMLTypes
					return type.htmltype.getName
				}
			}
	}
	
	override getType() {
		return type
	}
	
	
	override getExtendedAttribute() {
		return extendedAttribute
	}
	
	override getExtrasKeyValue() {
		if(this.htmltype instanceof ComplexHTMLTypes){
			var ComplexHTMLTypes cpHtml  = this.htmltype as ComplexHTMLTypes
			return cpHtml.keyvaluepairs
		}
	}
	
	
}