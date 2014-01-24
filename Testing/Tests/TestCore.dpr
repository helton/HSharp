program TestCore;
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
  HSharp.Core.Assert in '..\..\Core\HSharp.Core.Assert.pas',
  HSharp.Core.Benchmarker in '..\..\Core\HSharp.Core.Benchmarker.pas',
  HSharp.Core.Arrays in '..\..\Core\HSharp.Core.Arrays.pas',
  HSharp.Core.Version in '..\..\Core\HSharp.Core.Version.pas',
  HSharp.Core.Memoize in '..\..\Core\HSharp.Core.Memoize.pas',
  HSharp.Core.Nullable in '..\..\Core\HSharp.Core.Nullable.pas',
  HSharp.Core.TypeCast in '..\..\Core\HSharp.Core.TypeCast.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

