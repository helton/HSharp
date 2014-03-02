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
