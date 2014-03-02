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

unit HSharp.Collections;

interface

uses
  HSharp.Collections.Interfaces,
  HSharp.Collections.Dictionary,
  HSharp.Collections.List,
  HSharp.Collections.Stack;

type
  Collections = class
  public
    class function CreateList<T>: IList<T>;
    class function CreateDictionary<TKey,TValue>: IDictionary<TKey,TValue>;
    class function CreateStack<T>: IStack<T>;
  end;

implementation

{ Collections }

class function Collections.CreateDictionary<TKey, TValue>: IDictionary<TKey,TValue>;
begin
  Result := TInterfacedDictionary<TKey,TValue>.Create;
end;

class function Collections.CreateList<T>: IList<T>;
begin
  Result := TInterfacedList<T>.Create;
end;

class function Collections.CreateStack<T>: IStack<T>;
begin
  Result := TInterfacedStack<T>.Create;
end;

end.
