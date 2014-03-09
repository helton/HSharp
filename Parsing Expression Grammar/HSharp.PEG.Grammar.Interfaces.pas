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

unit HSharp.PEG.Grammar.Interfaces;

interface

uses
  System.Rtti,
  HSharp.Core.ArrayString,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Rule.Interfaces;

type
  IBaseGrammar = interface
    ['{E1A9FA2D-86A4-4EEB-969A-0DE8C36848FF}']
    function AsString: string;
    function Parse(const aText: string): INode;
    function ParseAndVisit(const aText: string): TValue;
    function Visit(const aNode: INode): TValue;
  end;

  IGrammar = interface(IBaseGrammar)
    ['{62382986-2D51-4205-ACC9-78615533CBDF}']
    function GetGrammarText: string;
    function GetLazyRules: IArrayString;
    property GrammarText: string read GetGrammarText;
    property LazyRules: IArrayString read GetLazyRules;
  end;

implementation

end.