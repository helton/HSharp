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

unit HSharp.Mapping.Metadata;

interface

uses
  System.Generics.Collections,
  System.Rtti,
  HSharp.Core.Arrays,
  HSharp.Database.Types,
  HSharp.Database.Connection.Factory,
  HSharp.Patterns.UnitOfWork;

type
  TColumnMap = class;

  TDataMap = class
  private
    FDomainClass: TRttiClass;
    FTableName: string;
    FColumnMaps: TList<TColumnMap>;
  public
    constructor Create;
    destructor Destroy; override;
  public
    property TableName: string read FTableName;
    property ColumnMaps: TList<TColumnMap> read FColumnMaps;
  public
    function ColumnList: string;
  end;

  TColumnMap = class
  private
    FProperty: TRttiProperty;
    FColumnName: string;
    FDataMap: TDataMap;
  end;

  TMapper = class
  private
    FDataMap: TDataMap;
    FUnitOfWork: TUnitOfWork;
  public
    function Find<T: class, constructor>(const AKeys: TArray<TValue>): T;
  end;

implementation

{ TDataMap }

function TDataMap.ColumnList: string;
begin
  {}
end;

constructor TDataMap.Create;
begin
  inherited;
  FColumnMaps := TList<TColumnMap>.Create;
end;

destructor TDataMap.Destroy;
begin
  FColumnMaps.Free;
  inherited;
end;

{ TMapper }

function TMapper.Find<T>(const AKeys: TArray<TValue>): T;
var
  Sql: string;
begin
  if FUnitOfWork.IsLoaded<T>(AKeys) then
    FUnitOfWork.Get<T>(AKeys)
  else
  begin
    Sql := 'SELECT ' + FDataMap.ColumnList +
           '  FROM ' + FDataMap.TableName +
           ' WHERE ';
//    CurrentConnection{.Query(Sql).Open)}
  end;
end;

end.
