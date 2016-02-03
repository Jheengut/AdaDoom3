separate(Neo.File.Model) package body Id_Tech is
  type Record_Internal_Joint is record
      Name     : String_2_Unbounded   := NULL_STRING_2_UNBOUNDED;
      Parent   : Integer_4_Signed     := -2;
      Position : Record_Coordinate_3D := (others => <>);
      Rotation : Record_Quaternion    := (others => <>);
    end record;
  package Vector_Record_Internal_Joint is new Vectors(Record_Internal_Joint);
  use Vector_Record_Internal_Joint.Unprotected;
  use Tree_Record_Animation_Joint.Unprotected;
  function Build_Skeleton(Joints : in out Vector_Record_Internal_Joint.Unprotected.Vector) return Tree_Record_Animation_Joint.Unprotected.Tree is
    Skeleton : Tree_Record_Animation_Joint.Unprotected.Tree;
    begin
      for Joint of Joints loop
        null;--if Joint.Parent = 0 then Append_Child(Skeleton, Skeleton.Root, Joint.Data, Joint.Index);
        --else Skeleton.Append_Child(Joints.Element(Joint.Parent).Index, Joint.Data, Joint.Index); end if;
      end loop;
      return Skeleton;
    end Build_Skeleton;
  function Load(Name : in String_2) return Record_Mesh is
    type Record_Internal_Vertex is record 
        Texture      : Record_Coordinate_2D := (others => <>);
        Index        : Integer_4_Natural    := 0;
        Weight_Start : Integer_4_Natural    := 0;
        Weight_Count : Integer_4_Natural    := 0;
      end record;
    package Map_Record_Internal_Vertex is new Ordered_Maps(Integer_4_Natural, Record_Internal_Vertex);
    type Record_Internal_Weight is record
        Joint    : Integer_4_Natural    := 0;
        Amount   : Integer_4_Natural    := 0;
        Position : Record_Coordinate_3D := (others => <>);
      end record;
    package Vector_Record_Internal_Weight is new Vectors(Record_Internal_Weight);
    type Record_Internal_Surface is record
        Shader    : String_2_Unbounded := NULL_STRING_2_UNBOUNDED;
        Weights   : Vector_Record_Internal_Weight.Unprotected.Vector;
        Vertices  : Map_Record_Internal_Vertex.Unprotected.Map;
        Triangles : Vector_Record_Coordinate_3D.Unprotected.Vector;
      end record;
    package Vector_Record_Internal_Surface is new Vectors(Record_Internal_Surface);
    Mesh_Surfaces : Vector_Record_Mesh_Surface.Unprotected.Vector;
    Surfaces      : Vector_Record_Internal_Surface.Unprotected.Vector;
    Joints        : Vector_Record_Internal_Joint.Unprotected.Vector;
    Weights       : Vector_Record_Internal_Weight.Unprotected.Vector;
    Vertex        : Record_Internal_Vertex  := (others => <>);
    Surface       : Record_Internal_Surface := (others => <>);
    Weight        : Record_Internal_Weight  := (others => <>);
    Joint         : Record_Internal_Joint   := (others => <>);
    Shape         : Record_Mesh_Vertex      := (True, others => <>);
    Mesh          : Record_Mesh             := (True, others => <>);
    package Mesh_Parser is new Parser(Name, "//", ("/*", "*/"));
    use Mesh_Parser;
    begin
      Assert("MD5Version");  Skip;
      Assert("commandline"); Skip_Set("""", """");
      Assert("numJoints");   Skip;
      Assert("numMeshes");   Skip;
      Assert("joints"); Assert("{"); while Peek /= "}" loop
        Joint.Name   := Next_Set("""", """");
        Joint.Parent := Integer_4_Signed(Next_Number);
        Assert("("); Joint.Position := (Next_Number, Next_Number, Next_Number);                Assert(")");
        Assert("("); Joint.Rotation := To_Quaternion((Next_Number, Next_Number, Next_Number)); Assert(")");
        Joints.Append(Joint);
      end loop; Skip;
      while not At_End loop
        Assert("mesh"); Assert("{");
        Assert("shader"); Surface.Shader := Next_Set("""", """");
        Assert("numverts"); Skip; while Peek = "vert" loop Skip;
          Vertex.Index        := Integer_4_Natural(Next_Number);
          Assert("("); Vertex.Texture := (Next_Number, Next_Number); Assert(")");
          Vertex.Weight_Count := Integer_4_Natural(Next_Number);
          Vertex.Weight_Start := Integer_4_Natural(Next_Number);
          Surface.Vertices.Insert(Vertex.Index, Vertex);
        end loop; 
        Assert("numtris"); Skip; while Peek = "tri" loop Skip(2);
          Surface.Triangles.Append((Next_Number, Next_Number, Next_Number));
        end loop; 
        Assert("numweights"); Skip; while Peek = "weight" loop Skip(2);
          Weight.Joint  := Integer_4_Natural(Next_Number);
          Weight.Amount := Integer_4_Natural(Next_Number);
          Assert("("); Weight.Position := (Next_Number, Next_Number, Next_Number); Assert(")");
          Surface.Weights.Append(Weight);
        end loop;
        Assert("}");
        Surfaces.Append(Surface);
        Surface.Vertices.Clear;
        Surface.Triangles.Clear;
        Surface.Weights.Clear;
      end loop;
      for Surface of Surfaces loop
        for Triangle of Surface.Triangles loop
           for J in Surface.Vertices.Element(I).Weight_Start..Surface.Vertices.Element(I).Weight_Start + Surface.Vertices.Element(I).Weight_Count loop
             Weights.Append((Surface.Weights.Element(J).Amount, Surface.Weights.Element(J).Position, Joints.Element(Surface.Weights.Element(J).Joint).Name));
           end loop;
           Shape.Insert(I, (True, Surface.Vertices.Element(I).Texture, Weights)); 
            Weights.Clear;
         Mesh_Surfaces.Append(Shape);
        end loop;
       Mesh.Surfaces.Append((Surface.Material, Mesh_Surfaces));
        Mesh_Surfaces.Clear;
      end loop;
      Mesh.Skeleton := Build_Skeleton(Joints);
      --Mesh.Bounds   := Build_Bounds(Weigh_Surfaces(Mesh.Skeleton, Mesh.Surfaces));
      return Mesh;
    end Load;
  procedure Save(Name : in String_2; Item : in Record_Mesh) is
    begin 
      null;
    end Save;
  function Load(Name : in String_2) return Record_Animation is
    type Record_Internal_Base_Frame_Joints(Flags : Integer_1_Unsigned := 0) is record
        Joint          : Record_Internal_Joint := (others => <>);
        Start_Index    : Integer_4_Positive    := 1;
        Has_Position_X : Boolean               := (Flags and 16#01#) > 0;
        Has_Position_Y : Boolean               := (Flags and 16#02#) > 0;
        Has_Position_Z : Boolean               := (Flags and 16#04#) > 0;
        Has_Rotation_X : Boolean               := (Flags and 16#08#) > 0;
        Has_Rotation_Y : Boolean               := (Flags and 16#0F#) > 0;
        Has_Rotation_Z : Boolean               := (Flags and 16#10#) > 0;
      end record;
    package Vector_Record_Internal_Base_Frame_Joints is new Vectors(Record_Internal_Base_Frame_Joints);
    type Record_Internal_Bound is record
        Minimum : Record_Coordinate_3D := (others => <>);
        Maximum : Record_Coordinate_3D := (others => <>);
      end record;
    package Vector_Record_Internal_Bound is new Vectors(Record_Internal_Bound);
    Base_Frame_Joints : Vector_Record_Internal_Base_Frame_Joints.Unprotected.Vector;
    Frame_Data        : Vector_Float_4_Real.Unprotected.Vector;
    Animation         : Record_Animation := (others => <>);
    begin
      Assert("MD5Version");            Skip;
      Assert("commandline");           Skip_Set("""", """");
      Assert("numFrames");             Skip;
      Assert("numJoints");             Skip;
      Assert("frameRate");             Animation.Frame_Rate := Next;
      Assert("numAnimatedComponents"); Skip;
      Assert("hierarchy"); Assert("{"); while Peek /= "}" loop
        Base_Frame_Joints.Append((
          Data        => (Next_Set("""", """"), Next, others => <>),
          Flags       => Integer_1_Unsigned(Next_Number),
          Start_Index => Integer_4_Positive(Next_Number)));
      end loop; Skip;
      Assert("bounds", "{"); while Peek /= "}" loop
        Assert("("); Bounds.Minimum := (Next_Number, Next_Number, Next_Number); Assert(")");
        Assert("("); Bounds.Maximum := (Next_Number, Next_Number, Next_Number); Assert(")");
        Animation.Frames.Append(Bounds => Bounds, others => <>);
      end loop; Skip;
      Assert("baseframe", "{"); for Joint in Base_Frame_Joints loop exit when Peek /= "}";
        Assert("("); Joint.Data.Position := (Next_Number, Next_Number, Next_Number);      Assert(")");
        Assert("("); Joint.Data.Rotation := (Next_Number, Next_Number, Next_Number, 0.0); Assert(")"); -- At this point W still needs computation
      end loop; Skip;
      while not At_End loop
        Assert("frame"); while Peek /= "}" loop Frame_Data.Append(Next); end loop; Skip;
        for Frame of Animation.Frames loop
          if Frame.Has_Position_X then Joint.Position(I) := Frame_Data.Element(Frame.Index); Frame.Index := Frame.Index + 1; end if;
          if Frame.Has_Position_Y then Joint.Position(I) := Frame_Data.Element(Frame.Index); Frame.Index := Frame.Index + 1; end if;
          if Frame.Has_Position_Z then Joint.Position(I) := Frame_Data.Element(Frame.Index); Frame.Index := Frame.Index + 1; end if;
          if Frame.Has_Rotation_X then Joint.Position(I) := Frame_Data.Element(Frame.Index); Frame.Index := Frame.Index + 1; end if;
          if Frame.Has_Rotation_Z then Joint.Position(I) := Frame_Data.Element(Frame.Index); Frame.Index := Frame.Index + 1; end if;
          if Frame.Has_Rotation_Y then Joint.Position(I) := Frame_Data.Element(Frame.Index); Frame.Index := Frame.Index + 1; end if;
        end loop;
        Animation.Frames.Append(Build_Skeleton(Joints));
      end loop;
      return Animation;
    end Load;
  function Load(Name : in String_2) return Record_Map is
    Map : Record_Map := (others => <>);
    begin
      declare
      package Collision_Model_Parser is new Parser(Name, "//"); use Collision_Model_Parser;
      begin
        Assert("CM"); Skip_Set("""", """");
        Assert(Map.CRC = Integer_8_Unsigned(Next_Number));
        while not At_End loop
          Assert("collisionModel");
          Section.Name := Next_Set("""", """");
          Assert("{");
          while Peek /= "}" loop
            Assert("vertices"); Assert("{"); Skip;
            while Peek /= "}" loop
              Assert("("); Section.Vertices.Append(Next_Number, Next_Number, Next_Number); Assert(")");
            end loop;
            Skip;
            Assert("edges"); Assert("{"); Skip;
            while Peek /= "}" loop
              Assert("("); Edge.Vertex := (Integer_4_Natural(Next_Number), Integer_4_Natural(Next_Number)); Assert(")");
              Edge.Internal        := Integer_4_Natural(Next_Number);
              Edge.Number_Of_Users := Integer_4_Natural(Next_Number);
              Surface.Edges.Append(Edge);
            end loop;
            Skip;
            Assert("nodes"); Assert("{"); Skip;
            while Peek /= "}" loop
              Assert("("); Surface.Nodes.Append((Integer_4_Natural(Next_Number), Next_Number)); Assert(")");
            end loop;
            Skip;
            Assert("polygons"); Skip; Assert("{");
            while Peek /= "}" loop
              Skip;
              Assert("(");
              while Peek /= ")" loop Polygon.Edges.Append(Integer_4_Signed(Next_Number)); end loop;
              Assert("("); Polygon.Normal := (Next_Number, Next_Number, Next_Number); Assert(")");
              Polygon.Distance := Next_Number;
              Assert("("); Polygon.Minimum := (Next_Number, Next_Number, Next_Number); Assert(")");
              Assert("("); Polygon.Maximum := (Next_Number, Next_Number, Next_Number); Assert(")");
              Polygon.Material := Next_Set("""", """");
              Map.Polygons.Append(Polygon); -- Add to tree?
            end loop;
            Skip;
            Assert("brushes"); Skip; Assert("{");
            while Peek /= "}" loop
              Skip;
              Assert("{");
              while Peek /= "}" loop
                Assert("("); Plane.Normal := ((Next_Number, Next_Number, Next_Number)); Assert(")");
                Plane.Distance := Next_Number;
                Brush.Normals.Append(Plane);
              end loop;
              Assert("("); Brush.Minimum := (Next_Number, Next_Number, Next_Number); Assert(")");
              Assert("("); Brush.Maximum := (Next_Number, Next_Number, Next_Number); Assert(")");
              for Content of Split(Next_Set("""", """"), ",") loop
                if    Content = "solid"  then Brush.Is_Solid := True;
                elsif Content = "opaque" then Brush.Is_Opaque := True;
                elsif Content = "" then Brush. := True;
                elsif Content = "" then Brush. := True;
                end if;
              end loop;
              Skip;
              Map.Brushes.Append(Brush);
            end loop;
            Skip;
          end loop;
          Skip;
        end;
        declare
        package Map_Entity_Parser is new Parser(Name, "//");
        begin
          Assert("Version"); Skip;
          while not At_End loop
            Assert("{");
            while Peek /= "}" loop
              Token := Next_Set("""", """");
              if Token = "classname" then
                Token := Next_Set("""", """");
                if Token = "" then
                end if;
              elsif Token = "origin" then
              end if;
            end loop;
          end loop;
        
        
        
        
        
        
        Data.Assert_Next("Version");
        Entity.Version := Integer'wide_value(Data.Next);
        while not Is_End(Data) loop 
          Data.Assert_Next("{");
          Token := Data.Next;
          while Token /= "}" loop
            if Token /= "{" then
              Token := Trim(Token, """", Both);
              if Token = "origin" then
                Origin := (Float_4_Real'wide_value(Data.Next), Float_4_Real'wide_value(Data.Next), Float_4_Real'wide_value(Data.Next));
              elsif Token = "classname" then
                Token := Data.Next;
                if Token = "worldspawn" then
                  Origin := (others => 0.0);
                  Entity.Values.Add("classname", "worldspawn"); 
                else
                  Entity.Values.Add("classname", Token); 
                end if;
              else
                Entity.Values.Add(Token, Data.Next);
              end if;
            else
              Token := Data.Next;
              if Token = "brush" then
                Map.Brushes.Add;
                Data.Assert_Next("{");
                Token := Data.Next;
                while Token /= "}" loop
                  while Token /= "(" loop
                    Map.Brushes.Last.Values.Add(Token, Data.Next);
                    Token := Data.Next;
                  end loop;
                  Token := Data.Next;
                  Map.Brushes.Last.Sides.Add((
                    Plane    => (if Token = "brushDef2" or Token = "brushDef3" then Data.Next_Vector(4)
                                 else Plane_From_Points(Data.Next_Vector(3), Data.Next_Vector(3), Data.Next_Vector(3), Origin)),
                    Texture  => Data.Next_Matrix(2, 3),
                    Origin   => Origin,
                    Material => (if Version < 2.0 then "textures/" else "") & Data.Next_File_Name));
                  Data.Skip_Line; -- Quake II allows override of default flags and values, but it is not needed anymore so skip it
                  Token := Data.Next;
                end loop;
              elsif Token = "patch" then -- "These were written out in the wrong order, IMHO"
                Token := Data.Next_Path;
                Map.Patches.Add(new Record_Patch(Data.Next = "patchDef3", Data.Next, Data.Next));
                Map.Patches.Last.Material := (if Version < 2.0 then "textures/" else "") & Token;
                Data.Assert_Next("(");
                if Map.Patches.Last.Is_Explicityly_Subdivided then
                  Map.Patches.Last.Subdivisions := (Data.Next, Data.Next);
                end if;
                Map.Patches.Last.Random_Information := Data.Next_Array_Integer(3);
                Data.Assert_Next((")", "("));
                for Vertex_Group of Map.Patches.Last.Vertices loop -- "vert = &((*patch)[i * patch->GetWidth + j]);"
                  Data.Assert_Next("(");
                  for Vertex of Vertex_Group loop
                    Data.Assert_Next("(");
                    Vertex := (Location => Data.Next_Array_Float(3) - Origin, Texture => Data.Next_Array_Float(2));
                    Data.Assert_Next(")");
                  end loop;
                  Data.Assert_Next(")");
                end loop;
                Token := Data.Next;
                while Token /= "}" loop
                  Map.Patches.Last.Values.Add(Token, Data.Next);
                  Token := Token.Next;
                end loop;
                Data.Assert_Next("}");
              else -- Assume it is a Quake III brush
                Map.Brushes.Add;
                Token := Data.Next;
                while Token /= "}" loop
                  Map.Brushes.Last.Sides.Add((
                    Plane    => Plane_From_Points(Data.Next_Vector(3), Data.Next_Vector(3), Data.Next_Vector(3), Origin),
                    Material => "textures/" & Data.Next,
                    Texture  => ((0.03125, 0.0, 0.0), (0.0, 0.03125, 0.0)),
                    Origin   => Origin));
                  Data.Skip(5); -- Apparently shift, rotate, and scale are ignored
                  Data.Skip_Line;
                end loop;
              end if;
            end if;
            Token := Data.Next;
          end loop;
        end loop;
        for Entity of Map.Entities loop
          for Primitive of Entity.Primitives loop
            for Side of Primitive.Sides loop
              Map.Geometry_Checksum :=
                Map.Geometry_Checksum xor 
                Side.Plane(1) xor
                Side.Plane(2) xor
                Side.Plane(3);
            end loop;
            Map.Geometry_Checksum := Map.Geometry_Checksum xor Side.Material;
          end loop;
          if Entity.Values.Element("classname") = "worldspawn" then
            --Number_Of_Worlds > 1;
            Number_Of_Worlds := Number_Of_Worlds + 1;
            if Entity.Values.Has_Element("removeEntities") then
              while
                const idKeyValue *removeEntities = entities[0]->epairs.MatchPrefix("removeEntities", NULL);
              end loop;
            end if;
            if Entity.Values.Has_Element("overrideMaterial") then
              for Overriden_Entity of Map.Entities loop
                for Primitive of Overriden_Entity loop
                  case Primitive.Kind is
                    when Brush_Primitive => for Side of Primitive.Sides loop Side.Material := Entity.Values.Element("overrideMaterial"); end loop;
                    when Patch_Primitive => Primitive.Material := Entity.Values.Element("overrideMaterial");
                  end case;
                end loop;
              end loop;
            end if;
            if Entity.Values.Has_Element("moveFuncGroups") then
              for Overriden_Entity of Map.Entities loop
                if Overriden.Entity.Element("classname") = "func_group" then
                  Entity.Primitives.Add(Overriden_Entity.Primitives);
                  Overriden_Entity.Primitives.Delete;
                end if;
              end loop;
            end if;
          end if;
        end loop;
          -- load it
          filename = name;
          filename.SetFileExtension(PROC_FILE_EXT);
          src = new (TAG_COLLISION) idLexer(filename, LEXFL_NOSTRINGCONCAT | LEXFL_NODOLLARPRECOMPILE);
          if (!src->IsLoaded 
            common->Warning("idCollisionModelManagerLocal::LoadProcBSP: couldn't load %s", filename.c_str);
            delete src;
            return;
          }
          if (!src->ReadToken(&token) || token.Icmp(PROC_FILE_ID) 
            common->Warning("idCollisionModelManagerLocal::LoadProcBSP: bad id '%s' instead of '%s'", token.c_str, PROC_FILE_ID);
            delete src;
            return;
          }
          -- parse the file
          while (1 
            if (!src->ReadToken(&token) 
              break;
            }
            if (token == "model" | == "shadowModel" | token == "interAreaPortals" 
              idToken token;
              int depth;

              depth = parseFirstBrace ? 0 : 1;
              do {
                if (!ReadToken(&token) 
                  return false;
                }
                if (token.type == TT_PUNCTUATION 
                  if (token == "{" 
                    depth++;
                  } else if (token == "}" 
                    depth--;
                  }
                }
              } while(depth);
              continue;
            }
            if (token == "nodes" 
              src->ExpectTokenString("{");
              numProcNodes = src->ParseInt;
              if (numProcNodes < 0 
                src->Error("ParseProcNodes: bad numProcNodes");
              }
              procNodes = (cm_procNode_t *)Mem_ClearedAlloc(numProcNodes * sizeof(cm_procNode_t), TAG_COLLISION);
              for (i = 0; i < numProcNodes; i++ 
                cm_procNode_t *node;
                node = &procNodes[i];
                src->Parse1DMatrix(4, node->plane.ToFloatPtr);
                if (!idLexer::ExpectTokenString("(") 
                  return false;
                }

                for (i = 0; i < x; i++ 
                  m[i] = idLexer::ParseFloat;
                }

                if (!idLexer::ExpectTokenString(")") 
                  return false;
                }
                return true;
                node->children[0] = src->ParseInt;
                node->children[1] = src->ParseInt;
              }
              src->ExpectTokenString("}");
              break;
            }
            src->Error("idCollisionModelManagerLocal::LoadProcBSP: bad token \"%s\"", token.c_str);
          }
          -- convert brushes and patches to collision data
          for (i = 0; i < mapFile->GetNumEntities; i++ 
            mapEnt = mapFile->GetEntity(i);
            if (numModels >= MAX_SUBMODELS 
              common->Error("idCollisionModelManagerLocal::BuildModels: more than %d collision models", MAX_SUBMODELS);
              break;
            }
            models[numModels] = CollisionModelForMapEntity(mapEnt);
            if (models[ numModels] 
              numModels++;
            }
          }
          -- free the proc bsp which is only used for data optimization
          Mem_Free(procNodes);
          procNodes = NULL;
          -- write the collision models to a file
          WriteCollisionModelsToFile(mapFile->GetName, 0, numModels, mapFile->GetGeometryCRC);
        } 
        idLexer src(LEXFL_NOFATALERRORS | LEXFL_NOSTRINGESCAPECHARS | LEXFL_NOSTRINGCONCAT | LEXFL_ALLOWPATHNAMES);
        idToken token;
        int depth;
        unsigned int c;
      end loop;
      -- calculate edge normals
      --checkCount++;
      --CalculateEdgeNormals(model, model->node);
      -- get model bounds from brush and polygon bounds
      --CM_GetNodeBounds(&model->bounds, model->node);
      -- get model contents
      --model->contents = CM_GetNodeContents(model->node);
    end Load;
end Id_Tech;
  
