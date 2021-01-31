------------------------------------------------------------------------------
--                    mikrocontroller2019                                   --
------------------------------------------------------------------------------

with ThreeAxisAccelerometer; use ThreeAxisAccelerometer;
with MicroBit.Time; use MicroBit; 

package AccelerationState is
   
   type Orientation is (Left, Right, Forwards, Backwards, Up, Down, Other);

   procedure Update;
   procedure Reset;

   procedure SetGravityThreshold(Value: Integer);
   procedure SetFreeFallThreshold(Value: Integer);
   procedure SetImpactThreshold(Value: Integer);
   procedure SetAutoResetInterval(Value: Integer);

   function GetLastTimeStamp return Time.Time_Ms;
   function GetCurrentData return Three_Axes_Data;
   function GetPreviousData return Three_Axes_Data;
   function GetPreviousTotal return Integer;
   function GetCurrentTotal return Integer;
   function GetMinTotal return Integer;
   function GetMaxTotal return Integer;
   function GetPreviousOrientation return Orientation;
   function GetCurrentOrientation return Orientation;
   function GetLastOrientationChangeTime return Time.Time_Ms;
   function GetLastFreeFallTime return Time.Time_Ms;
   function GetLastImpactTime return Time.Time_Ms;
   function OrientationFromData(Data : Three_Axes_Data) return Orientation; 
   
   function FallDetected(Timing : Long_Integer; IgnoreOrientationChange : Boolean) return Boolean;

end AccelerationState;
