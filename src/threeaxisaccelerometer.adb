------------------------------------------------------------------------------
--
-- ThreeAxisAccelerometer
--
-- Adaption of the original MircroBit.Accelerometer package by AdaCore for
-- usage with new LSM303AGR combinded motion sensor featured on the 1.5
-- micro:bit revision.
--
------------------------------------------------------------------------------
--                    mikrocontroller2019                                   --
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--                                                                          --
--                    Copyright (C) 2018-2019, AdaCore                      --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------
with LSM303AGR; use LSM303AGR;
with MicroBit.I2C; 
with MicroBit.Console;

package body ThreeAxisAccelerometer is

   Accelerometer  : LSM303AGR.LSM303AGR_Accelerometer (MicroBit.I2C.Controller);

   procedure Initialize;

   function Sqrt(X: Float) return Float;
 
   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      if not MicroBit.I2C.Initialized then
         MicroBit.I2C.Initialize;
      end if;

      Accelerometer.Configure (LSM303AGR.Freq_100);

      if not Accelerometer.Check_Accelerometer_Device_Id then
         MicroBit.Console.Put_Line("Warning: No LSM303AGR motion sensor found!");
      else
         MicroBit.Console.Put_Line("Info: LSM303AGR motion sensor initialized!");
      end if;

   end Initialize;

   ----------
   -- Data --
   ----------

   function Data return Three_Axes_Data is
      AllAxesData : LSM303AGR.All_Axes_Data := (X => 0, Y => 0, Z => 0);
      Retval : Three_Axes_Data := (X => 0, Y => 0, Z => 0);
   begin
      AllAxesData := LSM303AGR.Read_Accelerometer (Accelerometer); 
      -- MicroBit.Console.Put ("LSM303AGR reading (X,Y,Z):");
      -- MicroBit.Console.Put (Integer'Image (Integer (AllAxesData.X)));
      -- MicroBit.Console.Put ("," & Integer'Image (Integer (AllAxesData.Y)));
      -- MicroBit.Console.Put ("," & Integer'Image (Integer (AllAxesData.Z)));
      -- MicroBit.Console.Put_Line ("");
      Retval.X := Axis_Data(AllAxesData.X);
      Retval.Y := Axis_Data(AllAxesData.Y);
      Retval.Z := Axis_Data(AllAxesData.Z);
      return Retval;
   end Data;
   
   -------------------------------
   -- Total / Sum acceleration  --
   -------------------------------

   function Total(Accelerometer_Data : Three_Axes_Data) return Integer is
      Retval : Integer := -1;
      SquareX,SquareY,SquareZ : Integer;
   begin
      SquareX := Integer(Accelerometer_Data.X*Accelerometer_Data.X);
      SquareY := Integer(Accelerometer_Data.Y*Accelerometer_Data.Y);
      SquareZ := Integer(Accelerometer_Data.Z*Accelerometer_Data.Z);
      Retval :=  Integer(Sqrt(Float(SquareX+SquareY+SquareZ)));
      return Retval;
   end Total;

   
   -------------------------------------------------
   -- Simple square root approximation ('Heron')  --
   -------------------------------------------------
   
   function Sqrt(X: Float) return Float is
      Epsilon : constant := 0.01;
      R : Float;
      Y: Float;
   begin
      R := 1.0;
      Y := X / R;
      while abs(R-Y) > Epsilon loop
         R := (R + X/R) / 2.0;
         Y:= X / R;
      end loop;
      return R;
   end Sqrt;

begin
   Initialize;
end ThreeAxisAccelerometer;
