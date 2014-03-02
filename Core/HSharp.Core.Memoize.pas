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
  System.SysUtils,
  HSharp.Collections,
  HSharp.Collections.Interfaces;

type
  ENotImplemented = class(Exception);

  TMemoize = class
  public
    class function Memoize<TResult>(AFunc: TFunc<TResult>): TFunc<TResult>; overload;
    class function Memoize<T,TResult>(AFunc: TFunc<T,TResult>): TFunc<T,TResult>; overload;
    class function Memoize<T1,T2,TResult>(AFunc: TFunc<T1,T2,TResult>): TFunc<T1,T2,TResult>; overload;
    class function Memoize<T1,T2,T3,TResult>(AFunc: TFunc<T1,T2,T3,TResult>): TFunc<T1,T2,T3,TResult>; overload;
    class function Memoize<T1,T2,T3,T4,TResult>(AFunc: TFunc<T1,T2,T3,T4,TResult>): TFunc<T1,T2,T3,T4,TResult>; overload;
  end;

implementation

{ TMemoize }

class function TMemoize.Memoize<TResult>(AFunc: TFunc<TResult>): TFunc<TResult>;
var
  Map: IList<TResult>;
begin
  Map    := Collections.CreateList<TResult>;
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
  Map    := Collections.CreateDictionary<T, TResult>;
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
