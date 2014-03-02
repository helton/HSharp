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

unit TestHSharp_DesignPatterns;

interface

uses
  TestFramework,
  HSharp.DesignPatterns.Singleton;

type
  TMyClass = class
  end;

  TestSingleton = class(TTestCase)
  published
    procedure WhenCallInstance_ShouldGetAValidInstance;
    procedure WhenCallInstanceTwice_ShouldReturnTheSameInstance;
  end;

implementation


{ TestSingleton }

procedure TestSingleton.WhenCallInstanceTwice_ShouldReturnTheSameInstance;
var
  S: Singleton<TMyClass>;
  Instance1, Instance2: TMyClass;
begin
  Instance1 := S.Instance;
  Instance2 := S.Instance;
  CheckSame(Instance1, Instance2, 'Singleton 2 diferent instance in 2 calls');
end;

procedure TestSingleton.WhenCallInstance_ShouldGetAValidInstance;
var
  S: Singleton<TMyClass>;
begin
  CheckNotNull(S.Instance, 'Singleton returned a nil instance');
end;

initialization
  RegisterTest('HSharp.DesignPatterns.Singleton', TestSingleton.Suite);

end.

