package de.thm.icampus.joomdd.ejsl.web

import com.google.gson.Gson
import java.io.BufferedInputStream
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream
import java.util.Enumeration
import java.util.zip.ZipEntry
import java.util.zip.ZipFile
import javax.servlet.ServletContext
import javax.servlet.ServletException
import javax.servlet.ServletInputStream
import javax.servlet.annotation.WebServlet
import javax.servlet.http.Cookie
import javax.servlet.http.HttpServlet
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import de.thm.icampus.joomdd.ejsl.web.util.Helper
import java.net.URLDecoder
import java.io.BufferedReader
import java.io.InputStreamReader
import com.google.common.base.CharMatcher
import org.eclipse.jetty.util.StringUtil

/**
 * @author Dieudonne Timma
 */
@WebServlet(name = 'ReverseLoader', urlPatterns = '/reverse-loader/*')
class ReverseLoader extends HttpServlet {
	
	override protected doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		var String sessionID = req.session.id

		var workspaceUserPath = Helper.getWorkspaceUserPath(sessionID)
		
		var String manifest = workspaceUserPath + req.getParameter("manifest").replace("download-manager", "")
		manifest = URLDecoder.decode(manifest, "UTF-8");
		
		var String model = req.getParameter("model")
		
		var String target = workspaceUserPath + "/src/" + model
		
		var ServletContext context = this.servletContext;
        
		var String rootPath = CharMatcher.is('/').trimTrailingFrom(context.getRealPath("/")) + "/jar";
		var String jarPath = rootPath + "/jext2ejsl.jar"

		resp.status = HttpServletResponse.SC_OK
		resp.setHeader('Cache-Control', 'no-cache')
		resp.contentType = 'text/x-json'
		val gson = new Gson
		try{
		    var ProcessBuilder pb = new ProcessBuilder("java", "-jar", '''«jarPath»''', "-m", '''«manifest»''', "-o", '''«target»''', "-no-gui")
            pb.redirectErrorStream(true) // equivalent of 2>&1
		    		    
			var Process proc = pb.start()
			proc.waitFor
			
			var int status = proc.exitValue
			if(status == 0){
				gson.toJson(true, resp.writer)
			} else {
                try {
                    var BufferedReader b = new BufferedReader(new InputStreamReader(proc.getErrorStream()))
                    var String line;
                    if ((line = b.readLine()) !== null)
                    {
                        println(line);
                    }
                } catch (IOException e) {
                    e.printStackTrace()
                }     
				gson.toJson(false, resp.writer)
			}
			
		}catch(Exception e){
			gson.toJson(#[false, e.toString], resp.writer)
		}
	}
	
	override protected doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		var String sessionID = req.session.id
		var workspaceUserPath = Helper.getWorkspaceUserPath(sessionID)
		
		resp.status = HttpServletResponse.SC_OK
		resp.setHeader('Cache-Control', 'no-cache')
		resp.contentType = 'text/x-json'
		var String folderName = req.getParameter("filename").replace(".zip","").trim
		var String srcZip =  workspaceUserPath + "/reverse" + "/" + folderName + "/" + folderName + ".zip"
		var File createScr = new File(workspaceUserPath +"/reverse"+ "/" + folderName);
		if(!createScr.exists)
		createScr.mkdirs
		var String path = writeZip(srcZip,req.inputStream)
		println(folderName);
		decompress(path, workspaceUserPath, folderName)
		var File deleteSrc = new File (srcZip) 
		deleteSrc.delete
		val gson = new Gson
		gson.toJson(true, resp.writer)
	}
	
	def String writeZip(String filename, ServletInputStream stream) {
		try{
		var OutputStream out = new FileOutputStream(filename)
		var byte[] buffer = newByteArrayOfSize(16384);
            var int bytesRead;
            //read from is to buffer
            while((bytesRead = stream.read(buffer)) !=-1){
                out.write(buffer, 0, bytesRead);
            }
            stream.close();
            //flush OutputStream to write any buffered data to file
            out.flush();
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
		return filename
	}
	
	private def boolean decompress(String zipIn, String workspaceUserPath, String folderName){
		var String reverse = workspaceUserPath + "/reverse" + "/" +folderName 
		var ZipFile zipFile = new ZipFile(zipIn);
	       var Enumeration<? extends ZipEntry> entries = zipFile.entries()
		
		var File dest = new File(reverse)
		if(!dest.exists){
			dest.mkdir
		}
		var byte[] buffer = newByteArrayOfSize(16384);
	       var  int len;
		
		while(entries.hasMoreElements){
		var ZipEntry entry = entries.nextElement() as ZipEntry;
		var String entryFileName = entry.getName();
	           var File dir  = buildDirectoryHierarchyFor(entryFileName, dest);
	            if (!dir.exists()) {
	                dir.mkdirs();
	            }
	 
	            if (!entry.isDirectory()) {
	              var  BufferedOutputStream bos = new BufferedOutputStream(
	                        new FileOutputStream(new File(dest, entryFileName)));
	 
	               var BufferedInputStream bis = new BufferedInputStream(zipFile
	                        .getInputStream(entry));
	 
	                while ((len = bis.read(buffer)) > 0) {
	                    bos.write(buffer, 0, len);
	                }
	 
	                bos.flush();
	                bos.close();
	                bis.close();
	            }
	        }
	            zipFile.close();
	 
	    

        return true;
	}
	    /**
 *  build a new File name
 * 
 * @param String entryName
 * @param File destDir
 * return File
 */
	    def File buildDirectoryHierarchyFor(String entryName, File destDir) {
	      var  int lastIndex = entryName.lastIndexOf('/');
	      var  String entryFileName = entryName.substring(lastIndex + 1);
	      var  String internalPathToEntry = entryName.substring(0, lastIndex + 1);
	        return new File(destDir, internalPathToEntry);
	    }
	

	def boolean checkCookies(Cookie[] cookies) {
		var boolean havename = false;
		var boolean haveemail = false
		for(Cookie cook: cookies){
			if(cook.name == "joomddusername" && cook.value != null)
			 havename = true
			 if(cook.name == "joomddemail" && cook.value != null)
			 haveemail = true
		}
		return havename && haveemail
	}
	
}