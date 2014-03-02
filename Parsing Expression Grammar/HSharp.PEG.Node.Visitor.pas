unit HSharp.PEG.Node.Visitor;

interface

uses
  System.Rtti,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Node.Interfaces;

type
  TNodeVisitor = class(TInterfacedObject, INodeVisitor)
  strict private
    FGrammar: IGrammar;
    FRuleMethodsDict: IDictionary<string, TRttiMethod>;
  strict protected
    function Visit(const aNode: INode): TValue;
  public
    constructor Create(const aGrammar: IGrammar; const aRuleMethodsDict: IDictionary<string, TRttiMethod>); reintroduce;
  end;

implementation

uses
  Vcl.Dialogs, {TODO -oHelton -cRemove : Remove!}

  System.SysUtils,
  HSharp.Core.Arrays;

{ TNodeVisitor }

constructor TNodeVisitor.Create(const aGrammar: IGrammar;
  const aRuleMethodsDict: IDictionary<string, TRttiMethod>);
begin
  inherited Create;
  FGrammar := aGrammar;
  FRuleMethodsDict := aRuleMethodsDict;
end;

function TNodeVisitor.Visit(const aNode: INode): TValue;
var
  Child: INode;
  Method: TRttiMethod;
  ChildrenResults: IArray<TValue>;
  Value: TValue;
begin
  Result := nil;
  ChildrenResults := TArray<TValue>.Create;
  if Assigned(aNode.Children) then
  begin
    for Child in aNode.Children do
    begin
      Value := (Child as IVisitableNode).Accept(Self);
      ChildrenResults.Add(Value);
    end;
  end;
  if not aNode.Name.IsEmpty then
  begin
    if FRuleMethodsDict.TryGetValue(aNode.Name, Method) then
      Result := Method.Invoke(TObject(FGrammar),
                              [TValue.From<INode>(aNode),
                               TValue.From<IArray<TValue>>(ChildrenResults)]);
  end;
end;

end.
