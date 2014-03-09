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
  HSharp.Core.ArrayString,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Node.Visitors,
  HSharp.PEG.Rule.Interfaces,
  HSharp.PEG.Grammar.Base,
  HSharp.PEG.Grammar.Bootstrapping,
  HSharp.PEG.Grammar.Interfaces;

type
  TGrammar = class(TBaseGrammar, IGrammar)
  strict private
    FGrammarText: string;
    FLazyRules: IArrayString;
  strict private
    procedure BuildGrammarText;
    procedure BuildLazyRules;
  strict protected
    { IGrammar }
    function GetGrammarText: string;
    function GetLazyRules: IArrayString;
  public
    constructor Create; reintroduce; virtual;
    function Visit(const aNode: INode): TValue; override;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils,
  HSharp.Core.Rtti,
  HSharp.PEG.Grammar.Attributes;

{ TAnnotatedGrammar }

procedure TGrammar.BuildGrammarText;
var
  Method: TRttiMethod;
  Attribute: TCustomAttribute;
  Grammar: IArrayString;
begin
  Grammar := TArrayString.Create;
  for Method in RttiContext.GetType(ClassType).GetMethods do
  begin
    for Attribute in Method.GetAttributes do
    begin
      if Attribute is RuleAttribute then
        Grammar.Add(RuleAttribute(Attribute).Rule);
    end;
  end;
  FGrammarText := Grammar.AsString;
end;

procedure TGrammar.BuildLazyRules;
var
  Method: TRttiMethod;
  Attribute: TCustomAttribute;
begin
  FLazyRules := TArrayString.Create;
  for Method in RttiContext.GetType(ClassType).GetMethods do
  begin
    for Attribute in Method.GetAttributes do
    begin
      if Attribute is LazyRule then
        FLazyRules.Add(RightStr(Method.Name, Method.Name.Length - 'Visit_'.Length)); //copy only rule name
    end;
  end;
end;

constructor TGrammar.Create;
var
  BootstrappingGrammar: IBootstrappingGrammar;
begin
  BuildGrammarText;
  BuildLazyRules;
  BootstrappingGrammar := TBootstrappingGrammar.Create;
  inherited Create(BootstrappingGrammar.GetRules(FGrammarText));
end;

function TGrammar.GetGrammarText: string;
begin
  Result := FGrammarText;
end;

function TGrammar.GetLazyRules: IArrayString;
begin
  Result := FLazyRules;
end;

function TGrammar.Visit(const aNode: INode): TValue;
var
  NodeVisitor: INodeVisitor;
  VisitableNode: IVisitableNode;
begin
  NodeVisitor := TGrammarNodeVisitor.Create(Self, RuleMethodsDict, FLazyRules); {TODO -oHelton -cOtimize : Otimize using Visitor as Lazy<INodeVisitor, TGrammarNodeVisitor>}
  if Supports(aNode, IVisitableNode, VisitableNode) then
    Result := VisitableNode.Accept(NodeVisitor);
end;

end.