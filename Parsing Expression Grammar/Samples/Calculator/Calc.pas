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

  {$SCOPEDENUMS ON}
  TOperation = (None, Addition, Subtraction, Multiplication, Division, Power, Radix);
  {$SCOPEDENUMS OFF}

  TCalc = class(TGrammar, ICalc)
  strict private
    function StrToOperation(const aOperation: string): TOperation;
    function ExecuteOperation(aOperation: TOperation; aLeft, aRight: Extended): Extended;
  public
    [Rule('expression = _ negate term term_list:( addOp term )*')]
    function Visit_Expression(const aNode: INode): TValue;
    [Rule('term = factor factor_list:( mulOp factor )*')]
    function Visit_Term(const aNode: INode): TValue;
    [Rule('factor = atom atom_list:( expOp atom )*')]
    function Visit_Factor(const aNode: INode): TValue;
    [Rule('atom = parenthesizedExp | number')]
    function Visit_Atom(const aNode: INode): TValue;
    [Rule('parenthesizedExp = "(" _ expression ")" _')]
    function Visit_ParenthesizedExp(const aNode: INode): TValue;
    [Rule('addOp = op:("+"|"-") _')]
    function Visit_AddOp(const aNode: INode): TValue;
    [Rule('mulOp = op:("*"|"/") _')]
    function Visit_MulOp(const aNode: INode): TValue;
    [Rule('expOp = op:("^"|"r") _')]
    function Visit_ExpOp(const aNode: INode): TValue;
    [Rule('number = num:/[0-9]*\.?[0-9]+(e[-+]?[0-9]+)?/ _')]
    function Visit_Number(const aNode: INode): TValue;
    [Rule('negate = minus:"-"?')]
    function Visit_Negate(const aNode: INode): TValue;
    [Rule('_ = /\s+/?')]
    function Visit__(const aNode: INode): TValue;
  public
    function Evaluate(const aExpression: string): Extended;
  end;

implementation

uses
  System.Math,
  HSharp.PEG.Node.Visitors,
  System.SysUtils;

{ TCalc }

function TCalc.Evaluate(const aExpression: string): Extended;
begin
  Result := ParseAndVisit(aExpression).AsExtended;
end;

function TCalc.ExecuteOperation(aOperation: TOperation; aLeft,
  aRight: Extended): Extended;
begin
  case aOperation of
    TOperation.Addition:
      Result := aLeft + aRight;
    TOperation.Subtraction:
      Result := aLeft - aRight;
    TOperation.Multiplication:
      Result := aLeft * aRight;
    TOperation.Division:
      Result := aLeft / aRight;
    TOperation.Power:
      Result := Power(aLeft, aRight);
    TOperation.Radix:
      Result := Power(aRight, 1/aLeft);
    else
      Result := 0;
  end;
end;

function TCalc.StrToOperation(const aOperation: string): TOperation;
begin
  if aOperation = '+' then
    Result := TOperation.Addition
  else if aOperation = '-' then
    Result := TOperation.Subtraction
  else if aOperation = '*' then
    Result := TOperation.Multiplication
  else if aOperation = '/' then
    Result := TOperation.Division
  else if aOperation = '^' then
    Result := TOperation.Power
  else if aOperation = 'r' then
    Result := TOperation.Radix
  else
    Result := TOperation.None;
end;

function TCalc.Visit_AddOp(const aNode: INode): TValue;
begin
  Result := TValue.From<TOperation>(StrToOperation(aNode.Children['op'].Text));
end;

function TCalc.Visit_Atom(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value.AsExtended;
end;

function TCalc.Visit_ExpOp(const aNode: INode): TValue;
begin
  Result := TValue.From<TOperation>(StrToOperation(aNode.Children['op'].Text));
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
      Result := ExecuteOperation(
        ChildNode.Children['addOp'].Value.AsType<TOperation>,
        Result.AsExtended,
        ChildNode.Children['term'].Value.AsExtended
      );
    end;
  end;
  if aNode.Children['negate'].Value.AsBoolean then
    Result := -Result.AsExtended;
end;

function TCalc.Visit_Factor(const aNode: INode): TValue;
var
  ChildNode: INode;
begin
  Result := aNode.Children['atom'].Value.AsExtended;
  if Assigned(aNode.Children['atom_list'].Children) then
  begin
    for ChildNode in aNode.Children['atom_list'].Children do
    begin
      Result := ExecuteOperation(
        ChildNode.Children['expOp'].Value.AsType<TOperation>,
        Result.AsExtended,
        ChildNode.Children['atom'].Value.AsExtended
      );
    end;
  end;
end;

function TCalc.Visit_MulOp(const aNode: INode): TValue;
begin
  Result := TValue.From<TOperation>(StrToOperation(aNode.Children['op'].Text));
end;

function TCalc.Visit_Negate(const aNode: INode): TValue;
begin
  Result := Assigned(aNode.Children);
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
      Result := ExecuteOperation(
        ChildNode.Children['mulOp'].Value.AsType<TOperation>,
        Result.AsExtended,
        ChildNode.Children['factor'].Value.AsExtended
      );
    end;
  end;
end;

function TCalc.Visit__(const aNode: INode): TValue;
begin
end;

end.
