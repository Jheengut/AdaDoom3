package Neo.File.Image is
  type Enumerated_Format is(
    --Flexible_Image_Transport_System,
    -- 1981 International Astronomical Union Flexible Image Transport System Working Group
    --      http://web.archive.org/web/20130215103213/http://fits.gsfc.nasa.gov/standard30/fits_standard30aa.pdf
    Truevision_Graphics_Adapter_Format);--,
    -- 1984 Truevision
    --      http://web.archive.org/web/20130206052029/http://www.dca.fee.unicamp.br/~martino/disciplinas/ea978/tgaffs.pdf
    --Personal_Computer_Exchange_Format,
    -- 1985 ZSoft
    --      http://web.archive.org/web/20100206055706/http://www.qzx.com/pc-gpe/pcx.txt
    --Graphics_Interchange_Format,
    -- 1985 CompuServe Information Service, now a subsidiary of America Online
    --      http://web.archive.org/web/20130426053329/http://www.w3.org/Graphics/GIF/spec-gif89a.txt
    --Tagged_Image_File_Format,
    -- 1986 Aldus
    --      http://web.archive.org/web/20130430213645/http://partners.adobe.com/public/developer/en/tiff/TIFF6.pdf
    --Portable_Pixmap_Format,
    -- 1988 Jef Poskanzer
    --      http://web.archive.org/web/20130517063911/http://netpbm.sourceforge.net/doc/pbm.html
    --X_Pixmap_Format,
    -- 1989 Daniel Dardailler and Colas Nahaboo
    --      http://web.archive.org/web/20070227101113/http://www.net.uom.gr/Books/Manuals/xpm-3-paper.pdf
    --Bit_Map_Format,
    -- 1990 Microsoft
    --      http://web.archive.org/web/20130424130243/http://en.wikipedia.org/wiki/BMP_file_format
    --Joint_Photographic_Experts_Group_Format,
    -- 1992 Joint Photographic Experts Group and Joint Bi-level Image Experts Group
    --      http://web.archive.org/web/20111226041637/http://white.stanford.edu/~brian/psy221/reader/Wallace.JPEG.pdf
    --Portable_Network_Graphics_Format,
    -- 1996 Internet Engineering Steering Group
    --      http://web.archive.org/web/20130116130737/http://libpng.org/pub/png/spec/iso/
    --S3_Texture_Compression_Format,
    -- 1998 S3 Graphics
    --      http://web.archive.org/web/20030618083605/www.hardwarecentral.com/hardwarecentral/reports/140/1/
    --      (NON-ARCHIVED) http://www.gamedev.no/projects/MegatextureCompression/324337_324337.pdf
    --Joint_Photographic_Experts_Group_2000_Format,
    -- 2000 Joint Photographic Experts Group and Joint Bi-level Image Experts Group
    --      http://web.archive.org/web/20130314150613/http://jpeg.org/public/fcd15444-1.pdf
    --      http://web.archive.org/web/20120117162132/http://www.mast.queensu.ca/~web/Papers/lui-project01.pdf
    --Valve_Texture_Format,
    -- 2003 Valve Softare
    --      http://web.archive.org/web/20130421141633/https://developer.valvesoftware.com/wiki/Valve_Texture_Format
    --PowerVR_Texture_Compression_Format,
    -- 2003 Imagination Technologies
    --      http://web.archive.org/web/20121130180454/http://web.onetel.net.uk/~simonnihal/assorted3d/fenney03texcomp.pdf
    --Ericsson_Texture_Compression_1_Format,
    -- 2005 Ericsson Research
    --      (NON-ARCHIVED) https://code.google.com/p/rg-etc1/
    --Ericsson_Texture_Compression_2_Format,
    -- 2007 Ericsson Research
    --      http://web.archive.org/web/20080908035259/http://www.graphicshardware.org/previous/www_2007/presentations/strom-etc2-gh07.pdf
    --Android_Texture_Compression_Format,
    -- 2008 Google
    --      http://www.guildsoftware.com/papers/2012.Converting.DXTC.to.ATC.pdf
    --Adaptive_Scalable_Texture_Compression_Format,
    -- 2012 ARM
    --      (NON-ARCHIVED) http://paper.ustor.cn/read/a_i%3D516a503bc624e810046edbac/
  type Enumerated_Rotation is (Clockwise_90_Rotation, Clockwise_180_Rotation, Clockwise_270_Rotation);
  type Enumerated_Colors   is (Monochrome_Colors, Eight_Colors, Sixteen_Colors, Two_Hundred_Fifty_Six_Per_Colors, Two_Hundred_Fifty_Six_With_Alpha_Per_Colors); for Enumerated_Colors use (1, 8, 16, 256, 512);
  type Record_Pixel is record
      Color : Record_Color       := (others => <>);
      Alpha : Integer_1_Unsigned := Byte'last;
    end record;
  type Array_Record_Pixel  is array(Positive range <>, Positive range <>)  of Record_Pixel;
  type Record_Graphic(Format : Enumerated_Format := Truevision_Graphics_Adapter_Format; Width, Height : Integer_4_Positive := 1) is record
      Pixels : Array_Record_Pixel(1..Width, 1..Height) := (others => (others => <>));
      Colors : Enumerated_Colors                       := Two_Hundred_Fifty_Six_With_Alpha_Per_Colors;
      case Format is
        --when Graphics_Interchange_Format =>
        --  Until_Next : Day_Duration := 0.0;
        when Truevision_Graphics_Adapter_Format =>
          Do_Encode  : Boolean      := False;
        --when Joint_Photographic_Experts_Group_Format =>
        --  Brightness : Boolean      := False;
        --  Hue        : Boolean      := False;
        --  Saturation : Boolean      := False;
        --  Inphase    : Boolean      := False;
        --  Quadrature : Boolean      := False;
      when others => null; end case;
    end record;
  procedure Save (Name : in String_2; Item : in Record_Graphic);
  function Load  (Name : in String_2) return Record_Graphic;
  --function Process_Drop_Sample (Graphic : in Record_Graphic) return Record_Graphic;
  --function Resample            (Graphic : in Record_Graphic) return Record_Graphic;
  --function Rotate              (Graphic : in Record_Graphic; Amount : in Enumerated_Rotation) return Record_Graphic; -- Clockwise
  --function Flip                (Graphic : in Record_Graphic; Do_Horizontally : in Boolean) return Record_Graphic;
  --function Process_Mip_Map     (Graphic : in Record_Graphic; Do_Use_Alpha_Specularity, Do_Use_Gamma : in Boolean := False) return Record_Graphic;
  --function Blend_Over          (Graphic : in Record_Graphic; Pixel_Count : in Integer_4_Positive; Blend : in Array_Integer_1_Unsigned) return Record_Graphic;
private
  --package FTS is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end FTS;
  --package TGA is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end TGA;
  --package FITS is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end FITS;
  --package GIF is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end GIF;
  --package TIFF is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end TIFF;
  --package PPM is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end PPM;
  --package XPM is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end XPM;
  --package BMP is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end BMP;
  --package JPEG is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end JPEG;
  --package PNG is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end PNG;
  --package DXT is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end DXT;
  --package JPEG2 is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end JPEG2;
  --package VTF is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end VTF;
  --package PVRTC is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end PVRTC;
  --package ETC1 is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end ETC1;
  --package ETC2 is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end ETC2;
  --package ATC is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end ATC;
  --package ASTC is
  --    function Load  (Name : in String_2) return Record_Graphic;
  --    procedure Save (Name : in String_2; Graphic : in Record_Graphic);
  --  end ASTC;
  package Graphic is new Handler(Enumerated_Format, Record_Graphic);
  --package FITS_Graphic  is new Graphic.Format(Flexible_Image_Transport_System,              FITS.Save'access,  FITS.Load'access,  "fts, fits");
  --package TGA_Graphic   is new Graphic.Format(Truevision_Graphics_Adapter_Format,           TGA.Save'access,   TGA.Load'access,   "tga");
  --package PCX_Graphic   is new Graphic.Format(Personal_Computer_Exchange_Format,            PCX.Save'access,   PCX.Load'access,   "pcx");
  --package GIF_Graphic   is new Graphic.Format(Graphics_Interchange_Format,                  GIF.Save'access,   GIF.Load'access,   "gif");
  --package TIFF_Graphic  is new Graphic.Format(Tagged_Image_File_Format,                     TIFF.Save'access,  TIFF.Load'access,  "tif, tiff");
  --package PPM_Graphic   is new Graphic.Format(Portable_Pixmap_Format,                       PPM.Save'access,   PPM.Load'access,   "ppm");
  --package XPM_Graphic   is new Graphic.Format(X_Pixmap_Format,                              XPM.Save'access,   XPM.Load'access,   "xpm");
  --package BMP_Graphic   is new Graphic.Format(Bit_Map_Format,                               BMP.Save'access,   BMP.Load'access,   "bmp");
  --package JPEG_Graphic  is new Graphic.Format(Joint_Photographic_Experts_Group_Format,      JPEG.Save'access,  JPEG.Load'access,  "jpeg");
  --package PNG_Graphic   is new Graphic.Format(Portable_Network_Graphics_Format,             PNG.Save'access,   PNG.Load'access,   "png");
  --package DXT_Graphic   is new Graphic.Format(S3_Texture_Compression_Format,                DXT.Save'access,   DXT.Load'access,   "dxt, dxt1, dxt2, dxt3, dxt4, dex5, s3t");
  --package JPEG2_Graphic is new Graphic.Format(Joint_Photographic_Experts_Group_2000_Format, JPEG2.Save'access, JPEG2.Load'access, "jp2, jpg2, jpeg2, jpg2000, jpeg2000");
  --package VTF_Graphic   is new Graphic.Format(Valve_Texture_Format,                         VTF.Save'access,   VTF.Load'access,   "vtf");
  --package PVRTC_Graphic is new Graphic.Format(PowerVR_Texture_Compression_Format,           PVRTC.Save'access, PVRTC.Load'access, "pvr, pvrc, pvrtc");
  --package ETC1_Graphic  is new Graphic.Format(Ericsson_Texture_Compression_1_Format,        ETC1.Save'access,  ETC1.Load'access,  "etc1, et1");
  --package ETC2_Graphic  is new Graphic.Format(Ericsson_Texture_Compression_2_Format,        ETC2.Save'access,  ETC2.Load'access,  "etc2, et2");
  --package ATC_Graphic   is new Graphic.Format(Android_Texture_Compression_Format,           ATC.Save'access,   ATC.Load'access,   "atc");
  --package ASTC_Graphic  is new Graphic.Format(Adaptive_Scalable_Texture_Compression_Format, ASTC.Save'access,  ASTC.Load'access,  "astc, ast, asc, asf");
end Neo.File.Image;
