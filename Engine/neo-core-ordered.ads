
--                                                                                                                                      --
--                                                         N E O  E N G I N E                                                           --
--                                                                                                                                      --
--                                                 Copyright (C) 2016 Justin Squirek                                                    --
--                                                                                                                                      --
-- Neo is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the --
-- Free Software Foundation, either version 3 of the License, or (at your option) any later version.                                    --
--                                                                                                                                      --
-- Neo is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of                --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.                            --
--                                                                                                                                      --
-- You should have received a copy of the GNU General Public License along with Neo. If not, see gnu.org/licenses                       --
--                                                                                                                                      --

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers; use Ada.Containers;

generic
  type Key_T is (<>);
  type Map_T is private;
package Neo.Core.Ordered is

  ------------------
  -- Ordered Maps --
  ------------------

  -- Base type
  package Unsafe is new Ada.Containers.Indefinite_Ordered_Maps (Key_T, Map_T, "<", "="); use Unsafe;
  subtype Cursor is Unsafe.Cursor;
  NO_ELEMENT : Cursor := Unsafe.NO_ELEMENT;

  -- Wrapped type
  protected type Safe_Map is
      procedure Clear;
      procedure Set     (Val : Unsafe.Map);
      procedure Next    (Pos : in out Cursor);
      procedure Delete  (Pos : in out Cursor);
      procedure Delete  (Key : Key_T);
      procedure Replace (Pos : Cursor; Item : Map_T);
      procedure Replace (Key : Key_T;  Item : Map_T);
      procedure Insert  (Key : Key_T;  Item : Map_T);
      function Has      (Key : Key_T)  return Bool;
      function Has      (Pos : Cursor) return Bool;
      function Key      (Pos : Cursor) return Key_T;
      function Get      (Pos : Cursor) return Map_T;
      function Get      (Key : Key_T)  return Map_T;
      function Get                     return Unsafe.Map;
      function First                   return Cursor;
      function Length                  return Natural;
    private
      This : Unsafe.Map;
    end;
end;
