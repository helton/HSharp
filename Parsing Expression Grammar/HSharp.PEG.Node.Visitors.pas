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

unit HSharp.PEG.Node.Visitors;

interface

uses
  System.Rtti,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Node.Interfaces;

type
  TGrammarNodeVisitor = class(TInterfacedObject, INodeVisitor)
  strict private
    FGrammar: IGrammar;
    FRuleMethodsDict: IDictionary<string, TRttiMethod>;
  strict protected
    function Visit(const aNode: INode): TValue;
  public
    constructor Create(const aGrammar: IGrammar; const aRuleMethodsDict: IDictionary<string, TRttiMethod>); reintroduce;
  end;

  TPrinterNodeVisitor = class(TInterfacedObject, INodeVisitor)
  strict private
    FIndent: Integer;
  strict protected
    function Visit(const aNode: INode): TValue;
  end;

implementation

uses
  Vcl.Dialogs, {TODO -oHelton -cRemove : Remove!}
  System.StrUtils,
  System.SysUtils,
  HSharp.Core.Arrays,
  HSharp.Core.ArrayString,
  HSharp.Core.Rtti;

{ TNodeVisitor }

constructor TGrammarNodeVisitor.Create(const aGrammar: IGrammar;
  const aRuleMethodsDict: IDictionary<string, TRttiMethod>);
begin
  inherited Create;
  FGrammar := aGrammar;
  FRuleMethodsDict := aRuleMethodsDict;
end;

function TGrammarNodeVisitor.Visit(const aNode: INode): TValue;
var
  Child: INode;
  ChildrenResults: IArray<TValue>;

  function GetResultFromInvokedMethod(const aMethod: TRttiMethod): TValue;
  begin
    Result := aMethod.Invoke(TObject(FGrammar),
                             [TValue.From<INode>(aNode),
                              TValue.From<IArray<TValue>>(
                                ChildrenResults)]).AsType<TValue>;
  end;

  function GenericVisitCall: TValue;
  var
    Method: TRttiMethod;
  begin
    Result := nil;
    Method := RttiContext.GetType(TObject(FGrammar).ClassType).GetMethod('GenericVisit');
    if Assigned(Method) then
      Result := GetResultFromInvokedMethod(Method);
  end;

var
  Method: TRttiMethod;
begin
  Result := nil;
  ChildrenResults := TArray<TValue>.Create;
  if Assigned(aNode.Children) then
  begin
    for Child in aNode.Children do
      ChildrenResults.Add((Child as IVisitableNode).Accept(Self)); {TODO -oHelton -cQuestion : If is empty, add TValue.From<String>(Child.Text) ?}
  end;
  if not aNode.Name.IsEmpty then
  begin
    if FRuleMethodsDict.TryGetValue(aNode.Name, Method) then
      Result := GetResultFromInvokedMethod(Method)
    else
      Result := GenericVisitCall;
  end
  else
    Result := GenericVisitCall;
end;

{ TPrinterNodeVisitor }

function TPrinterNodeVisitor.Visit(const aNode: INode): TValue;
var
  Arr: IArrayString;
  Child: INode;
  Text: string;
begin
  Arr := TArrayString.Create;
  Text := aNode.Text.Replace(sLineBreak, '\n');
  if not aNode.Name.IsEmpty then
    Arr.AddFormatted('<%s called "%s" matching "%s">', [IfThen(Supports(aNode, IRegexNode), 'RegexNode', 'Node'), aNode.Name, Text])
  else
    Arr.AddFormatted('<%s matching "%s">', [IfThen(Supports(aNode, IRegexNode), 'RegexNode', 'Node'), Text]);
  if Assigned(aNode.Children) then
  begin
    Inc(FIndent);
    for Child in aNode.Children do
      Arr.Add((Child as IVisitableNode).Accept(Self).AsString);
    Dec(FIndent);
  end;
  Arr.Indent(FIndent);
  Result := Arr.AsString;
end;

end.
