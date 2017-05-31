
require(["jquery","infomodal"], function($,infomodal) {
	
	$("#templates").change(function(){
	var nameTemplate = $(this).val();
	$.ajax({
		  method: "GET",
		  url: "/instance-loader/",
		  data: { name: nameTemplate }
		})
		  .done(function( msg ) {
			  var editor = $("#xtext-editor");
			  editor[0].env.editor.getSession().setValue(msg);
			 
		  });
});
	require([ "cookie","treeloader"],function(Cookies,treeloader){
	
		$("#ejslGeneratorsave").click(function(){
		var name = Cookies.get('joomddusername');
		var resourceid = Cookies.get('resourceid');
		var editor = $("#xtext-editor");
		var save = editor[0].env.editor.xtextServices.saveResource();
		save.then( value => {
			infomodal.showmodal("Resource was successfull saved!")
		}, reason => {
			infomodal.showmodal("Failur was happen! Contact the Support")
		} );
		});
		
		$("#ejslReverseModel").click(function(){
			var data = $('#folder_tree').jstree(true).get_selected();
			var name = Cookies.get('joomddusername');
			var dataArray = data[0].split("/");
			if(dataArray[2] == "reverse" && dataArray[dataArray.length-1].endsWith(".xml")){
				infomodal.showloadmodal();
			var modelName = dataArray[dataArray.length-1].replace(".xml",".eJSL")
				$.ajax({
					  url: '/reverse-loader/',
					  type: 'PUT',
					  data: {user:name,manifest:data[0],model:modelName},
					  success: function(data) {
						  infomodal.closeloadmodal();
					    if(data){
					    	var name = Cookies.get('joomddusername');
					    	treeloader.reload()
					    }else{
					    	infomodal.showmodal("Failed! The Model cannot be extract!");
					    }
					  }
					});
			}
			});
		require([ "editorhandler"],function(editorhandler){
		$("#ejslLoadModel").click(function(){
			var data = $('#folder_tree').jstree(true).get_selected();
			var name = Cookies.get('joomddusername');
			if(data.length ==1){
				var nameArray = data[0].split("/");
				var namefile = nameArray[nameArray.length-1]
				editorhandler.loadEditor(name,namefile);
				 location.reload(); 
			}else{
				
			infomodal.showmodal("Choose only one Model!");
			}

		});
		$('#eJSlCreateModel').click(function(){
			var name = Cookies.get('joomddusername');
			var filename = $("#addfile").val()
			var tempArray = filename.split(".")
			if(tempArray[tempArray.length-1] != "eJSL")
				filename= filename+".eJSL"
			if(tempArray.length > 1)
				filename = tempArray[0] + ".eJSL"
				Cookies.set('resourceid',filename);
			var response = editorhandler.loadEditor(name, filename+"");
			 location.reload(); 

		});
		$('#eJSlUploadModel').click(function(){
			var name = Cookies.get('joomddusername');
			var input = $("#addRevers")[0].files[0];
			infomodal.showloadmodal();
			$.ajax({ url:"/reverse-loader/?filename=" + input.name,
				    method:"POST",
					dataType: 'application/zip',
					 contentType: "multipart/form-data",
					 processData: false,
					data:input,
					complete:function(data){
						infomodal.closeloadmodal();
						if(data){
					    	infomodal.showmodal("The Upload was succesfull, reload the Page");
					    	treeloader.reload()
						}else{
							infomodal.showmodal("Failure in the Loading of extension");
						}
					}
			    	});
		});
	});
});
});
