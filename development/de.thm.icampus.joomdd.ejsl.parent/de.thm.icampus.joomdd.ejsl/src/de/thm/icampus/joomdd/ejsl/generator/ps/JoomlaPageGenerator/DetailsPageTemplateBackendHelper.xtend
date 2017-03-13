package de.thm.icampus.joomdd.ejsl.generator.ps.JoomlaPageGenerator

import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedExtension.ExtendedComponent
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedPage.ExtendedDynamicPage
import de.thm.icampus.joomdd.ejsl.generator.ps.JoomlaUtil.Slug
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedReference
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedEntity

class DetailsPageTemplateBackendHelper {
	private ExtendedDynamicPage dpage
	private ExtendedComponent  com
	private String sec
	private ExtendedEntity mainEntity
	new(ExtendedDynamicPage dp, ExtendedComponent cp, String section){
		
		dpage = dp
		com = cp
		sec = section
		mainEntity = dp.extendedEntityList.get(0)
	}
		
	def CharSequence generateAdminModelprepareTableFunction() '''
	/**
	 * Prepare and sanitise the table prior to saving.
	 *
	 * @since	1.6
	 */
	protected function prepareTable($table)
	{
		jimport('joomla.filter.output');

		if (empty($table->«mainEntity.primaryKey.name»)) {

			// Set ordering to the last item if not set
			if (@$table->ordering === '') {
				$db = JFactory::getDbo();
				$db->setQuery('SELECT MAX(ordering) FROM #__«com.name.toLowerCase»_«dpage.entities.get(0).name.toLowerCase»');
				$max = $db->loadResult();
				$table->ordering = $max+1;
			}

		}
	}
	'''
	
	
	def CharSequence genAdminControllerSave()'''
	/**
	     * Method to edit an existing record.
	     *
	     * @param   string $key The name of the primary key of the URL variable.
	     * @param   string $urlVar The name of the URL variable if different from the primary key
	     *                           (sometimes required to avoid router collisions).
	     *
	     * @return  boolean  True if access level check and checkout passes, false otherwise.
	     *
	     * @since   12.2
	     */
	    public function save($key = null, $urlVar = null)
	    {
	        $input = JFactory::getApplication()->input;
	        $model = $this->getModel();
	        $table = $model->getTable();
	        // Determine the name of the primary key for the data.
	        if (empty($key)) {
	            $key = $table->getKeyName();
	        }
	
	        // To avoid data collisions the urlVar may be different from the primary key.
	        if (empty($urlVar)) {
	            $urlVar = $key;
	        }
	
	        $recordId = $this->input->getInt($urlVar);
	
	        // Populate the row id from the session.
	        $data[$key] = $recordId;
	        $params = JComponentHelper::getParams('«Slug.nameExtensionBind("com",com.name).toLowerCase»');
	        $mediaHelper = new JHelperMedia;
	        $uploadMaxSize = $params->get('upload_maxsize', 0) * 1024 * 1024;
	        $uploadMaxFileSize = $mediaHelper->toBytes(ini_get('upload_max_filesize'));
	        $files = $input->files->get("jform", array(), 'array');
	        if (isset($files)) {
	            foreach ($files as $file) {
	                if (!isset($file['name'])) {
	                    $this->setMessage(JText::_('«Slug.nameExtensionBind("com",com.name).toUpperCase»_INVALID_FILE_NAME'), 'error');
	
	                    $this->setRedirect(
	                        JRoute::_(
	                            'index.php?option=' . $this->option . '&view=' . $this->view_item
	                            . $this->getRedirectToItemAppend($recordId, $urlVar), false
	                        )
	                    );
	
	                    return false;
	                }
	                if(strpos($file['type'],"image")!==false){
                        $path = $params->get("«dpage.name.toLowerCase»_image_path");
                    }else{
                        $path = $params->get("«dpage.name.toLowerCase»_file_path");
                    }
	                $file['name'] = JFile::makeSafe($file['name']);
	                $file['name'] = str_replace(' ', '-', $file['name']);
	                $file['filepath'] = JPath::clean(implode(DIRECTORY_SEPARATOR, array(JPATH_ROOT, $path, $file['name'])));
	                if (($file['error'] == 1)
	                    || ($uploadMaxSize > 0 && $file['size'] > $uploadMaxSize)
	                    || ($uploadMaxFileSize > 0 && $file['size'] > $uploadMaxFileSize)
	                ) {
	                    // File size exceed either 'upload_max_filesize' or 'upload_maxsize'.
	                    $this->setMessage(JText::_('«Slug.nameExtensionBind("com",com.name).toUpperCase»_ERROR_WARNFILETOOLARGE'), 'error');
	
	                    $this->setRedirect(
	                        JRoute::_(
	                            'index.php?option=' . $this->option . '&view=' . $this->view_item
	                            . $this->getRedirectToItemAppend($recordId, $urlVar), false
	                        )
	                    );
	                    return false;
	                }
	             
	            }
	            return parent::save($key, $urlVar);
	        }
	        }
	'''
	
	def generateAdminModelTableFunction()'''
	/**
	 * Returns a reference to the a Table object, always creating it.
	 *
	 * @param	type	The table type to instantiate
	 * @param	string	A prefix for the table class name. Optional.
	 * @param	array	Configuration array for model. Optional.
	 * @return	JTable	A database object
	 * @since	1.6
	 */
	public function getTable($type = '«dpage.entities.get(0).name.toFirstUpper»', $prefix = '«com.name.toFirstUpper»Table', $config = array())
	{
		return JTable::getInstance($type, $prefix, $config);
	}
	'''
	def generateAdminViewAddToolbar() '''
	/**
	     * Add the page title and toolbar.
	     */
	    protected function addToolbar() {
	        JFactory::getApplication()->input->set('hidemainmenu', true);
	
	        $user = JFactory::getUser();
	        $isNew = ($this->item->«mainEntity.primaryKey.name» == 0);
	        if (isset($this->item->checked_out)) {
	            $checkedOut = !($this->item->checked_out == 0 || $this->item->checked_out == $user->get('id'));
	        } else {
	            $checkedOut = false;
	        }
	        $canDo = «com.name.toFirstUpper»Helper::getActions();
	
	        JToolBarHelper::title(JText::_('COM_«com.name.toUpperCase»_TITLE_«dpage.name.toUpperCase»'), '«dpage.name.toLowerCase».png');
	
	        // If not checked out, can save the item.
	        if (!$checkedOut && ($canDo->get('core.edit') || ($canDo->get('core.create')))) {
	
	            JToolBarHelper::apply('«dpage.name.toLowerCase».apply', 'JTOOLBAR_APPLY');
	            JToolBarHelper::save('«dpage.name.toLowerCase».save', 'JTOOLBAR_SAVE');
	        }
	        if (!$checkedOut && ($canDo->get('core.create'))) {
	            JToolBarHelper::custom('«dpage.name.toLowerCase».save2new', 'save-new.png', 'save-new_f2.png', 'JTOOLBAR_SAVE_AND_NEW', false);
	        }
	        // If an existing item, can save to a copy.
	        if (!$isNew && $canDo->get('core.create')) {
	            JToolBarHelper::custom('«dpage.name.toLowerCase».save2copy', 'save-copy.png', 'save-copy_f2.png', 'JTOOLBAR_SAVE_AS_COPY', false);
	        }
	        if (empty($this->item->id)) {
	            JToolBarHelper::cancel('«dpage.name.toLowerCase».cancel', 'JTOOLBAR_CANCEL');
	        } else {
	            JToolBarHelper::cancel('«dpage.name.toLowerCase».cancel', 'JTOOLBAR_CLOSE');
			}
		}
		
	'''
	
	def generateAdminViewDisplay() '''
	/**
		* Display the view
		*/
		public function display($tpl = null) {
		$this->setLayout('Edit');
		$this->state = $this->get('State');
		$this->item = $this->get('Item');
		$this->form = $this->get('Form');
		
		// Check for errors.
		if (count($errors = $this->get('Errors'))) {
		throw new Exception(implode("\n", $errors));
		}
		
		$this->addToolbar();
		parent::display($tpl);
		}
		
	'''
	
	def generateAdminViewLayoutFormular() '''
	<form action="<?php echo JRoute::_('index.php?option=com_«com.name.toLowerCase»&layout=edit&«mainEntity.primaryKey.name»=' . (int) $this->item->«mainEntity.primaryKey.name»); ?>" method="post" enctype="multipart/form-data" name="adminForm" id="«dpage.name.toLowerCase»-form" class="form-validate">

	    <div class="form-horizontal">
	        <?php echo JHtml::_('bootstrap.startTabSet', 'myTab', array('active' => 'general')); ?>
	
	        <?php echo JHtml::_('bootstrap.addTab', 'myTab', 'general', JText::_('COM_«com.name.toUpperCase»_TITLE_«dpage.name.toUpperCase»', true)); ?>
	        <div class="row-fluid">
	            <div class="span10 form-horizontal">
	                <fieldset class="adminform">
	                <input type="hidden" name="jform[«mainEntity.primaryKey.name»]" value="<?php echo $this->item->«mainEntity.primaryKey.name»; ?>" />
				<input type="hidden" name="jform[ordering]" value="<?php echo $this->item->ordering; ?>" />
				<input type="hidden" name="jform[state]" value="<?php echo $this->item->state; ?>" />
				<input type="hidden" name="jform[published]" value="<?php if($this->item->«mainEntity.primaryKey.name» != 0) echo $this->item->state; else echo 1;?>"/>
				«IF !dpage.extendedEditedFieldsList.isNullOrEmpty && (dpage.extendedEditedFieldsList.filter[t | t.extendedAttribute.name.equalsIgnoreCase("title")]).size == 0»
				<input type="hidden" id="jform_title" value="<?php echo $this->item->«dpage.extendedEditedFieldsList.get(0).attribute.name»; ?>" />
				«ENDIF»
				<input type="hidden" name="jform[checked_out]" value="<?php if(isset($this->item->checked_out)){
				 echo $this->item->checked_out;}else{ echo JFactory::getUser()->id;} ?>" />
				<input type="hidden" name="jform[checked_out_time]" value="<?php if(isset($this->item->checked_out_time)){
				 echo $this->item->checked_out_time;}else{ echo date("Y-m-d H:i:s") ;} ?>" />
				
			<?php if(empty($this->item->created_by)){ ?>
					<input type="hidden" name="jform[created_by]" value="<?php echo JFactory::getUser()->id; ?>" />

				<?php } 
				else{ ?>
					<input type="hidden" name="jform[created_by]" value="<?php echo $this->item->created_by; ?>" />

				<?php } ?>
				«Slug.generateEntytiesInputAttribute(dpage.extendedEditedFieldsList, dpage.extendedEntityList.get(0))»
				  
				 
				</fieldset>
			</div>
			</div>
	        <?php echo JHtml::_('bootstrap.endTab'); ?>
	        «FOR ExtendedReference ref: dpage.extendedEntityList.get(0).extendedReference.filter[t | t.upper.equalsIgnoreCase("*") || t.upper.equalsIgnoreCase("-1")]»
			  «Slug.generateEntytiesBackendInputRefrence(ref,com)»
			«ENDFOR» 
	        
		    <?php if (JFactory::getUser()->authorise('core.admin','«com.name.toLowerCase»')) : ?>
				<?php echo JHtml::_('bootstrap.addTab', 'myTab', 'permissions', JText::_('JGLOBAL_ACTION_PERMISSIONS_LABEL', true)); ?>
				<?php echo $this->form->getInput('rules'); ?>
				<?php echo JHtml::_('bootstrap.endTab'); ?>
			<?php endif; ?>

			<?php echo JHtml::_('bootstrap.endTabSet'); ?>
			

	        <input type="hidden" name="task" value="" />
	        <?php echo JHtml::_('form.token'); ?>
	
	    </div>
	</form>
	'''
	
}