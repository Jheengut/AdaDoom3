with Neo.OpenGL;              use Neo.OpenGL;
with Ada.Characters.Handling; use Ada.Characters.Handling;
separate(Neo.System.Graphics) package body OpenGL is
  package Import is
      function Get_Extensions return String_1;
      function Load_Function  (Name : in String_1) return Address;
      procedure Initialize    (Monitor : in Integer_4_Positive);
      procedure Finalize      (Monitor : in Integer_4_Positive);
      procedure Swap_Buffers;
    end Import;
  package body Import is separate; use Import;
  Invalid_Enumeration : Exception;
  Invalid_Operation   : Exception;
  Stack_Underflow     : Exception;
  Stack_Overflow      : Exception;
  Invalid_Value       : Exception;
  CONDITIONS : constant array(Enumerated_Condition) of Integer_4_Unsigned_C :=(
    Less_Than_Condition                => GL_LESS,
    Equal_Condition                    => GL_EQUAL,
    Never_Condition                    => GL_NEVER,
    Always_Condition                   => GL_ALWAYS,
    Greater_Than_Condition             => GL_GREATER,
    Not_Equal_Condition                => GL_GREATER,
    Less_Than_Or_Equal_To_Condition    => GL_LEQUAL,
    Greater_Than_Or_Equal_To_Condition => GL_GEQUAL);
  procedure Set_Color_Mask(Do_Mask_Red, Do_Mask_Green, Do_Mask_Blue, Do_Mask_Alpha : in Boolean := True) is
    begin
      Color_Mask(
        Red   => (if Do_Mask_Red   then GL_FALSE else GL_TRUE),
        Green => (if Do_Mask_Green then GL_FALSE else GL_TRUE),
        Blue  => (if Do_Mask_Blue  then GL_FALSE else GL_TRUE),
        Alpha => (if Do_Mask_Alpha then GL_FALSE else GL_TRUE));
    end Set_Color_Mask;
  procedure Scissor(X, Y, Width, Height : in Integer_4_Signed) is
    begin
      Scissor(Integer_4_Signed_C(X), Integer_4_Signed_C(Y), Integer_4_Signed_C(Width), Integer_4_Signed_C(Height));
    end Scissor;
  procedure Reset is
    begin
      Clear_Depth(1.0);
      Cull_Face(GL_FRONT_AND_BACK);
      Enable(GL_CULL_FACE);
      Set_Color_Mask;
      Blend_Function(GL_ONE, GL_ZERO);
      Depth_Mask(GL_TRUE);
      Depth_Function(GL_LESS);
      Disable(GL_STENCIL_TEST);
      Disable(GL_POLYGON_OFFSET_FILL);
      Disable(GL_POLYGON_OFFSET_LINE);
      Polygon_Mode(GL_FRONT_AND_BACK, GL_FILL);
      Shade_Model(GL_SMOOTH);
      Enable(GL_DEPTH_TEST);
      Enable(GL_BLEND);
      Enable(GL_SCISSOR_TEST);
      Draw_Buffer(GL_BACK);
      Read_Buffer(GL_BACK);
      if Do_Scissor.Get then Scissor(0, 0, Width.Get, Height.Get); end if;
    end Reset;
  procedure Initialize(Monitor : in Integer_4_Positive) is
    Extensions           :         String_2_Unbounded := NULL_STRING_2_UNBOUNDED;
    Number_Of_Extensions : aliased Integer_4_Signed_C := 0;
    Maximum_Texture_Size : aliased Float_4_Real_C     := 0.0;
    begin
      Import.Initialize(Monitor);
      Neo.OpenGL.Initialize(Import.Load_Function'access);
      if Monitor = 1 then
        Get_Integer_Value(GL_NUM_EXTENSIONS, Number_Of_Extensions'unchecked_access);
        Get_Float_Value(GL_MAX_TEXTURE_SIZE, Maximum_Texture_Size'unchecked_access);
        for I in 0..Number_Of_Extensions - 1 loop Extensions := Extensions & To_String_2_Unbounded(To_String_2(Get_String_Index(GL_EXTENSIONS, Integer_4_Unsigned_C(I)))); end loop;
        Current_Specifics.Is_Supported                  := True;
        Current_Specifics.Shading_Language              := OpenGL_Shading_Language;
        Current_Specifics.Maximum_Texture_Size          := Integer_4_Positive(Maximum_Texture_Size);
        Current_Specifics.Version                       := Float_4_Real'value(Trim(To_String_1(Get_String(GL_VERSION)), Both)(1..3));
        Current_Specifics.Has_Texture_Compression       := Index(Extensions, "EXT_texture_compression_s3tc")   /= 0 and Index(Extensions, "ARB_texture_compression") /= 0;
        Current_Specifics.Has_Anisotropic_Filter        := Index(Extensions, "EXT_texture_filter_anisotropic") /= 0;
        Current_Specifics.Has_Direct_State_Access       := Index(Extensions, "EXT_direct_state_access")        /= 0;
        Current_Specifics.Has_Depth_Bounds_Test         := Index(Extensions, "EXT_depth_bounds_test")          /= 0;
        Current_Specifics.Has_Sync                      := Index(Extensions, "ARB_sync")                       /= 0;
        Current_Specifics.Has_Timer_Query               := Index(Extensions, "ARB_timer_query")                /= 0;
        Current_Specifics.Has_Multitexture              := Index(Extensions, "ARB_multitexture")               /= 0;
        Current_Specifics.Has_Uniform_Buffer            := Index(Extensions, "ARB_uniform_buffer_object")      /= 0;
        Current_Specifics.Has_Occlusion_Query           := Index(Extensions, "ARB_occlusion_query")            /= 0;
        Current_Specifics.Has_Map_Buffer_Range          := Index(Extensions, "ARB_map_buffer_range")           /= 0;
        Current_Specifics.Has_Seamless_Cube_Map         := Index(Extensions, "ARB_seamless_cube_map")          /= 0;
        Current_Specifics.Has_Vertex_Array_Object       := Index(Extensions, "ARB_vertex_array_object")        /= 0;
        Current_Specifics.Has_Vertex_Buffer_Object      := Index(Extensions, "ARB_vertex_buffer_object")       /= 0;
        Current_Specifics.Has_RGB_Color_Framebuffer     := Index(Extensions, "ARB_framebuffer_sRGB")           /= 0;
        Current_Specifics.Has_Draw_Elements_Base_Vertex := Index(Extensions, "ARB_draw_elements_base_vertex")  /= 0;
        if Current_Specifics.Version < 2.0 then raise Unsupported; end if;
      end if;
      Reset;
    end Initialize;
  procedure Finalize(Monitor : in Integer_4_Positive) is
    begin
      Import.Finalize(Monitor);
    end Finalize;
  procedure Clear(Stencil_Value : in Integer_4_Signed; Do_Clear_Depth : in Boolean := False) is
    begin
      Clear_Stencil(Integer_4_Signed_C(Stencil_Value));
      Clear((if Do_Clear_Depth then GL_DEPTH_BUFFER_BIT else 0) or GL_STENCIL_BUFFER_BIT);
    end Clear;
  procedure Check_Exceptions is
    begin
      case Get_Error is
        when GL_INVALID_ENUM => raise Invalid_Enumeration;
        when GL_INVALID_OPERATION   => raise Invalid_Operation;
        when GL_STACK_UNDERFLOW     => raise Stack_Underflow;
        when GL_STACK_OVERFLOW      => raise Stack_Overflow;
        when GL_INVALID_VALUE       => raise Invalid_Value;
        when GL_OUT_OF_MEMORY       => raise Out_Of_Memory;
        when others                 => null;
      end case;
    end Check_Exceptions;
  procedure Cull(Kind : in Enumerated_Cull; Is_Mirror : in Boolean := False) is
    begin
      case Kind is
        when Face_Culling    => null;
        when Two_Sided_Cull  => Disable(GL_CULL_FACE);
        when Back_Sided_Cull => Cull_Face((if Is_Mirror then GL_FRONT else GL_BACK));
      end case;
    end Cull;
  procedure Set_Viewport(X, Y, Width, Height : in Integer_4_Signed) is
    begin
      Viewport(Integer_4_Signed_C(X), Integer_4_Signed_C(Y), Integer_4_Signed_C(Width), Integer_4_Signed_C(Height));
    end Set_Viewport;
  procedure Set_Polygon_Offset(Scale, Bias : in Float_4_Real) is
    begin
      if Scale = 0.0 and Bias = 0.0 then
        Disable(GL_POLYGON_OFFSET_FILL);
        Disable(GL_POLYGON_OFFSET_LINE);
      else
        Polygon_Offset(
          Factor => Float_4_Real_C(Scale),
          Units  => Float_4_Real_C(Bias));
        Enable(GL_POLYGON_OFFSET_FILL);
        Enable(GL_POLYGON_OFFSET_LINE);
      end if;
    end Set_Polygon_Offset;
  procedure Set_Blend(Source, Destination : in Enumerated_Blend) is
    BLENDS : constant array(Enumerated_Blend'range) of Integer_4_Unsigned_C :=(
      One_Blend                         => GL_ZERO,
      Zero_Blend                        => GL_ONE,
      Source_Alpha_Blend                => GL_SRC_ALPHA,
      Destination_Color_Blend           => GL_DST_COLOR,
      Destination_Alpha_Blend           => GL_DST_ALPHA,
      One_Minus_Source_Alpha_Blend      => GL_ONE_MINUS_SRC_ALPHA,
      One_Minus_Destination_Color_Blend => GL_ONE_MINUS_DST_COLOR,
      One_Minus_Destination_Alpha_Blend => GL_ONE_MINUS_DST_ALPHA);
    begin
      if Source = One_Blend and Destination = Zero_Blend then Disable(GL_BLEND);
      else
        Enable(GL_BLEND);
        Blend_Function(BLENDS(Source), BLENDS(Destination));
      end if;
    end Set_Blend;
  procedure Set_Stencil_Operation(Fail, Fail_Z, Pass : in Enumerated_Stencil_Operation) is
    OPERATIONS : constant array(Enumerated_Stencil_Operation'range) of Integer_4_Unsigned_C :=(
      Keep_Stencil_Operation           => GL_KEEP,
      Zero_Stencil_Operation           => GL_ZERO,
      Invert_Stencil_Operation         => GL_INVERT,
      Replace_Stencil_Operation        => GL_REPLACE,
      Increment_Stencil_Operation      => GL_INCR,
      Decrement_Stencil_Operation      => GL_DECR,
      Increment_Wrap_Stencil_Operation => GL_INCR_WRAP,
      Decrement_Wrap_Stencil_Operation => GL_DECR_WRAP);
    begin
      null;--Stencil_Operation(OPERATIONS(Fail), OPERATIONS(Fail_Z), OPERATIONS(Pass));
    end Set_Stencil_Operation;
  procedure Set_Stencil_Function(Kind : in Enumerated_Condition; Reference : in Integer_4_Signed; Mask : in Integer_4_Unsigned; Do_Test : in Boolean) is
    begin
      if Do_Test then Enable(GL_STENCIL_TEST);
      else Disable(GL_STENCIL_TEST); end if;
      --Stencil_Function(
      --  Referece      => Integer_4_Signed_C(Reference),
      --  Mask          => Integer_4_Unsigned_C(Mask),
      --  Function_Kind => CONDITIONS(Kind));
    end Set_Stencil_Function;
  procedure Set_Stereo_Depth(Kind : in Enumerated_Condition) is
    begin
      Depth_Function(CONDITIONS(Kind));
    end Set_Stereo_Depth;
  procedure Set_Depth_Mask(Do_Enable : in Boolean := True) is
    begin
      Depth_Mask((if Do_Enable then GL_TRUE else GL_FALSE));
    end Set_Depth_Mask;
  procedure Set_Polymode_Line(Do_Enable : in Boolean := True) is
    begin
      Polygon_Mode(GL_FRONT_AND_BACK, (if Do_Enable then GL_LINE else GL_FILL));
    end Set_Polymode_Line;
  procedure Set_Depth_Bounds(Z_Minimum, Z_Maximum : in Float_8_Real) is
    begin
      if Z_Minimum = 0.0 and Z_Maximum = 0.0 then Disable(GL_DEPTH_BOUNDS_TEST_EXT);
      else
        Enable(GL_DEPTH_BOUNDS_TEST_EXT);
        Depth_Bounds(Float_8_Real_C(Z_Minimum), Float_8_Real_C(Z_Maximum));
      end if;
    end Set_Depth_Bounds;
  --procedure Color(Color : in Record_Color) is
  --  begin
  --    Color(
  --      Red   => Float_4_Real_C(Color.Red)   / Color.Red'size,
  --      Green => Float_4_Real_C(Color.Green) / Color.Green'size,
  --      Blue  => Float_4_Real_C(Color.Blue)  / Color.Blue'size,
  --      Alpha => 1.0);
  --  end Color;
  function Get_Driver return Record_Driver is
    begin
      return(
        Set_Color_Mask => Set_Color_Mask'access,
        Reset          => Reset'access,
        Initialize     => Initialize'access,
        Finalize       => Finalize'access);
    end Get_Driver;
--     procedure Start_Depth_Pass(Rectane : in Record_Rectane) is
--       begin
--         null;
--       end Start_Depth_Pass;
--     procedure Finish_Depth_Pass(Rectane : in Record_Rectane)  is
--       begin
--         null;
--       end Finish_Depth_Pass;
--     procedure Get_Depth_Pass(Rectane : in out Record_Rectane) is
--       begin
--         Rectane := (others => <>);
--       end Get_Depth_Pass;
--     procedure Color(Pixel : in Record_Pixel)  is
--       begin
--         Color(
--           Red   => Float_4_Real_C(Pixel.Color.Red)   / Pixel.Color.Red'size,
--           Green => Float_4_Real_C(Pixel.Color.Green) / Pixel.Color.Green'size,
--           Blue  => Float_4_Real_C(Pixel.Color.Blue)  / Pixel.Color.Blue'size,
--           Alpha => Float_4_Real_C(Pixel.Alpha)       / Pixel.Color.Alpha'size);
--       end Color;
--     procedure Clear is
--       begin
--         Clear(DEPTH_BUFFER_BIT);
--       end Clear;
--     procedure Clear(Color : in Record_Pixel; Do_Clear_Depth : in Boolean := False) is
--       begin
--         Clear_Color(Red, Green, Blue, Alpha);
--         Clear((if Do_Clear_Depth then DEPTH_BUFFER_BIT else 0) or COLOR_BUFFER_BIT);
--       end Clear;
--     procedure Clear(Color : in Record_Pixel; Stencil_Value : in Integer_1_Unsigned; Do_Clear_Depth : in Boolean := False) is
--       begin
--         Clear_Stencil(Stencil_Value);
--         Clear((if Do_Clear_Depth then DEPTH_BUFFER_BIT else 0) or STENCIL_BUFFER_BIT or COLOR_BUFFER_BIT);
--       end Clear;
--     procedure Set_Stereo_3D(Stereo_3D : in Enumerated_Stereo_3D) is
--       begin
--       end Set_Stereo_3D;
--     procedure Set_Blend_Operation(Blend_Operation : in Enumerated_Blend_Operation) is
--       begin
--       end Set_Blend_Operation;
--     procedure Set_Stencil(Stencil : in Enumerated_Stencil) is
--       begin
--       end Set_Stencil;
--     procedure Set_Depth_Function(Value : in Enumerated_Depth_Function) is
--       begin
--       end Set_Depth_Function;
--     procedure Set_Buffer(const void *data ) is
--       -- see which draw buffer we want to render the frame to
--       const setBufferCommand_t * cmd = (const setBufferCommand_t *)data;
--       begin
--         Scissor(0, 0, tr.GetWidth, tr.GetHeight);
--         -- clear screen for debugging automatically enable this with several other debug tools
--         -- that might leave unrendered portions of the screen
--         if r_clear.GetFloat or idStr::Length(r_clear.GetString ) != 1 || r_sineArea.GetBool || r_showOverDraw.GetBool ) {
--           float c[3];
--           if sscanf(r_clear.GetString, "%f %f %f", &c[0], &c[1], &c[2] ) = 3 then
--             Clear(true, false, false, 0, c[0], c[1], c[2], 1.0f);
--           elsif r_clear.GetInteger = 2 then
--             Clear(true, false, false, 0, 0.0, 0.0, 0.0, 1.0);
--           elsif r_showOverDraw.GetBool then
--             Clear(true, false, false, 0, 1.0, 1.0, 1.0, 1.0);
--           else
--             Clear(true, false, false, 0, 0.4, 0.0, 0.25, 1.0);
--           end if;
--         end if;
--       end Set_Buffer;
--     procedure Make_Stereo_Render_Image(Graphic : in Record_Graphic) is
--       idImageOpts opts;
--       begin
--         opts.width := renderSystem->GetWidth;
--         opts.height := renderSystem->GetHeight;
--         opts.numLevels := 1;
--         opts.format := FMT_RGBA8;
--         image->AllocImage(opts, TF_LINEAR, TR_CLAMP);
--       end Make_Stereo_Render_Image;
--     procedure Render_Headset( is
--       begin
--       end Render;
  procedure Initialize_Texture(Texture : in out Record_Texture) is
--    int numSides;
--    int target;
--    int uploadTarget;
    begin
      Generate_Textures(1, Identifier'unchecked_access); -- glGenTextures
      Assert(Identifier /= GL_TEXTURE_NOT_LOADED);
      Bind_Texture(GL_TEXTURE_BINDING_2D, Identifier); -- glBindTexture
      Texture_Image_2D(uploadTarget + side, level, internalFormat, w, h, 0, dataFormat, dataType, NULL); -- glTexImage2D
      Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GL_TEXTURE_MAX_LEVEL, opts.numLevels - 1); -- glTexParameteri
      case Texture.Format is
        when Green_Alpha_Format =>
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_R, GL_ONE);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_G, GL_ONE);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_B, GL_ONE);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_A, GL_GREEN);  -- glTexParameteri
        when Luminance_Format =>
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_R, GL_RED);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_G, GL_RED);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_B, GL_RED);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_A, GL_ONE);  -- glTexParameteri
        when Luminance_Alpha_Format =>
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_R, GL_RED);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_G, GL_RED);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_B, GL_RED);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_A, GL_GREEN);  -- glTexParameteri
        when Alpha_Format =>
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_R, GL_ONE);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_G, GL_ONE);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_B, GL_ONE);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_A, GL_RED);  -- glTexParameteri
        when Intensity_Format =>
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_R, GL_RED);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_G, GL_RED);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_B, GL_RED);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_A, GL_RED);  -- glTexParameteri
        when others =>
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_R, GL_RED);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_G, GL_GREEN);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_B, GL_BLUE);  -- glTexParameteri
          Texture_Parameter_Integer(GL_TEXTURE_BINDING_2D, GLTEXTURE_SWIZZLE_A, GL_ALPHA);  -- glTexParameteri
      end case;
      case Texture.Filter is
        when Default_Filter =>
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_MIN_FILTER, (if Do_Use_Trilinear_Filtering.Get then GL_LINEAR_MIPMAP_LINEAR else GL_LINEAR_MIPMAP_NEAREST));
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        when Linear_Filter =>
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        when Nearest_Filter =>
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
      end case;
      case Texture.Clamp is
        when No_Clamp =>
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        when Zero_Clamp =>
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
        when Zero_Alpha_Clamp =>
          Texture_Parameter_Float_Vector(GL_TEXTURE_BINDING_2D, GL_TEXTURE_BORDER_COLOR, (0.0, 0.0, 0.0, 0.0));
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
        when Edge_Clamp =>
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
      end case;
      if SPECIFICS.Has_Anisotropic_Filter then
        if Texture.Filter = Default_Filter then
          Anisotropic_Value := Maximum_Anisotropic_Filtering.Get;
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, (if Anisotropic_Value > Maximum_Texture_Anisotropy then Maximum_Texture_Anisotropy else Anisotropic_Value));
        else
          Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1);
        end if;
      end if;
      if Texture_LOD_Bias_Available and usage /= Font then
        Texture_Parameter_Float(GL_TEXTURE_BINDING_2D, GL_TEXTURE_LOD_BIAS_EXT, LOD_Bias.Get);
      end if;
      Check_Exceptions;
    end Initialize_Texture;
  procedure Finalize_Texture(Texture : in out Record_Texture) is
    begin
      if Texture.Identifier /= TEXTURE_NOT_LOADED then null;
--        Delete_Textures(1, (GLuint *)&Texture.Identifier); -- this should be the ONLY place it is ever called!
--        Texture.Identifier = TEXTURE_NOT_LOADED;
      end if;
    end Finalize_Texture;
--     procedure Upload_Subimage (mipLevel, x, y, z, width, height, const void * pic, int pixelPitch) is
--       int compressedSize = 0;
--       begin
--         if Is_Compressed then
--           assert( !(x&3) && !(y&3) );
--           -- The compressed size may be larger than the dimensions due to padding to quads
--           compressedSize = ( width + 3 ) & ~3 * ( height + 3 ) & ~3 * BitsForFormat( opts.format ) / 8;
--           assert( x + width <= ( opts.width + 3 ) & ~3 && y + height <= ( opts.height + 3 ) & ~3);
--           -- OpenGL understands that there will be padding
--           if x + width > opts.width then width = opts.width - x; end if;
--           if y + height > opts.height then height = opts.height - x; end if;
--         else
--           assert( x + width <= opts.width && y + height <= opts.height );
--         end if;
--         int target;
--         int uploadTarget;
--         if ( opts.textureType == TT_2D ) {
--           target = TEXTURE_2D;
--           uploadTarget = TEXTURE_2D;
--         } else if ( opts.textureType == TT_CUBIC ) {
--           target = TEXTURE_CUBE_MAP_EXT;
--           uploadTarget = TEXTURE_CUBE_MAP_POSITIVE_X_EXT + z;
--         } else {
--           assert( !"invalid opts.textureType" );
--           target = TEXTURE_2D;
--           uploadTarget = TEXTURE_2D;
--         }
--         glBindTexture( target, texnum );
--         if ( pixelPitch != 0 ) {
--           glPixelStorei( UNPACK_ROW_LENGTH, pixelPitch );
--         }
--         if ( opts.format == FMT_RGB565 ) {
--           glPixelStorei( UNPACK_SWAP_BYTES, TRUE );
--         }
--         if ( IsCompressed ) {
--           glCompressedTexSubImage2DARB( uploadTarget, mipLevel, x, y, width, height, internalFormat, compressedSize, pic );
--         } else {
--           // make sure the pixel store alignment is correct so that lower mips get created
--           // properly for odd shaped textures - this fixes the mip mapping issues with
--           // fonts
--           int unpackAlignment = width * BitsForFormat( (textureFormat_t)opts.format ) / 8;
--           if ( ( unpackAlignment & 3 ) == 0 ) {
--             glPixelStorei( UNPACK_ALIGNMENT, 4 );
--           } else {
--             glPixelStorei( UNPACK_ALIGNMENT, 1 );
--           }
--           glTexSubImage2D( uploadTarget, mipLevel, x, y, width, height, dataFormat, dataType, pic );
--         }
--         if ( opts.format == FMT_RGB565 ) {
--           glPixelStorei( UNPACK_SWAP_BYTES, FALSE );
--         }
--         if ( pixelPitch != 0 ) {
--           glPixelStorei( UNPACK_ROW_LENGTH, 0 );
--         }
--       end Upload_Subimage;
--
--  /*
--  ========================
--  idImage::SetPixel
--  ========================
--  */
--  void idImage::SetPixel( int mipLevel, int x, int y, const void * data, int dataSize ) {
--    SubImageUpload( mipLevel, x, y, 0, 1, 1, data );
--  }
--
  procedure Draw is
    begin
      if Vertex_Cache.Is_Static(Surface.Ambient_Cache) then Vertex_Buffer := Vertex_Cache.Static_Data.Vertex_Buffer;
      else
        if Surface.Ambient_Cache.Frame_Number /= Vertex_Cache.Current_Frame then raise Call_Failure; end if;
        Vertex_Buffer := Vertex_Cache.Frame_Data(Vertex_Cache.Draw_List_Index).Vertex_Buffer;
      end if;
      if Vertex_Cache.Is_Static(Surface.Ambient_Cache) then Index_Buffer := Vertex_Cache.Static_Data.Index_Buffer;
      else
        if Surface.Ambient_Cache.Frame_Number != Vertex_Cache.Current_Frame then raise Call_Failure; end if;
        Index_Buffer := Vertex_Cache.Frame_Data(Vertex_Cache.Draw_List_Index).Index_Buffer;
      end if;
      if Surface.Joint_Cache.Is_Empty then Assert(not Current_Shader.Has_Joints or Current_Shader.Has_Optional_Skinning);
      else
        Assert(Current_Shader.Has_Joints);
        Assert(not Vertex_Cache.Joint_Buffer.Is_Empty);
        Assert(Vertex_Cache.Joint_Buffer.Offset = Uniform_Buffer_Offset_Alignment.Get);
        Bind_Buffer_Range(
          GL_UNIFORM_BUFFER,
          0,
          Vertex_Cache.Joint_Buffer.Get_API_Object,
          Vertex_Cache.Joint_Buffer.Offset,
          Vertex_Cache.Joint_Buffer.Length * idJointmat'size);-- glBindBufferRange( GL_UNIFORM_BUFFER, 0, ubo, jointBuffer.GetOffset, jointBuffer.GetNumJoints * sizeof( idJointMat ) );
      end if;
      Current_Shader.CommitUniforms;
      if backEnd.glState.currentIndexBuffer /= (GLuint)indexBuffer->GetAPIObject or not r_useStateCaching.GetBool then
        glBindBufferARB( GL_ELEMENT_ARRAY_BUFFER_ARB, (GLuint)indexBuffer->GetAPIObject );
        backEnd.glState.currentIndexBuffer = (GLuint)indexBuffer->GetAPIObject;
      end if;
      if (backEnd.glState.vertexLayout /= LAYOUT_DRAW_VERT) or (backEnd.glState.currentVertexBuffer /= (GLuint)vertexBuffer->GetAPIObject) or not r_useStateCaching.GetBool then
        glBindBufferARB( GL_ARRAY_BUFFER_ARB, (GLuint)vertexBuffer->GetAPIObject );
        backEnd.glState.currentVertexBuffer = (GLuint)vertexBuffer->GetAPIObject;
        Enable_Vertex_Attribute_Array(SHADER_VERTEX);--
        Enable_Vertex_Attribute_Array(SHADER_NORMAL);
        Enable_Vertex_Attribute_Array(SHADER_COLOR);
        Enable_Vertex_Attribute_Array(SHADER_COLOR2);
        Enable_Vertex_Attribute_Array(SHADER_INDEX_ST);
        Enable_Vertex_Attribute_Array(SHADER_TANGENT);
        Vertex_Attribute_Pointer(SHADER_INDEX_VERTEX,  3, GL_FLOAT,         GL_FALSE, sizeof( idDrawVert ), (void *)( ) ); -- glVertexAttribPointerARB
        Vertex_Attribute_Pointer(SHADER_INDEX_NORMAL,  4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof( idDrawVert ), (void *)( DRAWVERT_NORMAL_OFFSET ) );
        Vertex_Attribute_Pointer(SHADER_INDEX_COLOR,   4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof( idDrawVert ), (void *)( DRAWVERT_COLOR_OFFSET ) );
        Vertex_Attribute_Pointer(SHADER_INDEX_COLOR2,  4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof( idDrawVert ), (void *)( DRAWVERT_COLOR2_OFFSET ) );
        Vertex_Attribute_Pointer(SHADER_INDEX_ST,      2, GL_HALF_FLOAT,    GL_TRUE,  sizeof( idDrawVert ), (void *)( DRAWVERT_ST_OFFSET ) );
        Vertex_Attribute_Pointer(SHADER_INDEX_TANGENT, 4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof( idDrawVert ), (void *)( DRAWVERT_TANGENT_OFFSET ) );
        backEnd.glState.vertexLayout = LAYOUT_DRAW_VERT;
      end if;
      glDrawElementsBaseVertex( GL_TRIANGLES, r_singleTriangle.GetBool ? 3 : surf->numIndexes, GL_INDEX_TYPE, (triIndex_t *)indexOffset, vertOffset / sizeof ( idDrawVert ) );
    end Draw;
  procedure Bind_Buffers is
    begin
      if backEnd.glState.currentIndexBuffer /= indexBuffer->GetAPIObject or not r_useStateCaching.GetBool then
        glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, (GLuint)indexBuffer->GetAPIObject);
        backEnd.glState.currentIndexBuffer = (GLuint)indexBuffer->GetAPIObject;
      end if;
      if drawSurf->jointCache then
        Assert(renderProgManager.ShaderUsesJoints and );
        glBindBufferRange(GL_UNIFORM_BUFFER, 0, ubo, jointBuffer.GetOffset, jointBuffer.GetNumJoints * sizeof(idJointMat));
        if (backEnd.Gl_Satate.Vertex_Layer /= LAYOUT_DRAW_SHADOW_VERT_SKINNED) or (Back_End.GL_State.Current_Vertex_Buffer /= Vertex_Buffer.Get_API_Object) or not r_useStateCaching.GetBool then
          glBindBufferARB( GL_ARRAY_BUFFER_ARB, (GLuint)vertexBuffer->GetAPIObject );
          backEnd.glState.currentVertexBuffer = (GLuint)vertexBuffer->GetAPIObject;
          glEnableVertexAttribArrayARB( PC_ATTRIB_INDEX_VERTEX );
          glDisableVertexAttribArrayARB( PC_ATTRIB_INDEX_NORMAL );
          glEnableVertexAttribArrayARB( PC_ATTRIB_INDEX_COLOR );
          glEnableVertexAttribArrayARB( PC_ATTRIB_INDEX_COLOR2 );
          glDisableVertexAttribArrayARB( PC_ATTRIB_INDEX_ST );
          glDisableVertexAttribArrayARB( PC_ATTRIB_INDEX_TANGENT );
          glVertexAttribPointerARB( PC_ATTRIB_INDEX_VERTEX, 4, GL_FLOAT, GL_FALSE, sizeof( idShadowVertSkinned ), (void *)( SHADOWVERTSKINNED_XYZW_OFFSET ) );
          glVertexAttribPointerARB( PC_ATTRIB_INDEX_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof( idShadowVertSkinned ), (void *)( SHADOWVERTSKINNED_COLOR_OFFSET ) );
          glVertexAttribPointerARB( PC_ATTRIB_INDEX_COLOR2, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof( idShadowVertSkinned ), (void *)( SHADOWVERTSKINNED_COLOR2_OFFSET ) );
          backEnd.glState.vertexLayout = LAYOUT_DRAW_SHADOW_VERT_SKINNED;
        end if;
      elsif backEnd.glState.vertexLayout != LAYOUT_DRAW_SHADOW_VERT ) || ( backEnd.glState.currentVertexBuffer != (GLuint)vertexBuffer->GetAPIObject ) || !r_useStateCaching.GetBool ) {
        glBindBufferARB( GL_ARRAY_BUFFER_ARB, (GLuint)vertexBuffer->GetAPIObject );
        backEnd.glState.currentVertexBuffer = (GLuint)vertexBuffer->GetAPIObject;
        glEnableVertexAttribArrayARB( PC_ATTRIB_INDEX_VERTEX );
        glDisableVertexAttribArrayARB( PC_ATTRIB_INDEX_NORMAL );
        glDisableVertexAttribArrayARB( PC_ATTRIB_INDEX_COLOR );
        glDisableVertexAttribArrayARB( PC_ATTRIB_INDEX_COLOR2 );
        glDisableVertexAttribArrayARB( PC_ATTRIB_INDEX_ST );
        glDisableVertexAttribArrayARB( PC_ATTRIB_INDEX_TANGENT );
        glVertexAttribPointerARB( PC_ATTRIB_INDEX_VERTEX, 4, GL_FLOAT, GL_FALSE, sizeof( idShadowVert ), (void *)( SHADOWVERT_XYZW_OFFSET ) );
        backEnd.glState.vertexLayout = LAYOUT_DRAW_SHADOW_VERT;
      end if;
    end Bind_Buffers;
  procedure Finalize_Shadow_State is
    begin
      Cull(CT_FRONT_SIDED );
      if Do_Use_Shadow_Depth_Bounds.Get then
        if Do_Use_Light_Depth_Bounds.Get then
          GL_DepthBoundsTest( vLight->scissorRect.zmin, vLight->scissorRect.zmax );
        else
          GL_DepthBoundsTest( 0.0f, 0.0f );
        end if;
      end if;
      glStencilOpSeparate( GL_FRONT, GL_KEEP, GL_REPLACE, GL_ZERO );
      glStencilOpSeparate( GL_BACK, GL_KEEP, GL_ZERO, GL_REPLACE );
    end Finalize_Shadow_State;
end OpenGL;
