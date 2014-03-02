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
  HSharp.Core.ArrayString;

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
  Method: TRttiMethod;
  ChildrenResults: IArray<TValue>;
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
      Result := Method.Invoke(TObject(FGrammar),
                              [TValue.From<INode>(aNode),
                               TValue.From<IArray<TValue>>(ChildrenResults)]).AsType<TValue>;
  end;
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
