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

unit HSharp.PEG.Node.Interfaces;

interface

uses
  System.RegularExpressions,
  System.Rtti,
  HSharp.Collections.Interfaces;

type
  INode = interface;

  INodeVisitor = interface
    ['{EF39DA2D-7849-4C72-92C9-915AEF6848C4}']
    function Visit(const aNode: INode): TValue;
  end;

  IVisitableNode = interface
    ['{1D7B2F86-CD22-4299-8F24-982B32150B99}']
    function Accept(const aVisitor: INodeVisitor): TValue;
  end;

  INode = interface
    ['{7F8983C7-D49A-4B8F-9696-B1EA19909452}']
    { property accessors }
    function GetChildren: IList<INode>;
    function GetIndex: Integer;
    function GetName: string;
    function GetText: string;
    function GetValue: TValue;
    procedure SetValue(const aValue: TValue);
    { properties }
    property Children: IList<INode> read GetChildren;
    property Index: Integer read GetIndex;
    property Name: string read GetName;
    property Text: string read GetText;
    property Value: TValue read GetValue write SetValue;
  end;

  IRegexNode = interface(INode)
    ['{136B89D9-EBDB-4E6C-A116-7A88D1E59DB0}']
    { property accessors }
    function GetMatch: TMatch;
    { properties }
    property Match: TMatch read GetMatch;
  end;

implementation

end.
