unit HSharp.Collections.List;

interface

uses
  System.Generics.Collections,
  HSharp.Collections.Interfaces,
  HSharp.Collections.Internal;

type
  TBaseInterfacedList<T> = class abstract(TList<T>)
  strict private
    FRefCount: Integer;
  strict protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TInterfacedListInternal<T> = class(TBaseInterfacedList<T>, IList<T>)
  private
    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
    function GetCapacity: Integer;
    procedure SetCapacity(Value: Integer);
    function GetCount: Integer;
    procedure SetCount(Value: Integer);
  end;

  TInterfacedList<T> = class(TInterfacedListInternal<T>, IList<T>);

implementation

{ TBaseInterfacedList<T> }

function TBaseInterfacedList<T>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := InternalQueryInterface(Self, IID, Obj);
end;

function TBaseInterfacedList<T>._AddRef: Integer;
begin
  Result := Internal_AddRef(FRefCount);
end;

function TBaseInterfacedList<T>._Release: Integer;
begin
  Result := Internal_Release(FRefCount, TObject(Self));
end;

{ TInterfacedListInternal<T> }

function TInterfacedListInternal<T>.GetCapacity: Integer;
begin
  Result := Capacity;
end;

function TInterfacedListInternal<T>.GetCount: Integer;
begin
  Result := Count;
end;

function TInterfacedListInternal<T>.GetItem(Index: Integer): T;
begin
  Result := Items[Index];
end;

procedure TInterfacedListInternal<T>.SetCapacity(Value: Integer);
begin
  Capacity := Value;
end;

procedure TInterfacedListInternal<T>.SetCount(Value: Integer);
begin
  Count := Value;
end;

procedure TInterfacedListInternal<T>.SetItem(Index: Integer; const Value: T);
begin
  Items[Index] := Value;
end;

end.
