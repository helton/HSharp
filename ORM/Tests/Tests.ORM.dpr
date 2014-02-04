program Tests.ORM;
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
  HSharp.Mapping.Exceptions in '..\HSharp.Mapping.Exceptions.pas',
  HSharp.Mapping.Attributes in '..\HSharp.Mapping.Attributes.pas',
  TestHSharp_ORM in 'TestHSharp_ORM.pas',
  Tests.Entities in 'Tests.Entities.pas',
  HSharp.Engine.ObjectManager in '..\HSharp.Engine.ObjectManager.pas',
  HSharp.Mapping.Metadata in '..\HSharp.Mapping.Metadata.pas',
  HSharp.Patterns.UnitOfWork in '..\HSharp.Patterns.UnitOfWork.pas',
  HSharp.Core.Arrays in '..\..\Core\HSharp.Core.Arrays.pas',
  HSharp.Database.Connection.Factory in '..\HSharp.Database.Connection.Factory.pas',
  HSharp.Database.Connection.Firebird in '..\HSharp.Database.Connection.Firebird.pas',
  HSharp.Database.Connection.SQLite in '..\HSharp.Database.Connection.SQLite.pas',
  HSharp.Database.Connection.Interfaces in '..\HSharp.Database.Connection.Interfaces.pas',
  HSharp.Database.Types in '..\HSharp.Database.Types.pas';

{$R *.res}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

