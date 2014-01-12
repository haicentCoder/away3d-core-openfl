package away3d.core.base;

	//import away3d.arcane;
	import away3d.events.GeometryEvent;
	import away3d.library.assets.AssetType;
	import away3d.library.assets.IAsset;
	import away3d.library.assets.NamedAssetBase;
	
	import away3d.geom.Matrix3D;
	
	//use namespace arcane;
	
	/**
	 * Geometry is a collection of SubGeometries, each of which contain the actual geometrical data such as vertices,
	 * normals, uvs, etc. It also contains a reference to an animation class, which defines how the geometry moves.
	 * A Geometry object is assigned to a Mesh, a scene graph occurence of the geometry, which in turn assigns
	 * the SubGeometries to its respective SubMesh objects.
	 *
	 *
	 *
	 * @see away3d.core.base.SubGeometry
	 * @see away3d.scenegraph.Mesh
	 */
	class Geometry extends NamedAssetBase implements IAsset
	{
		var _subGeometries:Array<ISubGeometry>;
		
		public var assetType(get, null) : String;
		
		public function get_assetType() : String
		{
			return AssetType.GEOMETRY;
		}
		
		/**
		 * A collection of SubGeometry objects, each of which contain geometrical data such as vertices, normals, etc.
		 */
		public var subGeometries(get, null) : Array<ISubGeometry>;
		public function get_subGeometries() : Array<ISubGeometry>
		{
			return _subGeometries;
		}
		
		/**
		 * Creates a new Geometry object.
		 */
		public function new()
		{
			super();
			_subGeometries = new Array<ISubGeometry>();
		}
		
		public function applyTransformation(transform:Matrix3D):Void
		{
			var len:UInt = _subGeometries.length;
			// For loop conversion - 			for (var i:Int = 0; i < len; ++i)
			var i:Int;
			for (i in 0...len)
				_subGeometries[i].applyTransformation(transform);
		}
		
		/**
		 * Adds a new SubGeometry object to the list.
		 * @param subGeometry The SubGeometry object to be added.
		 */
		public function addSubGeometry(subGeometry:ISubGeometry):Void
		{
			_subGeometries.push(subGeometry);
			
			subGeometry.parentGeometry = this;
			if (hasEventListener(GeometryEvent.SUB_GEOMETRY_ADDED))
				dispatchEvent(new GeometryEvent(GeometryEvent.SUB_GEOMETRY_ADDED, subGeometry));
			
			invalidateBounds(subGeometry);
		}
		
		/**
		 * Removes a new SubGeometry object from the list.
		 * @param subGeometry The SubGeometry object to be removed.
		 */
		public function removeSubGeometry(subGeometry:ISubGeometry):Void
		{
			_subGeometries.splice(Lambda.indexOf(_subGeometries, subGeometry), 1);
			subGeometry.parentGeometry = null;
			if (hasEventListener(GeometryEvent.SUB_GEOMETRY_REMOVED))
				dispatchEvent(new GeometryEvent(GeometryEvent.SUB_GEOMETRY_REMOVED, subGeometry));
			
			invalidateBounds(subGeometry);
		}
		
		/**
		 * Clones the geometry.
		 * @return An exact duplicate of the current Geometry object.
		 */
		public function clone():Geometry
		{
			var clone:Geometry = new Geometry();
			var len:UInt = _subGeometries.length;
			// For loop conversion - 			for (var i:Int = 0; i < len; ++i)
			var i:Int;
			for (i in 0...len)
				clone.addSubGeometry(_subGeometries[i].clone());
			return clone;
		}
		
		/**
		 * Scales the geometry.
		 * @param scale The amount by which to scale.
		 */
		public function scale(scale:Float):Void
		{
			var numSubGeoms:UInt = _subGeometries.length;
			// For loop conversion - 			for (var i:UInt = 0; i < numSubGeoms; ++i)
			var i:UInt = 0;
			for (i in 0...numSubGeoms)
				_subGeometries[i].scale(scale);
		}
		
		/**
		 * Clears all resources used by the Geometry object, including SubGeometries.
		 */
		public function dispose():Void
		{
			var numSubGeoms:UInt = _subGeometries.length;
			
			// For loop conversion - 						for (var i:UInt = 0; i < numSubGeoms; ++i)
			
			var i:UInt = 0;
			
			for (i in 0...numSubGeoms) {
				var subGeom:ISubGeometry = _subGeometries[0];
				removeSubGeometry(subGeom);
				subGeom.dispose();
			}
		}
		
		/**
		 * Scales the uv coordinates (tiling)
		 * @param scaleU The amount by which to scale on the u axis. Default is 1;
		 * @param scaleV The amount by which to scale on the v axis. Default is 1;
		 */
		public function scaleUV(scaleU:Float = 1, scaleV:Float = 1):Void
		{
			var numSubGeoms:UInt = _subGeometries.length;
			// For loop conversion - 			for (var i:UInt = 0; i < numSubGeoms; ++i)
			var i:UInt = 0;
			for (i in 0...numSubGeoms)
				_subGeometries[i].scaleUV(scaleU, scaleV);
		}
		
		/**
		 * Updates the SubGeometries so all vertex data is represented in different buffers.
		 * Use this for compatibility with Pixel Bender and PBPickingCollider
		 */
		public function convertToSeparateBuffers():Void
		{
			var subGeom:ISubGeometry;
			var numSubGeoms:Int = _subGeometries.length;
			var _removableCompactSubGeometries:Array<CompactSubGeometry> = new Array<CompactSubGeometry>();
			
			// For loop conversion - 						for (var i:Int = 0; i < numSubGeoms; ++i)
			
			var i:Int;
			
			for (i in 0...numSubGeoms) {
				subGeom = _subGeometries[i];
				if (Std.is(subGeom, SubGeometry))
					continue;
				
				_removableCompactSubGeometries.push(cast(subGeom, CompactSubGeometry));
				addSubGeometry(subGeom.cloneWithSeperateBuffers());
			}
			
			Lambda.foreach(_removableCompactSubGeometries, function (s:CompactSubGeometry):Bool {
				removeSubGeometry(s);
				s.dispose();
				return true;
			});
		}
		
		public function validate():Void
		{
			// To be overridden when necessary
		}
		
		public function invalidateBounds(subGeom:ISubGeometry):Void
		{
			if (hasEventListener(GeometryEvent.BOUNDS_INVALID))
				dispatchEvent(new GeometryEvent(GeometryEvent.BOUNDS_INVALID, subGeom));
		}
	}
