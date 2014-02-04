program Tests.Core;
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
  HSharp.Core.Arrays in '..\HSharp.Core.Arrays.pas',
  HSharp.Core.Assert in '..\HSharp.Core.Assert.pas',
  HSharp.Core.Benchmarker in '..\HSharp.Core.Benchmarker.pas',
  HSharp.Core.Memoize in '..\HSharp.Core.Memoize.pas',
  HSharp.Core.Nullable in '..\HSharp.Core.Nullable.pas',
  HSharp.Core.Version in '..\HSharp.Core.Version.pas',
  DUnitTestRunner,
  TestHSharp_Core_Version in 'TestHSharp_Core_Version.pas';

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;
  DUnitTestRunner.RunRegisteredTests;
end.

