package de.thm.icampus.joomdd.ejsl.generator.ps.joomla4.JoomlaPageGenerator

import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedAttribute
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedExtension.ExtendedComponent
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedPage.ExtendedDynamicPage
import de.thm.icampus.joomdd.ejsl.generator.ps.joomla4.JoomlaUtil.Slug
import org.eclipse.xtext.generator.IFileSystemAccess2
import de.thm.icampus.joomdd.ejsl.generator.ps.joomla4.JoomlaUtil.StaticLanguage
import de.thm.icampus.joomdd.ejsl.generator.pi.util.MappingEntity
import java.util.OptionalInt
import java.util.stream.IntStream

/**
 * This class contains the templates to generate the necessary code for view templates.
 * 
 * @author Dieudonne Timma, Dennis Priefer
 * 
 */
class IndexPageTemplate extends DynamicPageTemplate {

    ExtendedDynamicPage ipage
    ExtendedComponent com
    String sec
    IndexPageTemplateAdminHelper helperAdmin
    IndexPageTemplateSiteHelper frontHelp
    String path
    String modelPath
    String viewPath
    String tmplPath
    String controllerPath
    String formPath
    String pagename

    new(ExtendedDynamicPage dp, ExtendedComponent cp, String section, String path, IFileSystemAccess2 fsa) {
        ipage = dp
        com = cp
        sec = section
        helperAdmin = new IndexPageTemplateAdminHelper(ipage, com, sec)
        frontHelp = new IndexPageTemplateSiteHelper(ipage, com, sec)
        this.path = path
        this.modelPath = path + "/Model"
        this.viewPath = path + "/View"
        this.tmplPath = path + "/tmpl"
        this.controllerPath = path + "/Controller"
        this.formPath = path + "/forms"
        pagename = Slug.slugify(dp.name.toLowerCase)
        this.fsa = fsa
    }

    def void generateView() {
        if (sec.equalsIgnoreCase("admin")) {
            generateFile(viewPath + "/" + pagename.toFirstUpper + "/" + "HtmlView.php", generateViewBackend())
            generateFile(tmplPath + "/" + pagename + "/" + "default.php", generateAdminViewLayoutBackend())
        } else {
            generateFile(viewPath + "/" + pagename.toFirstUpper + "/" + "HtmlView.php", generateSiteView())
            generateFile(tmplPath + "/" + pagename + "/" + "default.php", generateSiteViewLayoutShow())
            generateFile(tmplPath + "/" + pagename + "/" + "default.xml", xmlSiteTemplateContent(pagename, ipage, com))
        }
    }

    def CharSequence generateSiteViewLayoutShow() '''
        «generateFileDoc(ipage,com)»
        
        «Slug.generateUses(newArrayList("LayoutHelper", "Route", "Factory", "Html", "Text"))»
        
        «frontHelp.genViewTemplateInit»
        «frontHelp.genViewTemplateHead»
    '''

    def void generateController() {
        if (sec.equalsIgnoreCase("admin")) {
            generateFile(controllerPath + "/" + pagename.toFirstUpper + "Controller.php", generateAdminController())
        } else {
            generateFile(controllerPath + "/" + pagename.toFirstUpper + "Controller.php", generateSiteController())
        }
    }

    def CharSequence generateSiteController() '''
        «generateFileDoc(ipage, com)»
        
        «Slug.generateNamespace(com.name, "Site", "Controller")»
        
        «Slug.generateRestrictedAccess()»
        
        /**
         * Sliders list controller class.
         */
        class «ipage.name.toFirstUpper»Controller extends DisplayController
        {
            /**
             * Proxy for getModel.
             * @since  1.6
             */
            public function getModel($name = '«ipage.name.toFirstUpper»', $prefix = 'Site', $config = array())
            {
                $model = parent::getModel($name, $prefix, array('ignore_request' => true));
        
                return $model;
            }
        }
    '''

    def void generateModel() {
        if (sec.compareTo("admin") == 0) {
            generateFile(modelPath + "/" + pagename.toFirstUpper + "Model.php", generateAdminModel())
            generateFile(formPath + "/filter_" + pagename + ".xml", generateModelForms("Administrator"))
        } else {
            generateFile(modelPath + "/" + pagename.toFirstUpper + "Model.php", generateSiteModelShow)
            generateFile(formPath + "/filter_" + pagename + ".xml", generateModelForms("Site"))
        }
    }

    def CharSequence generateSiteModelShow() '''
        «generateFileDoc(ipage, com)»
        
        «Slug.generateNamespace(com.name, "Site", "Model")»
        
        «Slug.generateRestrictedAccess()»
        
        «Slug.generateUses(newArrayList("ModelList", "ComponentHelper", "Factory"))»
        
        /**
         * Methods supporting a list of Data.
         * @generated
         */
        class «ipage.name.toFirstUpper»Model extends ListModel
        {
            «helperAdmin.genAdminModelConstruct»
            «helperAdmin.genAdminModelGetItem»
            «helperAdmin.genAdminModelPopulateState»
            «helperAdmin.genAdminModelGetListQuery()»
            «helperAdmin.genGetIdOfReferenceItem»
        }
    '''

    def CharSequence generateViewBackend() '''
        «generateFileDoc(ipage, com)»
        
        «Slug.generateNamespace(com.name, "Administrator", "View\\" + pagename.toFirstUpper)»
        
        «Slug.generateRestrictedAccess()»
        
        «Slug.generateUses(newArrayList("Factory", "ViewLegacy", "Text", "ToolbarHelper", "Html", "Toolbar"))»
        use Joomla\Component\«com.name.toFirstUpper»\Administrator\Extension\«com.name.toFirstUpper»Component;
        use Joomla\Component\«com.name.toFirstUpper»\Administrator\Helper\«com.componentHelperClassName»;
        
        /**
         * @description «ipage.entities.get(0).name»View for «com.name»
         */
        jimport('joomla.filesystem.path');
        /**
         * «com.name»View class for component com_«Slug.slugify(com.name)»
         *
         * @category Joomla.Component. Admin
         * @package com_«Slug.slugify(com.name)»."admin"
         * @generated
         */
        class HtmlView extends BaseHtmlView
        {
            /**
             * An array of items
             *
             * @var  array
             */
            protected $items;

            /**
             * The pagination object
             *
             * @var  \JPagination
            */
            protected $pagination;

            /**
             * The model state
             *
             * @var  \JObject
             */
            protected $state;

            /**
             * Form object for search filters
             *
             * @var  \JForm
             */
            public $filterForm;

            /**
             * The active search filters
             *
             * @var  array
             */
            public $activeFilters;

            /**
             * The sidebar markup
             *
             * @var  string
             */
            protected $sidebar;

            «helperAdmin.genAdminViewDisplay»

            «helperAdmin.genAdminViewAddtoolbar»

            «helperAdmin.genAdminViewSortFields(ipage.extendedTableColumnList)»
        }
    '''

    def CharSequence generateAdminViewLayoutBackend() ''' 
        «generateFileDoc(ipage,com)»
        
        «Slug.generateUses(newArrayList("LayoutHelper", "Route", "Factory", "Html", "Text", "Session"))»
        
        HTMLHelper::_('bootstrap.tooltip');
        HTMLHelper::_('behavior.multiselect');
        HTMLHelper::_('behavior.tabstate');
        
        $columns = «helperAdmin.getextendedTableColumnListSize + 1»;
        «helperAdmin.genAdminViewLayoutHeader»
        «helperAdmin.genAdminViewLayoutForm»
    '''

    def CharSequence generateAdminModel() '''
        «generateFileDoc(ipage, com)»
        
        «Slug.generateNamespace(com.name, "Administrator", "Model")»
        
        «Slug.generateRestrictedAccess()»
        
        «Slug.generateUses(newArrayList("ModelList", "ComponentHelper", "Factory"))»
        
        /**
         * Methods supporting a list of Data.
         * @generated
         */
        class «ipage.name.toFirstUpper»Model extends ListModel
        {
            «helperAdmin.genAdminModelConstruct»
            «helperAdmin.genAdminModelGetItem»
            «helperAdmin.genAdminModelGetListQuery()»
            «helperAdmin.genAdminModelSaveOrder»
            «helperAdmin.genAdminModelPopulateState»
            «IF !ipage.entities.get(0).references.empty»
                «helperAdmin.genGetIdOfReferenceItem»
            «ENDIF»
        }
    '''

    def CharSequence generateAdminController() '''
        «generateFileDoc(ipage, com)»
        
        «Slug.generateNamespace(com.name, "Administrator", "Controller")»
        
        «Slug.generateRestrictedAccess()»
        
        «Slug.generateUses(newArrayList("ControllerAdmin", "ResponseJson", "Factory"))»
        
        /**
         * «ipage.name.toFirstUpper» list controller .
         * @generated
         */
        class «ipage.name.toFirstUpper»Controller extends AdminController
        {
            /**
             * The URL view list variable.
             *
             * @var    string
             * @since  1.6
             */
            protected $view_list = "«ipage.name»";
            
            «helperAdmin.genAdminControllerSaveOrdering»
            «helperAdmin.genAdminControllerGetModel»
        }
    '''

    def CharSequence generateSiteView() '''
        «generateFileDoc(ipage.instance,com)»
        
        «Slug.generateNamespace(com.name, "Site", "View\\" + ipage.name.toFirstUpper)»
        
        «Slug.generateRestrictedAccess()»
        
        «Slug.generateUses(newArrayList("ViewLegacy", "Text", "Factory"))»
        
        /**
         * View to  Show the Data
         */
        class HtmlView extends BaseHtmlView
        {
            protected $state;
            protected $item;
            protected $form;
            protected $params;
            «frontHelp.generateSiteViewDisplay()»
            «frontHelp.generateSiteViewprepareDocument()»
        }
    '''

    def CharSequence generateModelForms(String section) '''
        <?xml version="1.0" encoding="utf-8"?>
        <form addfieldprefix="Joomla\Component\«com.name.toFirstUpper»\«section»\Field">
            <fields name="filter">
                <field
                    name="search"
                    type="text"
                    label="«Slug.addLanguage(com.languages, newArrayList("com", com.name, ipage.name), StaticLanguage.SEARCH_LABEL)»"
                    description="«Slug.addLanguage(com.languages, newArrayList("com", com.name, ipage.name), StaticLanguage.SEARCH_DESC)»"
                    hint="JSEARCH_FILTER"
                />
                <field
                    name="state"
                    type="status"
                    label="JOPTION_SELECT_PUBLISHED"
                    description="JOPTION_SELECT_PUBLISHED_DESC"
                    onchange="this.form.submit();">
                    <option value="">JOPTION_SELECT_PUBLISHED</option>
                </field>
                <field
                    name="created_by"
                    type="«com.name.toLowerCase»user"
                    label="JGLOBAL_FIELD_CREATED_BY_LABEL"
                    description="JGLOBAL_FIELD_CREATED_BY_DESC"
                    entity="«ipage.extendedEntityList.get(0).name»"
                    onchange="this.form.submit();">
                    <option value="">JOPTION_SELECT_AUTHOR</option>
                </field>
                «FOR ExtendedAttribute attr : ipage.extendFiltersList»
                    «var valueColumn = ipage.getValueColumn(attr, com.allExtendedEntity)»
                    «var textColumn = ipage.getTextColumn(attr, com.allExtendedEntity)»
                    <field
                        name="«attr.name»"
                        type="«textColumn.type»"
                        label="«Slug.addLanguage(com.languages, newArrayList("com", com.name, "FILTER", attr.name, "LABEL"), attr.name)»"
                        description="«Slug.addLanguage(com.languages, newArrayList("com", com.name, "FILTER", attr.name, "DESC"), StaticLanguage.getCommonDescriptionFor(attr.name))»"
                        valueColumn="«valueColumn»"
                        textColumn="«textColumn»"
                        onchange="this.form.submit();">
                        <option value="">«Slug.addLanguage(com.languages, newArrayList("com", com.name, "FILTER", "SELECT", attr.name), '''- Select «attr.name» -''')»</option>
                    </field>
                «ENDFOR»
                «Slug.generateFilterFields(ipage, com.languages, com, '''com_«com.name»''', false, false, false, true)»
            </fields>
            <fields name="list">
                <field
                    name="fullordering"
                    type="list"
                    label="JGLOBAL_SORT_BY"
                    default="«ipage.extendedEntityList.get(0).name».«ipage.extendedEntityList.get(0).primaryKey.name» ASC"
                    onchange="this.form.submit();"
                >
                    <option value="">JGLOBAL_SORT_BY</option>
                    <option value="«ipage.entities.get(0).name».ordering ASC">JGRID_HEADING_ORDERING_ASC</option>
                    <option value="«ipage.entities.get(0).name».ordering DESC">JGRID_HEADING_ORDERING_ASC</option>
                    «FOR ExtendedAttribute attr : ipage.extendedTableColumnList»
                    <option value="«ipage.entities.get(0).name».«attr.name» ASC">«Slug.addLanguage(com.languages, newArrayList("com", com.name, "FORM", "LBL", attr.entity.name, attr.name.toUpperCase, "ASC"), '''«attr.name» ascending''')»</option>
                    <option value="«ipage.entities.get(0).name».«attr.name» DESC">«Slug.addLanguage(com.languages, newArrayList("com", com.name, "FORM", "LBL", attr.entity.name, attr.name.toUpperCase, "DESC"), '''«attr.name» descending''')»</option>
                    «ENDFOR»
                </field>
                <field
                    name="limit"
                    type="limitbox"
                    label="JGLOBAL_LIST_LIMIT"
                    default="25"
                    onchange="this.form.submit();"
                />
        </fields>
        </form>
    '''
}
