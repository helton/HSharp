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

unit HSharp.Proxy.Interfaces;

interface

uses
  HSharp.Behaviour.Interfaces;

type
  IProxyStrategy<T> = interface(IInvokable)
    ['{CE969732-65CB-401C-A9C5-3E164762B5C3}']
    function GetInstance: T;
    property Instance: T read GetInstance;
  end;

  IProxy<T> = interface(IProxyStrategy<T>)
    ['{FDD5E9BF-A538-40F5-BDC1-FF4C5180D69B}']
    procedure SetProxyStrategy(aProxyStrategy: IProxyStrategy<T>);
    procedure SetCurrentBehaviour(aBehaviour: IBehaviour<T>);
    procedure AddBehaviour(aBehaviour: IBehaviour<T>);
  end;

implementation

end.
