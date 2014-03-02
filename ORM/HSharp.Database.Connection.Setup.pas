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
