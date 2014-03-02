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

unit HSharp.Behaviour.Interfaces;

interface

uses
  System.Rtti;

type
  IBehaviour<T> = interface
    ['{F0D26FAA-04AE-4C7F-A77A-D2F896DB06B9}']
    function GetMethod: TRttiMethod;
    procedure SetMethod(const aMethod: TRttiMethod);
    property Method: TRttiMethod read GetMethod write SetMethod;
  end;

  IBehaviourExecuteMethod<T, M> = interface(IBehaviour<T>)
    ['{353D7E0E-669A-4FC5-BFA1-DF1F1FA1B542}']
    function GetMethodWillBeExecuted: M;
    property MethodWillBeExecuted: M read GetMethodWillBeExecuted;
  end;

  IBehaviourReturnValue<T> = interface(IBehaviour<T>)
    ['{353D7E0E-669A-4FC5-BFA1-DF1F1FA1B542}']
    function GetExpectedResult: TValue;
    property ExpectedResult: TValue read GetExpectedResult;
  end;


implementation

end.
