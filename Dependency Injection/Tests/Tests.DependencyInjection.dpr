program Tests.DependencyInjection;
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
  HSharp.Services in '..\HSharp.Services.pas',
  HSharp.Services.Exceptions in '..\HSharp.Services.Exceptions.pas',
  HSharp.Collections.Dictionary in '..\..\Collections\HSharp.Collections.Dictionary.pas',
  HSharp.Collections.Interfaces.Internal in '..\..\Collections\HSharp.Collections.Interfaces.Internal.pas',
  HSharp.Collections.Interfaces in '..\..\Collections\HSharp.Collections.Interfaces.pas',
  HSharp.Collections.Internal in '..\..\Collections\HSharp.Collections.Internal.pas',
  HSharp.Collections.List in '..\..\Collections\HSharp.Collections.List.pas',
  HSharp.Collections in '..\..\Collections\HSharp.Collections.pas',
  TestHSharp_Services in 'TestHSharp_Services.pas';

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;
  DUnitTestRunner.RunRegisteredTests;
end.

