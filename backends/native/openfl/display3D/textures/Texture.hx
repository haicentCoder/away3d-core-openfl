package openfl.display3D.textures;

using openfl.display.BitmapData;
import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.gl.GLFramebuffer;
import openfl.utils.ArrayBuffer;
import openfl.utils.ByteArray;
import openfl.utils.UInt8Array;

class Texture extends TextureBase 
{

	public var optimizeForRenderToTexture:Bool;
	
	public function new(glTexture:GLTexture, optimizeForRenderToTexture:Bool, width : Int, height : Int) {

		super (glTexture, width , height );

		if (optimizeForRenderToTexture) { 
				 
			GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 1); 
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST); 			
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE); 	 
		}  
	}

	public function uploadCompressedTextureFromByteArray(data:ByteArray, byteArrayOffset:Int, async:Bool = false):Void {
		// TODO
	}

	public function uploadFromBitmapData (bitmapData:BitmapData, miplevel:Int = 0):Void {
        #if html5
        var p = bitmapData.getPixels(new openfl.geom.Rectangle(0, 0, bitmapData.width, bitmapData.height));
        #else
        var p = bitmapData.getRGBAPixels();
        #end
		width = bitmapData.width;
        height = bitmapData.height;
        uploadFromByteArray(p, 0, miplevel);
	}

	public function uploadFromByteArray(data:ByteArray, byteArrayOffset:Int, miplevel:Int = 0):Void {
        GL.bindTexture (GL.TEXTURE_2D, glTexture);
		 
		if (optimizeForRenderToTexture) { 
				 
			GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 1); 
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST); 			
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE); 
		 
		}  
        var source : UInt8Array;
        #if html5
        source = new UInt8Array(data.length);
        data.position = byteArrayOffset;
        var i:Int = 0;
        while (data.position < data.length) {
            source[i] = data.readUnsignedByte();
            i++;
        }
        #else
        //TODO byteArrayOffset ?
        source = new UInt8Array(data);
        #end
        GL.texImage2D( GL.TEXTURE_2D, miplevel, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, source );
        GL.bindTexture (GL.TEXTURE_2D, null);
	}
}
