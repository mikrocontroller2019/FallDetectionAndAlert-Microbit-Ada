------------------------------------------------------------------------------
--                    mikrocontroller2019                                   --
------------------------------------------------------------------------------

with MicroBit.Buttons; use MicroBit.Buttons;
with MicroBit.Display;
with MicroBit.Display.Symbols;
with MicroBit.Console;
with MicroBit.Time;
with MicroBit.Music;
use MicroBit;
with Beacon;
with ThreeAxisAccelerometer;
with AccelerationState;

procedure Main is

   Data : ThreeAxisAccelerometer.Three_Axes_Data := (X => 0, Y => 0, Z => 0);
   TotalAcc, MinTotalAcc, MaxTotalAcc : Integer := -1;
   Panic, FallDetected : Boolean := False;
   Alarm : constant MicroBit.Music.Note := (MicroBit.Music.B4,400);

begin

   Beacon.Initialize_Radio;

   -- Console output for testing, remove in production ...
   -- (for plotter legend)
   Console.Put_Line ("accX:0 accY:0 accZ:0 totalAcc:0 minTotalAcc:0 maxTotalAcc:0");

   loop
      --  Read the accelerometer data ...
      AccelerationState.Update;

      -- Console output for testing, remove in production ...
      Data := AccelerationState.GetCurrentData;
      TotalAcc := AccelerationState.GetCurrentTotal;
      MinTotalAcc := AccelerationState.GetMinTotal;
      MaxTotalAcc := AccelerationState.GetMaxTotal;
      Console.Put (Integer'Image (Integer (Data.X)));
      Console.Put (" " & Integer'Image (Integer (Data.Y)));
      Console.Put (" " & Integer'Image (Integer (Data.Z)));
      Console.Put (" " & Integer'Image (TotalAcc));
      Console.Put (" " & Integer'Image (MinTotalAcc));
      Console.Put (" " & Integer'Image (MaxTotalAcc));
      Console.Put_Line ("");

      -- Check for fall detection ..
      if AccelerationState.FallDetected(1000,True) then
         FallDetected := True;
      end if;

      -- Check buttons ...
      if MicroBit.Buttons.State (MicroBit.Buttons.Button_A) = Pressed then
         --  If button A is pressed signal "Panic!" ...
         Panic := True;
      elsif MicroBit.Buttons.State (MicroBit.Buttons.Button_B) = Pressed then
         --  If button B is pressed reset all distress flags ...
         FallDetected := False;
         Panic := False;
      end if;

      -- If fall detected or panic signaled ...
      if FallDetected or Panic then
         Display.Clear;
         Display.Symbols.Frown;
         -- Send BLE beacon packet ...
         Beacon.Send_Beacon_Packet;
         -- Play alarm sound on buzzer ...
         MicroBit.Music.Play (0, Alarm);
         -- For testing only, remove the following section (else branch)
         -- for 'production' to save battery life ...
      else
         Display.Clear;
         case AccelerationState.GetCurrentOrientation is
            when AccelerationState.Left => Display.Symbols.Left_Arrow;
            when AccelerationState.Right =>      Display.Symbols.Right_Arrow;
            when AccelerationState.Up =>  Display.Symbols.Up_Arrow;
            when AccelerationState.Down => Display.Symbols.Down_Arrow;
            when AccelerationState.Forwards => Display.Display('F');
            when AccelerationState.Backwards => Display.Display('B');
            when others => Display.Display ('X');
         end case;
      end if;

      --  Do nothing for 50 milliseconds
      Time.Sleep (50);
   end loop;

end Main;
