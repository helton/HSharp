unit HSharp.Database.Connection.Setup;

interface

uses
  HSharp.Database.Connection.Interfaces;

type
  TConnectionSetup = class(TInterfacedObject, IConnectionSetup)
  private
    FDatabase: string;
    FServer: string;
    FPort: Integer;
    FUsername: string;
    FPassword: string;
  public
    function Database(aDatabase: string): IConnectionSetup;
    function Server(aServer: string): IConnectionSetup;
    function Port(aPort: Integer): IConnectionSetup;
    function Username(aUserName: string): IConnectionSetup;
    function Password(aPassword: string): IConnectionSetup;
  end;

implementation

{ TConnectionSetup }

function TConnectionSetup.Database(aDatabase: string): IConnectionSetup;
begin
  FDatabase := aDatabase;
  Result := Self;
end;

function TConnectionSetup.Password(aPassword: string): IConnectionSetup;
begin
  FPassword := aPassword;
  Result := Self;
end;

function TConnectionSetup.Port(aPort: Integer): IConnectionSetup;
begin
  FPort := aPort;
  Result := Self;
end;

function TConnectionSetup.Server(aServer: string): IConnectionSetup;
begin
  FServer := aServer;
  Result := Self;
end;

function TConnectionSetup.Username(aUserName: string): IConnectionSetup;
begin
  FUserName := aUserName;
  Result := Self;
end;

end.
