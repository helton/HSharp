unit HSharp.Collections.Internal;

interface

function InternalQueryInterface(aInstance: TObject; const IID: TGUID; out Obj): HResult; stdcall;
function Internal_AddRef(var aRefCount: Integer): Integer; stdcall;
function Internal_Release(var aRefCount: Integer; var aInstance: TObject): Integer; stdcall;

implementation

function InternalQueryInterface(aInstance: TObject; const IID: TGUID; out Obj): HResult;
begin
  if aInstance.GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function Internal_AddRef(var aRefCount: Integer): Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicIncrement(aRefCount);
{$ELSE}
  Result := __ObjAddRef;
{$ENDIF}
end;

function Internal_Release(var aRefCount: Integer; var aInstance: TObject): Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicDecrement(aRefCount);
  if Result = 0 then
    aInstance.Destroy;
{$ELSE}
  Result := __ObjRelease;
{$ENDIF}
end;

end.
