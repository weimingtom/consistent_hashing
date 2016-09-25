package
{
	//
	//¹Ù·½SDK
	//corelib
	//see also:http://labs.adobe.com/wiki/index.php/ActionScript_3:resources:apis:libraries#corelib
	//
	import com.adobe.crypto.*;
	
	/**  
	 * Uses CRC32 to hash a value into a 32bit binary string data address space.  
	 *  
	 * @author Paul Annesley  
	 * @package Flexihash  
	 * @licence http://www.opensource.org/licenses/mit-license.php  
	 */  
	public class Flexihash_Md5Hasher implements Flexihash_Hasher   
	{   
	  
		/* (non-phpdoc)  
		 * @see Flexihash_Hasher::hash()  
		 */  
		public function hash(str:String):String  
		{   
			return MD5.hash(str); 
		}   
	}
}

	