program Tests.Collections;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  HSharp.Collections in '..\HSharp.Collections.pas',
  HSharp.Collections.Interfaces in '..\HSharp.Collections.Interfaces.pas',
  TestHSharp_Collections in 'TestHSharp_Collections.pas',
  HSharp.Collections.Internal in '..\HSharp.Collections.Internal.pas',
  HSharp.Collections.List in '..\HSharp.Collections.List.pas',
  HSharp.Collections.Dictionary in '..\HSharp.Collections.Dictionary.pas',
  HSharp.Collections.Interfaces.Internal in '..\HSharp.Collections.Interfaces.Internal.pas';

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;
  DUnitTestRunner.RunRegisteredTests;
end.

