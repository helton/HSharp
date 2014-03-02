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

unit HSharp.Mock.Interfaces;

interface

uses
  System.Rtti;

type
  IMock<T> = interface
    ['{B74A1A0F-64CF-4E4F-B82A-46BAE8A5E880}']
  end;

  IWhen<T> = interface
    ['{7668A5DE-4A18-4AEA-BAF4-770B894BBF08}']
    function When: T;
  end;

  ISetup<T> = interface
    ['{07115CE3-C487-4E7C-985C-B1ED710F46B7}']
    function WillReturn(aValue: TValue): IWhen<T>;
  end;

implementation

end.
