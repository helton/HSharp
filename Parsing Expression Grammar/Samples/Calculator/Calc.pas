unit Calc;

interface

uses
  System.Rtti,
  HSharp.PEG.Node,
  HSharp.PEG.Grammar,
  HSharp.PEG.Grammar.Attributes,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Node.Interfaces;

type
  ICalc = interface(IGrammar)
    ['{48EF9501-978B-41E7-839E-9FE71C53C788}']
    function Evaluate(const aExpression: string): Extended;
  end;

  TCalc = class(TGrammar, ICalc)
  public
    [Rule('expression = _ "-"? term ( addOp term )*')]
    function Visit_Expression(const aNode: INode): TValue;
    [Rule('term = factor ( mulOp factor )*')]
    function Visit_Term(const aNode: INode): TValue;
    [Rule('factor = parenthesizedExp | number')]
    function Visit_Factor(const aNode: INode): TValue;
    [Rule('parenthesizedExp = "(" _ expression ")" _')]
    function Visit_ParenthesizedExp(const aNode: INode): TValue;
    [Rule('addOp = ("+"|"-") _')]
    function Visit_AddOp(const aNode: INode): TValue;
    [Rule('mulOp = ("*"|"/") _')]
    function Visit_MulOp(const aNode: INode): TValue;
    [Rule('number = /[0-9]*\.?[0-9]+(e[-+]?[0-9]+)?/ _')]
    function Visit_Number(const aNode: INode): TValue;
    [Rule('_ = /\s+/?')]
    function Visit__(const aNode: INode): TValue;
  public
    function Evaluate(const aExpression: string): Extended;
  end;

implementation

uses
  Vcl.Dialogs,

  HSharp.PEG.Node.Visitors,
  System.SysUtils;

{ TCalc }

function TCalc.Evaluate(const aExpression: string): Extended;
begin
  Result := ParseAndVisit(aExpression).AsExtended;
end;

function TCalc.Visit_AddOp(const aNode: INode): TValue;
begin
  Result := aNode.Children[0].Text;
end;

function TCalc.Visit_Expression(const aNode: INode): TValue;
var
  ChildNode: INode;
begin
  Result := aNode.Children[2].Value.AsExtended;
  if Assigned(aNode.Children[3].Children) then
  begin
    for ChildNode in aNode.Children[3].Children do
    begin
      if ChildNode.Children[0].Children[0].Text = '+' then
        Result := Result.AsExtended + ChildNode.Children[1].Value.AsExtended
      else
        Result := Result.AsExtended - ChildNode.Children[1].Value.AsExtended;
    end;
  end;
  if not aNode.Children[1].Text.IsEmpty then
    Result := -Result.AsExtended;
end;

function TCalc.Visit_Factor(const aNode: INode): TValue;
begin
  Result := aNode.Children[0].Value.AsExtended;
end;

function TCalc.Visit_MulOp(const aNode: INode): TValue;
begin
  Result := aNode.Children[0].Text;
end;

function TCalc.Visit_Number(const aNode: INode): TValue;
begin
  Result := aNode.Children[0].Text.Replace('.', ',').ToExtended;
end;

function TCalc.Visit_ParenthesizedExp(const aNode: INode): TValue;
begin
  Result := aNode.Children['expression'].Value.AsExtended;
end;

function TCalc.Visit_Term(const aNode: INode): TValue;
var
  ChildNode: INode;
begin
  Result := aNode.Children[0].Value.AsExtended;
  if Assigned(aNode.Children[1].Children) then
  begin
    for ChildNode in aNode.Children[1].Children do
    begin
      if ChildNode.Children[0].Children[0].Text = '*' then
        Result := Result.AsExtended * ChildNode.Children[1].Value.AsExtended
      else
        Result := Result.AsExtended / ChildNode.Children[1].Value.AsExtended;
    end;
  end;
end;

function TCalc.Visit__(const aNode: INode): TValue;
begin
end;

end.
