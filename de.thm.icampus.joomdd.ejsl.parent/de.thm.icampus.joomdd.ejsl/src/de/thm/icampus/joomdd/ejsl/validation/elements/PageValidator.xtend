package de.thm.icampus.joomdd.ejsl.validation.elements

import de.thm.icampus.joomdd.ejsl.eJSL.DynamicPage
import de.thm.icampus.joomdd.ejsl.eJSL.DetailsPage
import de.thm.icampus.joomdd.ejsl.eJSL.EJSLModel
import de.thm.icampus.joomdd.ejsl.eJSL.EJSLPackage
import de.thm.icampus.joomdd.ejsl.eJSL.Entity
import de.thm.icampus.joomdd.ejsl.eJSL.IndexPage
import de.thm.icampus.joomdd.ejsl.eJSL.Page
import java.util.HashSet
import org.eclipse.xtext.validation.AbstractDeclarativeValidator
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.validation.EValidatorRegistrar
import de.thm.icampus.joomdd.ejsl.validation.util.HTMLTypeMappings
import de.thm.icampus.joomdd.ejsl.eJSL.SimpleHTMLTypeKinds
import de.thm.icampus.joomdd.ejsl.eJSL.HTMLTypes
import java.util.HashMap
import java.util.Arrays

/**
 * This class contains custom validation rules about Pages
 * 
 */
class PageValidator extends AbstractDeclarativeValidator {

    public static val PAGE_AMBIGUOUS = 'ambiguousPage'
    public static val PAGE_TABLE_COLUMN_AMBIGUOUS = 'ambiguousTableColumnAttribute'
    public static val PAGE_FILTER_AMBIGUOUS = 'ambiguousFilterAttribute'
    public static val PAGE_COLUMNS_USED_MULTIPLE_TIMES = 'columnsUsedMultipleTimes'
    public static val PAGE_FILTER_USED_MULTIPLE_TIMES = 'filterUsedMultipleTimes'
    public static val PAGE_FORBIDDEN_UNDERSCORE = 'forbiddenUnderscorePagename'
    public static val PAGE_MISSING_REFERENCE_TO_MAIN_ENTITY = 'noReferenceToMainEntity'
    public static val PAGE_LOCALPARAMETER_AMBIGOUS = 'ambiguousLocalparam'
    public static val PAGE_GLOBALPARAMETER_AMBIGUOUS = 'ambiguousGlobalparam'
    public static val PAGE_ENTITY_USED_MULTIPLE_TIMES = 'entityUsedMultipleTimes'
    public static val PAGE_DETAILSPAGE_EDITFIELDS_REFERENCE = 'invalidEditfieldReference'
    public static val PAGE_EDITFIELDS_WRONG_HTML_TYPE = 'wrongHTMLType'

    public override register(EValidatorRegistrar registrar) {}

    /**
     * Checks if the existing pages of the model have different/unique names
     */
    @Check
    def checkPagesAreUnique(EJSLModel model) {
        var pages = new HashSet<String>

        var ejslPart = model.ejslPart

        if (ejslPart !== null) {
            for (page : ejslPart.feature.pages) {
				if (page !== null) {
					if (!pages.add(page.getName)) {
						error(
							'Page names must be unique.',
							page,
							EJSLPackage.Literals.PAGE__NAME,
							de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_AMBIGUOUS
						)
					}
				}
			}
        }
    }

    /**
     * Check if entities that occur in index pages with further entities, have a reference to the first entity
     */
    @Check
    def checkMultipleEntitiesInIndexPageReferences(EJSLModel model) throws Exception {
        var mainEntities = new HashSet<Entity>
        var foundReferenceEntity = new HashSet<Entity>
        var duplicateEntity = false;
        var ejslPart = model.ejslPart

        if (ejslPart !== null) {
            for (page : ejslPart.feature.pages) {
                if (page instanceof IndexPage) {

                    if (page.entities !== null && page.entities.size > 1) {
                        // Save main entity
                        mainEntities.add(page.entities.get(0))
                        for (int i : 1 ..< page.entities.size) {

							// Check for duplicate entity (will be caught by multiple entity usage rule)
							if (page.entities.get(i).name.toLowerCase == mainEntities.get(0).name.toLowerCase) {
								duplicateEntity = true;
							}
							
                            // Check if current entity has a reference to main entity
							for (referencedE : page.entities.get(i).references) {
								if (referencedE !== null) {
									if (referencedE.entity instanceof Entity) {
										if (referencedE.entity.name.toLowerCase == mainEntities.get(0).name.toLowerCase) {
											foundReferenceEntity.add(referencedE.entity as Entity)
										}
									}
								}
							}
                            if (foundReferenceEntity.empty && !duplicateEntity) {
                                error(
                                    'Entity: \'' + page.entities.get(i).name + '\' of IndexPage: \'' + page.name +
                                        '\' has no reference to IndexPage main-entity: \'' +
                                        mainEntities.get(0).name + '\'.',
                                    page,
                                    EJSLPackage.Literals.DYNAMIC_PAGE__ENTITIES,
                                    i,
                                    de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_MISSING_REFERENCE_TO_MAIN_ENTITY
                                )
                            }
                            duplicateEntity = false;
                            foundReferenceEntity.clear
                        }
                    }
                    mainEntities.clear
                }
            }
        }
    }

    /**
     * Check if edit field type exists as entity reference
     */
    @Check
    def checkDetailsPageFieldEntityReference(DetailsPage p) {
    	
        // Check if editfields are used
        if (p.editfields.size > 0) {
            var refEntities = new HashSet<String>

            // Build map with all referenced entity and attribute names for an entity (Talk.Participant.name)
			if (p.entities !== null) {
				for (entity : p.entities) {
					if (entity.references !== null) {
						for (ref : entity.references) {
							if (ref.attributerefereced !== null) {
								for (attrRef : ref.attributerefereced) {
									if (attrRef.eContainer instanceof Entity) {
										val refEnt = attrRef.eContainer as Entity
										refEntities.add(entity.name + "." + refEnt.name + "." + attrRef.name)
									}
								}
							}							
						}
					}
				}
			}
            

            // Check if editfield type is set as reference in entity
            for (editf : p.editfields) {
                if (editf.fieldtype !== null) {
                    if (editf.attribute.eContainer instanceof Entity && editf.fieldtype.eContainer instanceof Entity) {
                        val ent = editf.attribute.eContainer as Entity
                        val refEnt = editf.fieldtype.eContainer as Entity
                        if (refEntities.add(ent.name + "." + refEnt.name + "." + editf.fieldtype.name)) {
                            error(
                                'Field type of editfield has to be a reference in given entity.',
                                editf,
                                EJSLPackage.Literals.DETAILS_PAGE__EDITFIELDS.EOpposite,
                                de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_DETAILSPAGE_EDITFIELDS_REFERENCE
                            )
                        }
                    }
                }
            }
        }
    }

    /**
     * Check if the entity in the filter is declared in the page
     * Cannot cast containing entity of filter to EJSL::Entity
     */
    @Check
    def nonDeclaredFilterAttribute(DynamicPage p) throws Exception{
    	if (p.filters !== null) {
    		for (filt : p.filters) {
				val enti = filt.eContainer
				if (enti instanceof Entity) {
					if (!p.entities.contains(enti)) {
						error(
							'Entity for the filter attribute must be declared before.',
							filt,
							EJSLPackage.Literals.DYNAMIC_PAGE__FILTERS.EOpposite,
							de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_FILTER_AMBIGUOUS
						)
					}
				} else {
					error(
						'May trying to referencing a non existing entity for a filter.',
						filt,
						EJSLPackage.Literals.DYNAMIC_PAGE__FILTERS.EOpposite,
						de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_FILTER_AMBIGUOUS
					)
				}
			}
    	}
    }

    /**
     * Check if the entity in the table column is declared in the page
     */
    @Check
    def nonDeclaredColumnAttribute(DynamicPage p) throws Exception{
    	if (p.tablecolumns !== null) {
    		for (column : p.tablecolumns) {
				val enti = column.eContainer
				if (enti instanceof Entity) {
					if (!p.entities.contains(enti)) {
						error(
							'Entity for the table column attribute must be declared before.',
							column,
							EJSLPackage.Literals.DYNAMIC_PAGE__TABLECOLUMNS.EOpposite,
							de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_TABLE_COLUMN_AMBIGUOUS
						)
					}
				} else {
					error(
						'May trying to referencing a non existent Entity for a column.',
						column,
						EJSLPackage.Literals.DYNAMIC_PAGE__TABLECOLUMNS.EOpposite,
						de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_TABLE_COLUMN_AMBIGUOUS
					)
				}
			}
    	}   
    }

    /**
     * Check table column are only once in a page
     */
    @Check
    def checkTableColumnsAreUnique(DynamicPage p) {
        var enticolumns = new HashSet<String>
        if (p.tablecolumns !== null) {
        	for (column : p.tablecolumns) {
				val enti = column.eContainer
				if (enti instanceof Entity) {
					if (!enticolumns.add(enti.name + column.name)) {
						error(
							'table column used multiple times in this Page.',
							column,
							EJSLPackage.Literals.DYNAMIC_PAGE__TABLECOLUMNS.EOpposite,
							PAGE_COLUMNS_USED_MULTIPLE_TIMES
						)
					}
				} else {
					error(
						'May trying to referencing to a non existing entity for a column.',
						column,
						EJSLPackage.Literals.DYNAMIC_PAGE__TABLECOLUMNS.EOpposite,
						PAGE_COLUMNS_USED_MULTIPLE_TIMES
					)
				}
			}
        }     
    }

    /**
     * Check Filters are only once in a page
     */
    @Check
    def checkFiltersAreUnique(DynamicPage p) {
        var entifilters = new HashSet<String>
        if (p.filters !== null) {
        	for (filter : p.filters) {
				val enti = filter.eContainer
				if (enti instanceof Entity) {
					if (!entifilters.add(enti.name + filter.name)) {
						error(
							'Filter used multiple times in this Page!',
							p,
							EJSLPackage.Literals.DYNAMIC_PAGE__FILTERS.EOpposite,
							de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_FILTER_USED_MULTIPLE_TIMES
						)
					}
				} else {
					error(
						'May trying to referencing to a non existing entity for a filter.',
						p,
						EJSLPackage.Literals.DYNAMIC_PAGE__FILTERS.EOpposite,
						de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_FILTER_USED_MULTIPLE_TIMES
					)
				}
			}
        }   
    }

    /**
     * Check if details page fields are mapped to suitable HTML types
     */
    @Check
    def checkDetailsPageFieldHTMLTypes(DetailsPage p) {
    	if (p.editfields !== null) {
    		for (editfield : p.editfields) {
    			
				// get HTML type
				var String x = new String();
				var String htmltype = new String();
				if (editfield.htmltype !== null) {
					x = editfield.htmltype.toString();
					htmltype = x.substring(x.lastIndexOf(': ') + 2, x.length - 1);
				}
				
				// get attribute type
				var String y = new String();
				var String attrType = new String();
				if (editfield.attribute !== null) {
					y = editfield.attribute.type.toString();
					attrType = y.substring(y.lastIndexOf('type: ') + 6, y.indexOf(','));
				}
				
				var htmlTypeMapping = HTMLTypeMappings.HTMLTYPEMAP.get(htmltype)

				if (htmlTypeMapping !== null) {
					if (! htmlTypeMapping.contains(attrType)) {
						error(
							'Edit fields have to be mapped to a suitable HTML type',
							editfield,
							EJSLPackage.Literals.DETAILS_PAGE__EDITFIELDS.EOpposite,
							de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_EDITFIELDS_WRONG_HTML_TYPE
						)
					}
				}
			}
    	}     
    }

    /**
     * Check if all local parameters of a page have different/unique names.
     */
    @Check
    def checkPageLocalparametersAreUnique(Page p) {
        var params = new HashSet<String>

		if (p.localparameters !== null) {
			for (param : p.getLocalparameters) {
				if (!params.add(param.name)) {
					error(
						'Localparameter name must be unique per page.',
						param,
						EJSLPackage.Literals.PARAMETER__NAME,
						de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_LOCALPARAMETER_AMBIGOUS
					)
				}
			}
		}
    }

    /**
     * Validates if all global parameters of a model have different/unique names.
     */
    @Check
    def checkPageGlobalparametersAreUnique(EJSLModel model) {
        var params = new HashSet<String>
        var ejslPart = model.ejslPart

        if (ejslPart !== null && ejslPart.globalparameters !== null) {
            for (param : ejslPart.getGlobalparameters) {
                if (!params.add(param.getName)) {
                    error(
                        'Globalparameter name must be unique.',
                        param,
                        EJSLPackage.Literals.PARAMETER__NAME,
                        de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_GLOBALPARAMETER_AMBIGUOUS
                    )
                }
            }
        }
    }

    /**
     * Validate that an entity can only used once per Page and not multiple times.
     */
    @Check
    def checkEntitysAreUsedOnlyOncePerPage(DynamicPage page) {
        var entities = new HashSet<String>

        var i = 0
        if (page.entities !== null) {
			for (entity : page.getEntities) {
				if (!entities.add(entity.name)) {
					warning(
						'Entity is used multiple times for this page.',
						EJSLPackage.Literals.DYNAMIC_PAGE__ENTITIES,
						i,
						de.thm.icampus.joomdd.ejsl.validation.elements.PageValidator.PAGE_ENTITY_USED_MULTIPLE_TIMES
					)
				}
				i++
			}
		} 
    }
}
