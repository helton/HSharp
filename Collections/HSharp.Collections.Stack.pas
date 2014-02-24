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
