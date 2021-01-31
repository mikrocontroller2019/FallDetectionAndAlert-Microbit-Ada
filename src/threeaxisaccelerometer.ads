package ThreeAxisAccelerometer is

   type Axis_Data is range -2**9 .. 2**9 - 1 with
     Size => 10;

   type Three_Axes_Data is record
      -- Represents accelerometer data for 3 Axes
      X, Y, Z : Axis_Data;
   end record;
   
   function Data return Three_Axes_Data;
   --  Return the acceleration value for each of the three axes (X, Y, Z)
   
   function Total(Accelerometer_Data : Three_Axes_Data) return Integer;
   -- Return the total acceleration value as "sum" of the three axes (X, Y, Z)
   
end ThreeAxisAccelerometer;
