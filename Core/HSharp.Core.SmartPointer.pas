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

unit HSharp.Core.SmartPointer;

interface

uses
  System.SysUtils;

type
  ISmartPointer<T> = reference to function: T;

  TSmartPointer<T: class, constructor> = class(TInterfacedObject, ISmartPointer<T>)
  private
    FValue: T;
  public
    constructor Create; overload;
    constructor Create(aValue: T); overload;
    destructor Destroy; override;
    function Invoke: T;
  end;

implementation

uses
  HSharp.Core.Functions;

{ TSmartPointer<T> }

constructor TSmartPointer<T>.Create;
begin
  inherited;
  FValue := T.Create;
end;

constructor TSmartPointer<T>.Create(aValue: T);
begin
  inherited Create;
  if AValue = nil then
    FValue := Generics.GetNewInstance<T>
  else
    FValue := aValue;
end;

destructor TSmartPointer<T>.Destroy;
begin
  FValue.Free;
  inherited;
end;

function TSmartPointer<T>.Invoke: T;
begin
  Result := FValue;
end;

end.
