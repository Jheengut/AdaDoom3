with Ada.Finalization; use Ada.Finalization;
with Ada.Streams;      use Ada.Streams;
package Neo.System.Network is
  Invalid_Network_Address : Exception;
  type Record_State is record
      Network_Address           : String_2(1..64)    := (others => NULL_CHARACTER_2);
      Number_Of_Packets_Read    : Integer_8_Unsigned := 0;
      Number_Of_Packets_Written : Integer_8_Unsigned := 0;
      Number_Of_Bytes_Read      : Integer_8_Unsigned := 0;
      Number_Of_Bytes_Written   : Integer_8_Unsigned := 0;
    end record;
  generic
    IP_Address : String_2;
  package Connection is
      procedure Silence;
      procedure Vocalize;
      procedure Send     (Recipient : in String_2; Data : in Stream_Element_Array);
      function Recieve   (Sender : out String_2_Unbounded; Timeout : in Duration := 0.0) return Stream_Element_Array;
      function Get_State return Record_State;
    private
      type Record_Controller is new Controlled;
      Controller   : Record_Controller;
      Vocal_Status : Protected_Status;
      Socket       : Integer_8_Unsigned := 0; --???
      State        : Record_State       := (others => <>);
    end Connection;
  function Get_IP_Address return String_2;
private
  package Import is
      procedure Set_IP_Address (Socket : in Integer_8_Unsigned; Value : in String_2);
      procedure Send           (Socket : in Integer_8_Unsigned; To    : in String_2; Data : in Address);
      function Recieve         (Socket : in Integer_8_Unsigned; From  : in String_2; Timeout : in Duration) return Address;
      function Get_IP_Address  return String_2;
    end Import;
end Neo.System.Network;
