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
    [Rule('expression = _ negate:"-"? term term_list:( addOp term )*')]
    function Visit_Expression(const aNode: INode): TValue;
    [Rule('term = factor factor_list:( mulOp factor )*')]
    function Visit_Term(const aNode: INode): TValue;
    [Rule('factor = parenthesizedExp | number')]
    function Visit_Factor(const aNode: INode): TValue;
    [Rule('parenthesizedExp = "(" _ expression ")" _')]
    function Visit_ParenthesizedExp(const aNode: INode): TValue;
    [Rule('addOp = op:("+"|"-") _')]
    function Visit_AddOp(const aNode: INode): TValue;
    [Rule('mulOp = op:("*"|"/") _')]
    function Visit_MulOp(const aNode: INode): TValue;
    [Rule('number = num:/[0-9]*\.?[0-9]+(e[-+]?[0-9]+)?/ _')]
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
  Result := aNode.Children['op'].Text;
end;

function TCalc.Visit_Expression(const aNode: INode): TValue;
var
  ChildNode: INode;
begin
  Result := aNode.Children['term'].Value.AsExtended;
  if Assigned(aNode.Children['term_list'].Children) then
  begin
    for ChildNode in aNode.Children['term_list'].Children do
    begin
      if ChildNode.Children['addOp'].Value.AsString = '+' then
        Result := Result.AsExtended + ChildNode.Children['term'].Value.AsExtended
      else
        Result := Result.AsExtended - ChildNode.Children['term'].Value.AsExtended;
    end;
  end;
  if not aNode.Children['negate'].Text.IsEmpty then
    Result := -Result.AsExtended;
end;

function TCalc.Visit_Factor(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value.AsExtended;
end;

function TCalc.Visit_MulOp(const aNode: INode): TValue;
begin
  Result := aNode.Children['op'].Text;
end;

function TCalc.Visit_Number(const aNode: INode): TValue;
begin
  Result := aNode.Children['num'].Text.Replace('.', ',').ToExtended;
end;

function TCalc.Visit_ParenthesizedExp(const aNode: INode): TValue;
begin
  Result := aNode.Children['expression'].Value.AsExtended;
end;

function TCalc.Visit_Term(const aNode: INode): TValue;
var
  ChildNode: INode;
begin
  Result := aNode.Children['factor'].Value.AsExtended;
  if Assigned(aNode.Children['factor_list'].Children) then
  begin
    for ChildNode in aNode.Children['factor_list'].Children do
    begin
      if ChildNode.Children['mulOp'].Value.AsString = '*' then
        Result := Result.AsExtended * ChildNode.Children['factor'].Value.AsExtended
      else
        Result := Result.AsExtended / ChildNode.Children['factor'].Value.AsExtended;
    end;
  end;
end;

function TCalc.Visit__(const aNode: INode): TValue;
begin
end;

end.
