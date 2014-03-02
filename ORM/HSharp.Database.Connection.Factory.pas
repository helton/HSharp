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

unit HSharp.Database.Connection.Factory;

interface

uses
  System.Generics.Collections,
  HSharp.Database.Types,
  HSharp.Database.Connection.Interfaces;

type
  DatabaseConnectionManagerFactory = class
  private
    class var
      FDBTypes: TDictionary<TDBType, IConnectionManager>;
  public
    class constructor Create;
    class destructor Destroy;
    class function GetConnectionManager(aDBType: TDBType): IConnectionManager;
    class procedure RegisterConnectionManager(aDBType: TDBType; aConnection: IConnectionManager);
  end;

var
  CurrentConnection: IConnection;

implementation

{ DatabaseConnectionFactory }

class constructor DatabaseConnectionManagerFactory.Create;
begin
  FDBTypes := TDictionary<TDBType, IConnectionManager>.Create;
end;

class destructor DatabaseConnectionManagerFactory.Destroy;
begin
  FDBTypes.Free;
end;

class function DatabaseConnectionManagerFactory.GetConnectionManager(
  aDBType: TDBType): IConnectionManager;
begin
  FDBTypes.TryGetValue(aDBType, Result);
end;

class procedure DatabaseConnectionManagerFactory.RegisterConnectionManager(aDBType: TDBType;
  aConnection: IConnectionManager);
begin
  FDBTypes.Add(aDBType, aConnection);
end;

initialization
  CurrentConnection := DatabaseConnectionManagerFactory
    .GetConnectionManager(TDBType.Firebird)
    .GetConnection;
  CurrentConnection.Setup
    .Database('C:\Databases\BugTracker.fdb')
    .Username('SYSDBA')
    .Password('masterkey')
    .Server('127.0.0.1')
    .Port(3050);
  CurrentConnection.Connect;

end.
