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

unit HSharp.Core.Lazy;

interface

type
  Lazy<I: IInterface; T: class, constructor> = record
  private
    FInstance: I;
  public
    function Instance: I;
    class operator Implicit(const aLazy: Lazy<I, T>): I;
    class operator Implicit(const aInstance: I): Lazy<I, T>;
  end;

implementation

uses
  System.SysUtils,
  HSharp.Core.Functions;

{ Lazy<I, T> }

class operator Lazy<I, T>.Implicit(const aLazy: Lazy<I, T>): I;
begin
  Result := aLazy.Instance;
end;

class operator Lazy<I, T>.Implicit(const aInstance: I): Lazy<I, T>;
begin
  Result.FInstance := aInstance;
end;

function Lazy<I, T>.Instance: I;
var
  Obj: T;
begin
  if not Assigned(FInstance) then
  begin
    Obj := Generics.GetNewInstance<T>;
    Supports(Obj, Generics.InterfaceToGuid<I>, FInstance);
  end;
  Result := FInstance;
end;

end.
