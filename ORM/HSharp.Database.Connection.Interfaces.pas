unit HSharp.Database.Connection.Interfaces;

interface

type
  IConnectionSetup = interface
    ['{177AF6C2-70B5-4C19-95D9-2BB45B577B39}']
    function Database(aDatabase: string): IConnectionSetup;
    function Server(aServer: string): IConnectionSetup;
    function Port(aPort: Integer): IConnectionSetup;
    function Username(aUserName: string): IConnectionSetup;
    function Password(aPassword: string): IConnectionSetup;
  end;

  IResultSet = interface
    ['{5CE2C735-5F85-471F-AD63-3B5BA88601F0}']
//    function Next: Boolean;
//    function GetFieldValue(FieldIndex: Integer): Variant; overload;
//    function GetFieldValue(FieldName: string): Variant; overload;
  end;

  IStatement = interface
    ['{75B85DAC-91C9-43FE-8D50-BBDF83A210A5}']
    procedure SetSQLCommand(aSQLCommand: string);
//    procedure SetParams(aParams: TEnumerable<TDBParam>);
    procedure Execute;
//    function ExecuteQuery: IResultSet;
  end;

  IConnection = interface
    ['{FC6CFC84-F970-408A-B002-CF78861B7BD3}']
    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;
    function Setup: IConnectionSetup;
//    function CreateStatement: IStatement;
{    function BeginTransaction: IDBTransaction;
    function SqlDialect: string;}
  end;

  IConnectionManager = interface
   ['{7A93DA9A-51A3-4598-A7EF-DB05A3EB541C}']
   function GetConnection: IConnection;
  end;

implementation

end.
