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

unit HSharp.Core.Functions;

interface

type
  Generics = class
  public
    class function InterfaceToGuid<I: IInterface>: TGuid;
    class function CreateInstance<T: class, constructor>: T;
  end;

implementation

uses
  System.Rtti,
  System.TypInfo;

{ Generics }

class function Generics.InterfaceToGuid<I>: TGuid;
begin
  Result := GetTypeData(TypeInfo(I)).Guid;
end;

class function Generics.CreateInstance<T>: T;
var
  RttiType: TRttiType;
  ConstructorMethod: TRttiMethod;
begin
  Result := nil;
  RttiType := TRttiContext.Create.GetType(T);
  if Assigned(RttiType) then
  begin
    ConstructorMethod := RttiType.GetMethod('Create');
    if Assigned(ConstructorMethod) then
      Result := ConstructorMethod.Invoke(RttiType.AsInstance.MetaclassType,
                                         []).asType<T>;
  end;
  if not Assigned(Result) then
    Result := T.Create;
end;

end.
