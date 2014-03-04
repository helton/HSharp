unit Calc;

interface

uses
  System.Rtti,
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
//E -> [-] T { (+|-) T }
//T -> F { (*|/) F }
//F -> '(' E ')' | digit
    [Rule('add = number (addop number)*')]
    function Visit_Add(const aNode: INode): TValue;
    [Rule('addop = "+"|"-"')]
    function Visit_AddOp(const aNode: INode): TValue;
    [Rule('number = _ /[0-9]+/ _')]
    function Visit_Number(const aNode: INode): TValue;
    [Rule('_ = /\s+/?')]
    function Visit__(const aNode: INode): TValue;
  public
    function Evaluate(const aExpression: string): Extended;
  end;

implementation

uses
  System.SysUtils;

{ TCalc }

function TCalc.Evaluate(const aExpression: string): Extended;
begin
  Result := ParseAndVisit(aExpression).AsExtended;
end;

function TCalc.Visit_Add(const aNode: INode): TValue;
var
  ChildNode: INode;
begin
  Result := aNode.Children[0].Value.AsExtended;
  if Assigned(aNode.Children[1].Children) then
  begin
    for ChildNode in aNode.Children[1].Children do
    begin
      if ChildNode.Children[0].Text = '+' then
        Result := Result.AsExtended + ChildNode.Children[1].Value.AsExtended
      else
        Result := Result.AsExtended - ChildNode.Children[1].Value.AsExtended;
    end;
  end;
end;

function TCalc.Visit_Number(const aNode: INode): TValue;
begin
  Result := aNode.Children[1].Text.ToInteger;
end;

function TCalc.Visit_AddOp(const aNode: INode): TValue;
begin
  Result := aNode.Children[0].Text;
end;

function TCalc.Visit__(const aNode: INode): TValue;
begin
end;

end.
