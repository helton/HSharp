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

unit HSharp.Container.Interfaces;

interface

uses
  System.Rtti,
  HSharp.Container.Types;

type
  IRegistrationInfo = interface
    ['{585073EE-B872-4563-A0EA-9F0F9076ED4E}']
    function GetInstance: TValue;
  end;

  IImplementsType<T: class, constructor> = interface
    ['{63F2078A-3E7F-4F9A-AC7F-A1F604995AF4}']
    procedure AsTransient;
    procedure AsSingleton;
    procedure DelegateTo(const aDelegate: TActivatorDelegate<T>);
  end;

  IRegistrationType<T: class, constructor> = interface
    ['{198C5BBB-B420-448C-BDBC-7AD3CBF6093C}']
    function Implements(aIntfGuid: TGuid): IImplementsType<T>;
  end;

implementation

end.
