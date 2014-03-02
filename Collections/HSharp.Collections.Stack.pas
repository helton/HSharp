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

unit HSharp.Collections.Stack;

interface

uses
  System.Generics.Collections,
  HSharp.Collections.Interfaces,
  HSharp.Collections.Internal;

type
  TBaseInterfacedStack<T> = class abstract(TStack<T>)
  strict private
    FRefCount: Integer;
  strict protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TInterfacedStackInternal<T> = class(TBaseInterfacedStack<T>, IStack<T>)
  private
    function GetCapacity: Integer;
    procedure SetCapacity(Value: Integer);
    function GetCount: Integer;
  end;

  TInterfacedStack<T> = class(TInterfacedStackInternal<T>, IStack<T>);

implementation

{ TBaseInterfacedStack<T> }

function TBaseInterfacedStack<T>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := InternalQueryInterface(Self, IID, Obj);
end;

function TBaseInterfacedStack<T>._AddRef: Integer;
begin
  Result := Internal_AddRef(FRefCount);
end;

function TBaseInterfacedStack<T>._Release: Integer;
begin
  Result := Internal_Release(FRefCount, TObject(Self));
end;

{ TInterfacedStackInternal<T> }

function TInterfacedStackInternal<T>.GetCapacity: Integer;
begin
  Result := Capacity;
end;

function TInterfacedStackInternal<T>.GetCount: Integer;
begin
  Result := Count;
end;

procedure TInterfacedStackInternal<T>.SetCapacity(Value: Integer);
begin
  Capacity := Value;
end;

end.
