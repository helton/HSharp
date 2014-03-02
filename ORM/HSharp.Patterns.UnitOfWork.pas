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

unit HSharp.Patterns.UnitOfWork;

interface

uses
  System.Rtti,
  HSharp.Core.Arrays;

type
  TUnitOfWork = class
    function IsLoaded<T: class, constructor>(const AKeys: TArray<TValue>): Boolean;
    function Get<T: class, constructor>(const AKeys: TArray<TValue>): T;
  end;

implementation

{ TUnitOfWork }

function TUnitOfWork.Get<T>(const AKeys: TArray<TValue>): T;
begin

end;

function TUnitOfWork.IsLoaded<T>(const AKeys: TArray<TValue>): Boolean;
begin

end;

end.
