package
{
    import flash.utils.ByteArray;

	public class Flexihash_Crc32Hasher implements Flexihash_Hasher   
	{   
	  
		/* (non-phpdoc)  
		 * @see Flexihash_Hasher::hash()  
		 */  
		public function hash(str:String):String   
		{   
			var ba:ByteArray=new ByteArray();
			ba.writeUTFBytes(str);
			update(ba);
			return(getValue().toString(16));
		}
		
		//
		//�ο���/See also :
		//http://www.cnitblog.com/flashlizi/archive/2007/09/10/33198.html
		//
		/** 
		 * @name:CRC32(CRC32У����)
		 * @usage:����java.util.zip��CRC32��д��AS3��CRC32У����
		 * @author:flashlizi
		 * @update:2007/06/05
		 * @example:
		var crc=new CRC32();
		var ba:ByteArray=new ByteArray();
		var str="123";
		ba.writeUTFBytes(str);
		crc.update(ba,0,3);
		trace(crc.getValue().toString(16).toUpperCase());
		 */
		private var crc32:uint;
		private static  var CRCTable:Array=initCRCTable();
		/** *//** 
		 * @usage ����ָ�����ֽ������CRC32
		 * @param buffer��ָ�����ֽ�����,arg��arg[0]Ϊoffsetƫ������arg[1]Ϊlength
		ָ������
		 * �������ָֻ��һ������buffer��Ҳ����offset,length��ָ��
		 * @return void
		 */
		public function update(buffer:ByteArray, arg0:int = 0, arg1:int = 0):void 
		{
			var offset:int=arg0?arg0:0;
			var length:int=arg1?arg1:buffer.length;
			var crc:uint = ~crc32;
			for (var i:int = offset; i < length; i++) 
			{
				crc = CRCTable[(crc ^ buffer[i]) & 0xFF] ^ (crc >>> 8);
			}
			crc32 = ~crc;
		}
		/** *//** 
		 * @usage 
		 * @param 
		 * @return CRC32ֵ
		 */
		public function getValue():uint {
			return crc32 & 0xFFFFFFFF;
		}
		/** *//** 
		 * @usage ��CRC32����Ϊ��ʼֵ
		 * @param 
		 * @return void
		 */
		public function reset():void {
			crc32 = 0;
		}
		/** *//** 
		 * @usage ��ʼ�� CRC table, ����Ϊ256.
		 * @param crcTable��CRC table
		 * @return ��ʼ����crcTable,ʹ�ñ�׼polyֵ��0xEDB88320
		 */
		private static function initCRCTable():Array {
			var crcTable:Array=new Array(256);
			for (var i:int=0; i < 256; i++) {
				var crc:uint=i;
				for (var j:int=0; j < 8; j++) {
					crc=(crc & 1)?(crc >>> 1) ^ 0xEDB88320:(crc >>> 1);
				}
				crcTable[i]=crc;
			}
			return crcTable;
		}
		

	}   
}	