{***************************************************************************}
{                                                                           }
{           HSharp Framework for Delphi                                     }
{                                                                           }
{           Copyright (C) 2014 Helton Carlos de Souza                       }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit HSharp.Database.Connection.Firebird;

interface

uses
  HSharp.Database.Types,
  HSharp.Database.Connection.Factory,
  HSharp.Database.Connection.Interfaces,
  HSharp.Database.Connection.Setup,
  Data.SqlExpr;

type
  TFirebirdDatabaseConnectionManager = class(TInterfacedObject,
    IConnectionManager)
  public
    { IConnectionManager }
    function GetConnection: IConnection;
  end;

implementation

uses
  System.SysUtils;

type
  TFirebirdDatabaseConnection = class(TInterfacedObject, IConnection, IConnectionSetup)
  private
    FSQLConnection: TSQLConnection;
  public
    constructor Create;
    destructor Destroy; override;
    { IConnection }
    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;
    function Setup: IConnectionSetup;
    { IConnectionSetup }
    function Database(aDatabase: string): IConnectionSetup;
    function Server(aServer: string): IConnectionSetup;
    function Port(aPort: Integer): IConnectionSetup;
    function Username(aUserName: string): IConnectionSetup;
    function Password(aPassword: string): IConnectionSetup;
  end;

{ TFirebirdDatabaseConnection }

procedure TFirebirdDatabaseConnection.Connect;
begin
  FSQLConnection.Connected := True;
end;

constructor TFirebirdDatabaseConnection.Create;
begin
  inherited;
  FSQLConnection := TSQLConnection.Create(nil);
end;

function TFirebirdDatabaseConnection.Database(
  aDatabase: string): IConnectionSetup;
begin
  FSQLConnection.Params.Values['Database'] := aDatabase;
  Result := Self;
end;

destructor TFirebirdDatabaseConnection.Destroy;
begin
  FSQLConnection.Free;
  inherited;
end;

procedure TFirebirdDatabaseConnection.Disconnect;
begin
  FSQLConnection.Connected := False;
end;

function TFirebirdDatabaseConnection.IsConnected: Boolean;
begin
  Result := FSQLConnection.Connected;
end;

function TFirebirdDatabaseConnection.Password(
  aPassword: string): IConnectionSetup;
begin
  FSQLConnection.Params.Values['Password'] := aPassword;
  Result := Self;
end;

function TFirebirdDatabaseConnection.Port(aPort: Integer): IConnectionSetup;
begin
  FSQLConnection.Params.Values['Port'] := aPort.ToString;
  Result := Self;
end;

function TFirebirdDatabaseConnection.Server(aServer: string): IConnectionSetup;
begin
  FSQLConnection.Params.Values['Server'] := aServer;
  Result := Self;
end;

function TFirebirdDatabaseConnection.Setup: IConnectionSetup;

  procedure SetupBasicSettings;
  begin
{
  object SQLConnection1: TSQLConnection
    DriverName = 'Firebird'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DBXFirebird'

        'DriverPackageLoader=TDBXDynalinkDriverLoader,DbxCommonDriver190.' +
        'bpl'

        'DriverAssemblyLoader=Borland.Data.TDBXDynalinkDriverLoader,Borla' +
        'nd.Data.DbxCommonDriver,Version=19.0.0.0,Culture=neutral,PublicK' +
        'eyToken=91d62ebb5b0d1b1b'

        'MetaDataPackageLoader=TDBXFirebirdMetaDataCommandFactory,DbxFire' +
        'birdDriver190.bpl'

        'MetaDataAssemblyLoader=Borland.Data.TDBXFirebirdMetaDataCommandF' +
        'actory,Borland.Data.DbxFirebirdDriver,Version=19.0.0.0,Culture=n' +
        'eutral,PublicKeyToken=91d62ebb5b0d1b1b'
      'GetDriverFunc=getSQLDriverINTERBASE'
      'LibraryName=dbxfb.dll'
      'LibraryNameOsx=libsqlfb.dylib'
      'VendorLib=fbclient.dll'
      'VendorLibWin64=fbclient.dll'
      'VendorLibOsx=/Library/Frameworks/Firebird.framework/Firebird'
      'Database=C:\Databases\BugTracker.fdb'
      'User_Name=sysdba'
      'Password=masterkey'
      'Role=RoleName'
      'MaxBlobSize=-1'
      'LocaleCode=0000'
      'IsolationLevel=ReadCommitted'
      'SQLDialect=3'
      'CommitRetain=False'
      'WaitOnLocks=True'
      'TrimChar=False'
      'BlobSize=-1'
      'ErrorResourceFile='
      'RoleName=RoleName'
      'ServerCharSet='
      'Trim Char=False')
}
    FSQLConnection.DriverName := 'Firebird';
    FSQLConnection.LoginPrompt := False;
  end;

begin
  SetupBasicSettings;
  Result := Self;
end;

function TFirebirdDatabaseConnection.Username(
  aUserName: string): IConnectionSetup;
begin
  FSQLConnection.Params.Values['User_Name'] := aUserName;
  Result := Self;
end;

{ TFirebirdDatabaseConnectionManager }

function TFirebirdDatabaseConnectionManager.GetConnection: IConnection;
begin
  Result := TFirebirdDatabaseConnection.Create;
end;

initialization
  DatabaseConnectionManagerFactory.RegisterConnectionManager(TDBType.Firebird,
    TFirebirdDatabaseConnectionManager.Create);

end.
