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

unit HSharp.PEG.Grammar;

interface

uses
  System.Rtti,
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Context,
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Node.Visitors,
  HSharp.PEG.Rule.Interfaces;

type
  TGrammar = class(TInterfacedObject, IGrammar)
  strict private
    FRuleMethodsDict: IDictionary<string, TRttiMethod>;
    FDefaultRule: IRule; //should be a weak reference?
    FRules: IList<IRule>;
  public
    constructor Create(const aRules: array of IRule; const aDefaultRule: IRule = nil); reintroduce;
    function Parse(const aText: string): INode;
    function ParseAndVisit(const aText: string): TValue;
    function AsString: string;
  end;

implementation

uses
  System.SysUtils,
  HSharp.Core.Arrays,
  HSharp.Core.ArrayString,
  HSharp.Core.Rtti;

{ TGrammar }

function TGrammar.AsString: string;
var
  Rule: IRule;
  Grammar: IArrayString;
begin
  Grammar := TArrayString.Create;
  Grammar.Add(FDefaultRule.AsString);
  for Rule in FRules do
  begin
    if Rule <> FDefaultRule then
      Grammar.Add(Rule.AsString);
  end;
  Result := Grammar.AsString;
end;

constructor TGrammar.Create(const aRules: array of IRule;
  const aDefaultRule: IRule);

  procedure MapRules;
  var
    Rule: IRule;
    Method: TRttiMethod;
  begin
    FRuleMethodsDict := Collections.CreateDictionary<string, TRttiMethod>;
    for Rule in FRules do
    begin
      Method := RttiContext.GetType(ClassType).GetMethod('Visit_' + Rule.Name);
      if Assigned(Method) then
        FRuleMethodsDict.Add(Rule.Name, Method);
    end;
  end;

begin
  inherited Create;
  FRules := Collections.CreateList<IRule>;
  FRules.AddRange(aRules);
  if Assigned(aDefaultRule) then
    FDefaultRule := aDefaultRule
  else
    FDefaultRule := FRules.First;
  MapRules;
end;

function TGrammar.Parse(const aText: string): INode;
var
  Context: IContext;
begin
  Context := TContext.Create(aText);
  Result := FDefaultRule.Parse(Context);
end;

function TGrammar.ParseAndVisit(const aText: string): TValue;
var
  Node: INode;
  NodeVisitor: INodeVisitor;
  VisitableNode: IVisitableNode;
begin
  Result := nil;
  Node := Parse(aText);
  NodeVisitor := TGrammarNodeVisitor.Create(Self, FRuleMethodsDict);
  if Supports(Node, IVisitableNode, VisitableNode) then
    Result := VisitableNode.Accept(NodeVisitor);
end;

end.