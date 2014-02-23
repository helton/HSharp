program Tests.PEG;
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
  HSharp.PEG in '..\HSharp.PEG.pas',
  TestHSharp_PEG in 'TestHSharp_PEG.pas',
  HSharp.WeakReference in '..\..\WeakReferences\HSharp.WeakReference.pas',
  HSharp.Collections.Dictionary in '..\..\Collections\HSharp.Collections.Dictionary.pas',
  HSharp.Collections.Interfaces.Internal in '..\..\Collections\HSharp.Collections.Interfaces.Internal.pas',
  HSharp.Collections.Interfaces in '..\..\Collections\HSharp.Collections.Interfaces.pas',
  HSharp.Collections.Internal in '..\..\Collections\HSharp.Collections.Internal.pas',
  HSharp.Collections.List in '..\..\Collections\HSharp.Collections.List.pas',
  HSharp.Collections in '..\..\Collections\HSharp.Collections.pas',
  HSharp.PEG.Bootstrap in '..\HSharp.PEG.Bootstrap.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

