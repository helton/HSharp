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

unit HSharp.Core.Wrapper;

interface

type
  IWrapper<T> = interface
    ['{B8BF7123-1FCE-4452-B68C-893FFF378DDE}']
    function GetInstance: T;
    procedure SetInstance(const Value: T);
    property Instance: T read GetInstance write SetInstance;
  end;

  TWrapper<T> = class(TInterfacedObject, IWrapper<T>)
  strict private
    FInstance: T;
  strict protected
    function GetInstance: T;
    procedure SetInstance(const Value: T);
  end;

implementation

{ TWrapper<T> }

function TWrapper<T>.GetInstance: T;
begin
  Result := FInstance;
end;

procedure TWrapper<T>.SetInstance(const Value: T);
begin
  FInstance := Value;
end;

end.
