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

unit HSharp.PEG.Context.Interfaces;

interface

type
  IContext = interface
    ['{BCCB62C1-06A3-4678-8D53-0A030952FC81}']
    procedure IncIndex(aOffset: Integer);
    procedure SaveState;
    procedure RestoreState;
    { Property accessors }
    function GetIndex: Integer;
    function GetText: string;
    { Properties }
    property Index: Integer read GetIndex;
    property Text: string read GetText;
  end;

implementation

end.
