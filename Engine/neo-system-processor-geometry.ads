with Ada.Numerics.Generic_Complex_Types;
with Ada.Numerics.Generic_Real_Arrays;
with Ada.Numerics.Generic_Complex_Arrays;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Numerics.Generic_Complex_Elementary_Functions;
package Neo.System.Processor.Geometry is
  type Record_Coordinate_2D_Degree is record
      X : Float_8_Degree := 0.0;
      Y : Float_8_Degree := 0.0;
    end record;
  type Record_Coordinate_2D is record
      X : Float_8_Real := 0.0;
      Y : Float_8_Real := 0.0;
    end record;
  type Record_Coordinate_3D is record
      x : Float_8_Real := 0.0;
      Y : Float_8_Real := 0.0;
      Z : Float_8_Real := 0.0;
    end record;
  type Record_Quaternion is record
      x : Float_8_Real := 0.0;
      Y : Float_8_Real := 0.0;
      Z : Float_8_Real := 0.0;
      W : Float_8_Real := 0.0;
    end record;
  type Array_Record_Coordinate_2D is array(Integer_4_Positive range <>) of Record_Coordinate_2D;
  type Array_Record_Coordinate_3D is array(Integer_4_Positive range <>) of Record_Coordinate_3D;
  type Array_Record_Quaternion    is array(Integer_4_Positive range <>) of Record_Quaternion;
  package Vector_Record_Coordinate_2D is new Vectors(Record_Coordinate_2D);
  package Vector_Record_Coordinate_3D is new Vectors(Record_Coordinate_3D);
  package Vector_Record_Quaternion is new Vectors(Record_Quaternion);
  function To_Quaternion(Coordinate : in Record_Coordinate_3D) return Record_Quaternion;
end Neo.System.Processor.Geometry;
-- with
--   Ada.Numerics.Generic_Complex_Types;
--   Ada.Numerics.Generic_Real_Arrays;
--   Ada.Numerics.Generic_Complex_Arrays;
--   Ada.Numerics.Generic_Elementary_Functions;
--   Ada.Numerics.Generic_Complex_Elementary_Functions;
--   System;
-- use
--   System;
-- package Neo.System.Processor.Geometry
--   is
--   ------------------
--   -- Enumerations --
--   ------------------
-- --- btDispatcher uses these types
-- --- IMPORTANT NOTE:The types are ordered polyhedral, implicit convex and concave
-- --- to facilitate type checking
-- --- CUSTOM_POLYHEDRAL_SHAPE_TYPE,CUSTOM_CONVEX_SHAPE_TYPE and CUSTOM_CONCAVE_SHAPE_TYPE can be used to extend Bullet without modifying source code
-- --  enum BroadphaseNativeTypes
-- --  {
-- --  --concave shapes
-- --  CONCAVE_SHAPES_START_HERE,
-- --          --keep all the convex shapetype below here, for the check IsConvexShape in broadphase proxy!
-- --          TRIANGLE_MESH_SHAPE_PROXYTYPE,
-- --          SCALED_TRIANGLE_MESH_SHAPE_PROXYTYPE,
-- --          -- used for demo integration FAST/Swift collision library and Bullet
-- --          FAST_CONCAVE_MESH_PROXYTYPE,
-- --          --terrain
-- --          TERRAIN_SHAPE_PROXYTYPE,
-- --  -- Used for GIMPACT Trimesh integration
-- --          GIMPACT_SHAPE_PROXYTYPE,
-- --  -- Multimaterial mesh
-- --      MULTIMATERIAL_TRIANGLE_MESH_PROXYTYPE,
-- --
-- --          EMPTY_SHAPE_PROXYTYPE,
-- --          STATIC_PLANE_PROXYTYPE,
-- --          CUSTOM_CONCAVE_SHAPE_TYPE,
-- --  CONCAVE_SHAPES_END_HERE,
-- --
-- --
-- --          COMPOUND_SHAPE_PROXYTYPE,
-- --          SOFTBODY_SHAPE_PROXYTYPE,
-- --          HFFLUID_SHAPE_PROXYTYPE,
-- --          HFFLUID_BUOYANT_CONVEX_SHAPE_PROXYTYPE,
-- --          INVALID_SHAPE_PROXYTYPE,
-- --          MAX_BROADPHASE_COLLISION_TYPES
--     type Enumerated_Stride
--       is(
--       Vertex_Stride,
--       Material_Stride);
--     type Enumerated_Shape
--       is(
--       Concave_Shape,
--       Convex_Shape);
--     type Enumerated_Shape_Convex
--       is(
--       Surface_Convex,
--       Sphere_Convex,
--       Box_Convex,
--       Winding_Convex);
--     type Enumerated_Shape_Concave
--       is(
--       Plane_Concave,
--       Mesh_Winding_Concave);
--     type Enumerated_Body
--       is(
--       Rigid_Broad_Body,
--       Rigid_Narrow_Body,
--       Soft_Body);
--   ---------------
--   -- Constants --
--   ---------------
--   --------------
--   -- Packages --
--   --------------
--     package Numeric_Real
--       is new Ada.Numerics.Generic_Elementary_Functions(Real);
--     package Numeric_Complex
--       is new Ada.Numerics.Generic_Complex_Elementary_Functions(Complex_Types);
--   ------------
--   -- Arrays --
--   ------------
--     type Array_Real_Vector
--       is array(Integer_4_Signed range <>)
--       of Real'Base;
--     type Array_Real_Matrix
--       is array(Integer_4_Signed range <>, Integer_4_Signed range <>)
--       of Real'Base;
--     type Array_Complex_Vector
--       is array(Integer_4_Signed range <>)
--       of Complex;
--     type Array_Complex_Matrix
--       is array(Integer_4_Signed range <>, Integer_4_Signed range <>)
--       of Complex;
--     type Array_Integer_Vector
--       is array(Integer_4_Signed range <>)
--       of Integer_4_Signed;
--     type Array_Integer_Matrix
--       is array(Integer_4_Signed range <>, Integer_4_Signed range <>)
--       of Integer_4_Signed;
--     type Array_Boolean_Vector
--       is array(Integer_4_Signed range <>)
--       of Boolean;
--     type Array_Boolean_Matrix
--       is array(Integer_4_Signed range <>, Integer_4_Signed range <>)
--       of Boolean;
--     type Array_Plucker_Coordinate
--       is array(1..2, 1..3)
--       of ;
--   -------------
--   -- Records --
--   -------------
--     type Record_Stride(
--       Stride : Enumerated_Stride)
--       is new Ada.Finalization.Controlled
--       with record
--         case Stride is
--           when Vertex_Stride =>
--           when Material_Stride =>
--         end case;
--       end record;
--     type Record_Shape(
--       Kind : Enumerated_Shape)
--       is new Ada.Finalization.Controlled
--       with record
--         case Kind is
--           when Concave_Shape =>
--           when Convex_Shape =>
--         end case;
--       end record;
--     type Record_Convex_Hull(
--       Kind : Enumerated_Shape_Convex)
--       is new Ada.Finalization.Controlled
--       with record
--         Shape : Record_Shape(Convex_Shape);
--         case Kind is
--           when Plane_Convex =>
--           when Sphere_Convex =>
--           when Cone_Convex =>
--           when Capsule_Convex =>
--           when Cylinder_Convex =>
--           when Mesh_Box_Convex | Mesh_Winding_Convex =>
--             case Kind is
--               when Mesh_Box_Convex =>
--               when Mesh_Winding_Convex =>
--               when others =>
--                 null;
--             end case;
--         end case;
--       end record;
--     type Record_Concave_Hull(
--       Kind : Enumerated_Shape_Concave)
--       is new Ada.Finalization.Controlled
--       with record
--         Shape : Record_Shape(Concave_Shape);
--         case Kind is
--           when Plane_Concave =>
--           when Mesh_Winding_Concave =>
--         end case;
--       end record;
--     type Record_Body(
--       Kind : Enumerated_Body)
--       is new Ada.Finalization.Controlled
--       with record
--         case Kind is
--           when Rigid_Broad_Body | Rigid_Narrow_Body =>
--             case Kind is
--               when Rigid_Broad_Body =>
--                 void*   m_clientObject;
--                 short int m_collisionFilterGroup;
--                 short int m_collisionFilterMask;
--                 void*   m_multiSapParentProxy;
--                 Maximum : Array_Real_Vector(1..3);
--                 Minimum : Array_Real_Vector(1..3);
--               when Rigid_Narrow_Body =>
--             end case;
--           when Soft_Body =>
--         end case;
--       end record;
--   -----------------
--   -- Subprograms --
--   -----------------
--     procedure Test;
-- -------
-- private
-- -------
--   --------------
--   -- Packages --
--   --------------
--     package Import
--       is
--       end Import;
