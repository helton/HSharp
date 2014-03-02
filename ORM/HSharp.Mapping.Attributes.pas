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

unit HSharp.Mapping.Attributes;

interface

type
  Table = class(TCustomAttribute)
  private
    FTableName: string;
  public
    constructor Create(aTableName: string);
  end;

  Column = class(TCustomAttribute)
  private
    FColumnName: string;
  public
    constructor Create(aColumnName: string);
  end;

  Entity = class(TCustomAttribute);

  Automapping = class(TCustomAttribute);

implementation

{ Table }

constructor Table.Create(aTableName: string);
begin
  inherited Create;
  FTableName := aTableName;
end;

{ Column }

constructor Column.Create(aColumnName: string);
begin
  inherited Create;
  FColumnName := aColumnName;
end;

end.
