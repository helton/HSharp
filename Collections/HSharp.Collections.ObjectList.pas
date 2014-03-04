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

unit HSharp.Collections.ObjectList;

interface

uses
  System.Generics.Collections,
  HSharp.Collections.Interfaces,
  HSharp.Collections.Internal;

type
  TBaseInterfacedObjectList<T: class> = class abstract(TObjectList<T>)
  strict private
    FRefCount: Integer;
  strict protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TInterfacedObjectListInternal<T: class> = class(TBaseInterfacedObjectList<T>, IObjectList<T>)
  private
    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
    function GetCapacity: Integer;
    procedure SetCapacity(Value: Integer);
    function GetCount: Integer;
    procedure SetCount(Value: Integer);
  end;

  TInterfacedObjectList<T: class> = class(TInterfacedObjectListInternal<T>, IObjectList<T>);

implementation

{ TBaseInterfacedObjectList<T> }

function TBaseInterfacedObjectList<T>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := InternalQueryInterface(Self, IID, Obj);
end;

function TBaseInterfacedObjectList<T>._AddRef: Integer;
begin
  Result := Internal_AddRef(Self, FRefCount);
end;

function TBaseInterfacedObjectList<T>._Release: Integer;
begin
  Result := Internal_Release(Self, FRefCount);
end;

{ TInterfacedObjectListInternal<T> }

function TInterfacedObjectListInternal<T>.GetCapacity: Integer;
begin
  Result := Capacity;
end;

function TInterfacedObjectListInternal<T>.GetCount: Integer;
begin
  Result := Count;
end;

function TInterfacedObjectListInternal<T>.GetItem(Index: Integer): T;
begin
  Result := Items[Index];
end;

procedure TInterfacedObjectListInternal<T>.SetCapacity(Value: Integer);
begin
  Capacity := Value;
end;

procedure TInterfacedObjectListInternal<T>.SetCount(Value: Integer);
begin
  Count := Value;
end;

procedure TInterfacedObjectListInternal<T>.SetItem(Index: Integer; const Value: T);
begin
  Items[Index] := Value;
end;

end.
