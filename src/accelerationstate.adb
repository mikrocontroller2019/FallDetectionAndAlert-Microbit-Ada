------------------------------------------------------------------------------
--                    mikrocontroller2019                                   --
------------------------------------------------------------------------------

package body AccelerationState is

   -- Thresholds
   GravityThreshold : Axis_Data := 150;
   FreeFallThreshold :  Integer := 50;
   ImpactThreshold :  Integer := 500;
  
   -- Interval for detection reset
   AutoResetInterval : Time.Time_Ms := 10000;
   
   -- Sensor data
   CurrentData, PreviousData : Three_Axes_Data := (X => 0, Y => 0, Z => 0);
   
   -- Total acceleration
   CurrentTotal, PreviousTotal : Integer := -1;
   MinTotal : Integer := Integer(Axis_Data'Last);
   MaxTotal : Integer := Integer(Axis_Data'First);
   
   -- Sensor orientation
   CurrentOrientation, PreviousOrientation : Orientation := Down;
  
   -- Timestamps
   LastTimeStamp : Time.Time_Ms := 0;
   LastOrientationChangeTime : Time.Time_Ms := 0;
   LastFreeFallTime : Time.Time_Ms := 0;
   LastImpactTime : Time.Time_Ms := 0;
   
   -- Update data from sensor reading
   procedure Update is
      Data : Three_Axes_Data;
      TimeStamp : Time.Time_Ms;
   begin
      TimeStamp := Time.Clock;
      Data := ThreeAxisAccelerometer.Data;
      
      if Long_Integer(TimeStamp) - Long_Integer(LastTimeStamp) > Long_Integer(AutoResetInterval) then
         Reset;
      end if;
      
      PreviousData := CurrentData;
      CurrentData := Data;
      
      PreviousTotal := CurrentTotal;
      CurrentTotal := ThreeAxisAccelerometer.Total(CurrentData);
      
      if MinTotal > CurrentTotal then
         MinTotal := CurrentTotal;
      end if;
      
      if MaxTotal < CurrentTotal then
         MaxTotal := CurrentTotal;
      end if;
      
      if CurrentTotal <= FreeFallThreshold then
         LastFreeFallTime := TimeStamp;
      end if;
      
      if CurrentTotal >= ImpactThreshold then
         LastImpactTime := TimeStamp;
      end if;
      
      PreviousOrientation := CurrentOrientation;
      CurrentOrientation := OrientationFromData(CurrentData);
      
      if  PreviousOrientation /= CurrentOrientation then
         LastOrientationChangeTime := TimeStamp;
      end if;
      
      LastTimeStamp := TimeStamp;
   end Update;
   
   -- Reset all calculated / detection values
   procedure Reset is
      TimeStamp : Time.Time_Ms;
   begin
      TimeStamp := Time.Clock;
      
      PreviousData := CurrentData;
      CurrentData := (X => 0, Y => 0, Z => 0);
      
      PreviousTotal := CurrentTotal;
      CurrentTotal := -1;
      MinTotal := Integer(Axis_Data'Last);
      MaxTotal := Integer(Axis_Data'First);
     
      LastFreeFallTime := 0;
      LastImpactTime := 0;
      
      LastTimeStamp := TimeStamp;
   end Reset;
      
   -- Parmeter setter
   procedure SetGravityThreshold(Value: Integer) is
   begin
      GravityThreshold:= Axis_Data(Value);
   end SetGravityThreshold;
   
   procedure SetFreeFallThreshold(Value: Integer) is
   begin
      FreeFallThreshold:= Value;
   end SetFreeFallThreshold;
   
   procedure SetImpactThreshold(Value: Integer) is
   begin
      ImpactThreshold:= Value;
   end SetImpactThreshold;
   
   procedure SetAutoResetInterval(Value: Integer) is
   begin
      AutoResetInterval:= Time.Time_Ms(Value);
   end SetAutoResetInterval;
  
   -- Value getter
   function GetLastTimeStamp return Time.Time_Ms is (LastTimeStamp);
   function GetCurrentData return Three_Axes_Data is (CurrentData);
   function GetPreviousData return Three_Axes_Data is (PreviousData);
   function GetPreviousTotal return Integer is (PreviousTotal);
   function GetCurrentTotal return Integer is (CurrentTotal);
   function GetMinTotal return Integer is (MinTotal);
   function GetMaxTotal return Integer is (MaxTotal);
   function GetPreviousOrientation return Orientation is (PreviousOrientation);
   function GetCurrentOrientation return Orientation is (CurrentOrientation);
   function GetLastOrientationChangeTime return Time.Time_Ms is (LastOrientationChangeTime);
   function GetLastFreeFallTime return Time.Time_Ms is (LastFreeFallTime);
   function GetLastImpactTime return Time.Time_Ms is (LastImpactTime);
   
   -- Determine orientation
   function OrientationFromData(Data : Three_Axes_Data) return Orientation is
      Retval: Orientation;
   begin
      if Data.X > GravityThreshold then
         Retval := Left;
      elsif Data.X < -GravityThreshold then
         Retval := Right;
      elsif Data.Y > GravityThreshold then
         Retval := Up;
      elsif Data.Y < -GravityThreshold then
         Retval := Down;
      elsif Data.Z > GravityThreshold then
         Retval := Backwards;
      elsif Data.Z < -GravityThreshold then
         Retval := Forwards;
      else
         Retval:= Other;
      end if;
      return Retval;
   end OrientationFromData;
   
   -- Fall detection
   function FallDetected(Timing : Long_Integer; IgnoreOrientationChange : Boolean) return Boolean is
      LastTime, FreeFallTime, ImpactTime, OrientationChangeTime : Long_Integer;
      RecentFreeFall, RecentImpact, RecentOrientationChange : Boolean := False;
   begin
      LastTime := Long_Integer(LastTimeStamp);
      FreeFallTime := Long_Integer(LastFreeFallTime);
      ImpactTime := Long_Integer(LastImpactTime);
      OrientationChangeTime := Long_Integer(LastOrientationChangeTime);
      
      if FreeFallTime > 0 and  LastTime - FreeFallTime < Timing then
         RecentFreeFall := True;
      end if;
     
      if ImpactTime > 0 and LastTime - ImpactTime < Timing then
         RecentImpact := True;
      end if;
     
      if OrientationChangeTime > 0 and LastTime - OrientationChangeTime < Timing then
         RecentOrientationChange := True;
      end if;
      
      if RecentFreeFall and RecentImpact and (IgnoreOrientationChange or RecentOrientationChange) then
         return True;
      else
         return False;
      end if;
   end FallDetected;
   
end AccelerationState;
