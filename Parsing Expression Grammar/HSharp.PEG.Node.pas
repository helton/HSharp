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

unit HSharp.PEG.Node;

interface

uses
  System.RegularExpressions,
  System.Rtti,
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.Collections.List,
  HSharp.PEG.Node.Interfaces;

type
  TNode = class(TInterfacedObject, INode, IVisitableNode)
  strict private
    FName: string;
    FText: string;
    FIndex: Integer;
    FValue: TValue;
    FChildren: INodeList;
  strict protected
    { INode }
    function GetChildren: INodeList;
    function GetIndex: Integer;
    function GetName: string;
    function GetText: string;
    function GetValue: TValue;
    procedure SetValue(const aValue: TValue);
    { IVisitableNode }
    function Accept(const aVisitor: INodeVisitor): TValue;
  public
    constructor Create(const aName, aText: string; aIndex: Integer;
      const aChildren: INodeList = nil); reintroduce;
  end;

  TRegexNode = class(TNode, IRegexNode)
  strict private
    FMatch: TMatch;
  strict protected
    function GetMatch: TMatch;
  public
    constructor Create(const aName: string; aMatch: TMatch; aIndex: Integer;
       const aChildren: INodeList = nil); reintroduce;
  end;

  TNodeList = class(TInterfacedList<INode>, INodeList)
  strict protected
    function GetItemById(const aId: TValue): INode;
  public
    property ItemById[const aId: TValue]: INode read GetItemById; default;
  end;

implementation

uses
  System.SysUtils,
  System.TypInfo,
  HSharp.Core.ArrayString;

{ TNode }

function TNode.Accept(const aVisitor: INodeVisitor): TValue;
begin
  Result := aVisitor.Visit(Self);
end;

constructor TNode.Create(const aName, aText: string; aIndex: Integer;
  const aChildren: INodeList);
begin
  inherited Create;
  FName := aName;
  FText := aText;
  FIndex := aIndex;
  FChildren := aChildren;
end;

function TNode.GetChildren: INodeList;
begin
  Result := FChildren;
end;

function TNode.GetIndex: Integer;
begin
  Result := FIndex;
end;

function TNode.GetName: string;
begin
  Result := FName;
end;

function TNode.GetText: string;
begin
  Result := FText;
end;

function TNode.GetValue: TValue;
begin
  Result := FValue;
end;

procedure TNode.SetValue(const aValue: TValue);
begin
  FValue := aValue;
end;

{ TRegexNode }

constructor TRegexNode.Create(const aName: string; aMatch: TMatch;
  aIndex: Integer; const aChildren: INodeList);
begin
  inherited Create(aName, aMatch.Value, aIndex, aChildren);
  FMatch := aMatch;
end;

function TRegexNode.GetMatch: TMatch;
begin
  Result := FMatch;
end;

{ TNodeList }

function TNodeList.GetItemById(const aId: TValue): INode;

  function GetItemByName(const aName: string): INode;
  var
    Node: INode;
  begin
    for Node in Self do
    begin
      if Node.Name = aName then
      begin
        Result := Node;
        Break;
      end;
    end;
  end;

begin
  Result := nil;
  if aId.TypeInfo.Kind in [tkChar, tkString, tkWChar, tkLString, tkWString, tkUString] then
    Result := GetItemByName(aId.AsString)
  else if aId.TypeInfo.Kind in [tkInteger, tkInt64] then
    Result := GetItem(aId.AsInteger);
end;

end.
