program Tests.Mocks;
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
  TestHSharp_Mock in 'TestHSharp_Mock.pas',
  HSharp.Behaviour.Interfaces in '..\HSharp.Behaviour.Interfaces.pas',
  HSharp.Behaviour in '..\HSharp.Behaviour.pas',
  HSharp.Exceptions in '..\HSharp.Exceptions.pas',
  HSharp.Mock.Interfaces in '..\HSharp.Mock.Interfaces.pas',
  HSharp.Mock in '..\HSharp.Mock.pas',
  HSharp.Proxy.Interfaces in '..\HSharp.Proxy.Interfaces.pas',
  HSharp.Proxy in '..\HSharp.Proxy.pas',
  HSharp.Stub.Interfaces in '..\HSharp.Stub.Interfaces.pas',
  HSharp.Stub in '..\HSharp.Stub.pas',
  HSharp.WeakReference in '..\..\WeakReferences\HSharp.WeakReference.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  DUnitTestRunner.RunRegisteredTests;
end.

