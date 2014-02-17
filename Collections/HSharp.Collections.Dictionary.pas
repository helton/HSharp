unit HSharp.Collections.Dictionary;

interface

uses
  System.Generics.Collections,
  HSharp.Collections.Interfaces,
  HSharp.Collections.Internal;

type
  TBaseInterfacedDictionary<TKey,TValue> = class abstract(TDictionary<TKey,TValue>)
  strict private
    FRefCount: Integer;
  strict protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TInterfacedDictionaryInternal<TKey,TValue> = class(TBaseInterfacedDictionary<TKey,TValue>, IDictionary<TKey,TValue>)
  private
    function GetItem(const Key: TKey): TValue;
    procedure SetItem(const Key: TKey; const Value: TValue);
    function GetCount: Integer;
    function GetKeys: TDictionary<TKey,TValue>.TKeyCollection;
    function GetValues: TDictionary<TKey,TValue>.TValueCollection;
  end;

  TInterfacedDictionary<TKey,TValue> = class(TInterfacedDictionaryInternal<TKey,TValue>, IDictionary<TKey,TValue>);

implementation

{ TBaseInterfacedDictionary<TKey,TValue> }

function TBaseInterfacedDictionary<TKey,TValue>.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  Result := InternalQueryInterface(Self, IID, Obj);
end;

function TBaseInterfacedDictionary<TKey,TValue>._AddRef: Integer;
begin
  Result := Internal_AddRef(FRefCount);
end;

function TBaseInterfacedDictionary<TKey,TValue>._Release: Integer;
begin
  Result := Internal_Release(FRefCount, TObject(Self));
end;

{ TInterfacedDictionaryInternal<TKey, TValue> }

function TInterfacedDictionaryInternal<TKey, TValue>.GetCount: Integer;
begin
  Result := Count;
end;

function TInterfacedDictionaryInternal<TKey, TValue>.GetItem(const Key: TKey): TValue;
begin
  Result := Items[Key];
end;

function TInterfacedDictionaryInternal<TKey, TValue>.GetKeys: TDictionary<TKey, TValue>.TKeyCollection;
begin
  Result := Keys;
end;

function TInterfacedDictionaryInternal<TKey, TValue>.GetValues: TDictionary<TKey, TValue>.TValueCollection;
begin
  Result := Values;
end;

procedure TInterfacedDictionaryInternal<TKey, TValue>.SetItem(const Key: TKey;
  const Value: TValue);
begin
  Items[Key] := Value;
end;

end.
