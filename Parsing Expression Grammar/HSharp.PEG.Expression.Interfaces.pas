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

unit HSharp.PEG.Expression.Interfaces;

interface

uses
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Node.Interfaces;

type
  IExpression = interface
    ['{62F4F422-597B-4B06-AED9-109236BCF845}']
    procedure SetName(const aName: string);
    function GetName: string;
    function IsMatch(const aContext: IContext): Boolean;
    function Match(const aContext: IContext): INode;
    function AsString: string;
    property Name: string read GetName write SetName;
  end;

implementation

end.
