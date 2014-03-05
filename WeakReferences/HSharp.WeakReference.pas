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

unit HSharp.WeakReference;

interface

type
  Weak<I: IInterface> = record
  private
    FInstance: TInterfacedObject;
  public
    class operator Implicit(const aWeak: Weak<I>): I;
    class operator Implicit(const aValue: I): Weak<I>;
  end;

implementation

uses
  System.SysUtils,
  HSharp.Core.Functions;

{ Weak<T> }

class operator Weak<I>.Implicit(const aWeak: Weak<I>): I;
begin
  Supports(aWeak.FInstance, Generics.InterfaceToGuid<I>, Result);
end;

class operator Weak<I>.Implicit(const aValue: I): Weak<I>;
begin
  Result.FInstance := TInterfacedObject(aValue);
end;

end.
