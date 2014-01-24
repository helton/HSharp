{
  # Author: Craig Stuntz
  # Links:
     http://blogs.teamb.com/craigstuntz/2008/10/01/37839/
     http://cc.embarcadero.com/item/26106
}

unit HSharp.Core.Memoize;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils;

type
  ENotImplemented = class(Exception);

  IDictionary<TKey,TValue> = interface
    ['{4A15EB4C-9FA5-4781-B910-F8E110519C6E}']
    procedure Add(const Key: TKey; const Value: TValue);
    function TryGetValue(const Key: TKey; out Value: TValue): Boolean;
  end;

  IList<T> = interface
    ['{D151E641-3ED6-4293-BBBA-165F999560F1}']
    function Add(const Value: T): Integer;
    function Contains(const Value: T): Boolean;
  end;

  TManagedDictionary<TKey,TValue> = class(TDictionary<TKey,TValue>, IDictionary<TKey,TValue>)
  protected
    FRefCount: Integer;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TManagedList<T> = class(TList<T>, IList<T>)
    FRefCount: Integer;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TMemoize = class
  public
    class function Memoize<TResult>(AFunc: TFunc<TResult>): TFunc<TResult>; overload;
    class function Memoize<T,TResult>(AFunc: TFunc<T,TResult>): TFunc<T,TResult>; overload;
    class function Memoize<T1,T2,TResult>(AFunc: TFunc<T1,T2,TResult>): TFunc<T1,T2,TResult>; overload;
    class function Memoize<T1,T2,T3,TResult>(AFunc: TFunc<T1,T2,T3,TResult>): TFunc<T1,T2,T3,TResult>; overload;
    class function Memoize<T1,T2,T3,T4,TResult>(AFunc: TFunc<T1,T2,T3,T4,TResult>): TFunc<T1,T2,T3,T4,TResult>; overload;
  end;

implementation

uses
  Winapi.Windows;

{ TManagedList<T> }

function TManagedList<T>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TManagedList<T>._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TManagedList<T>._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

{ TManagedDictionary<TKey, TValue> }

function TManagedDictionary<TKey, TValue>.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TManagedDictionary<TKey,TValue>._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TManagedDictionary<TKey,TValue>._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

{ TMemoize }

class function TMemoize.Memoize<TResult>(AFunc: TFunc<TResult>): TFunc<TResult>;
var
  Map: IList<TResult>;
begin
  Map    := TManagedList<TResult>.Create;
  Result :=
    function: TResult
    var
      FuncResult: TResult;
    begin
      if Map.Contains(FuncResult) then
        Exit(FuncResult);
      FuncResult := AFunc;
      Map.Add(FuncResult);
      Exit(FuncResult);
    end;
end;

class function TMemoize.Memoize<T, TResult>(
  AFunc: TFunc<T, TResult>): TFunc<T, TResult>;
var
  Map: IDictionary<T, TResult>;
begin
  Map    := TManagedDictionary<T, TResult>.Create;
  Result :=
    function(aArg: T): TResult
    var
      FuncResult: TResult;
    begin
      if Map.TryGetValue(aArg, FuncResult) then
        Exit(FuncResult);
      FuncResult := AFunc(aArg);
      Map.Add(aArg, FuncResult);
      Exit(FuncResult);
    end;
end;

class function TMemoize.Memoize<T1, T2, TResult>(
  AFunc: TFunc<T1, T2, TResult>): TFunc<T1, T2, TResult>;
begin
  raise ENotImplemented.Create('Feature not implemented yet');
end;

class function TMemoize.Memoize<T1, T2, T3, TResult>(
  AFunc: TFunc<T1, T2, T3, TResult>): TFunc<T1, T2, T3, TResult>;
begin
  raise ENotImplemented.Create('Feature not implemented yet');
end;

class function TMemoize.Memoize<T1, T2, T3, T4, TResult>(
  AFunc: TFunc<T1, T2, T3, T4, TResult>): TFunc<T1, T2, T3, T4, TResult>;
begin
  raise ENotImplemented.Create('Feature not implemented yet');
end;

end.
