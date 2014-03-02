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

unit HSharp.Container.Exceptions;

interface

uses
  System.TypInfo,
  System.SysUtils;

type
  ENotRegisteredType = class(Exception)
  public
    constructor Create(aTypeInfo: PTypeInfo); reintroduce;
  end;

  ETypeAlreadyRegistered = class(Exception)
  public
    constructor Create(aTypeInfo: PTypeInfo); reintroduce;
  end;

implementation

uses
  System.Rtti;

{ ENotRegisteredType }

constructor ENotRegisteredType.Create(aTypeInfo: PTypeInfo);
begin
  inherited Create(Format('Type not registered yet to interface "%s"',
                   [aTypeInfo.Name]));
end;

{ ETypeAlreadyRegistered }

constructor ETypeAlreadyRegistered.Create(aTypeInfo: PTypeInfo);
begin
  inherited Create(Format('Type already registered to interface "%s"',
                   [aTypeInfo.Name]));
end;

end.
