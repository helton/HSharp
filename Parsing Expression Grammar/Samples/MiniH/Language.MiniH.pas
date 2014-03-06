unit Language.MiniH;

interface

uses
  System.Rtti,
  System.SysUtils,
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Grammar,
  HSharp.PEG.Grammar.Attributes,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Node,
  HSharp.PEG.Node.Interfaces;

type
  {$REGION 'Types'}

  EVariableNotDefined = class(Exception);
  {$SCOPEDENUMS ON}
  TOperation = (None, Addition, Subtraction, Multiplication, Division, Power, Radix);
  {$SCOPEDENUMS OFF}

  {$ENDREGION}

  {$REGION 'Interfaces'}
  IMiniH = interface(IGrammar)
    ['{48EF9501-978B-41E7-839E-9FE71C53C788}']
    function Execute(const aExpression: string): TValue;
  end;
  {$ENDREGION}

  //TScope = class

  TMiniH = class(TGrammar, IMiniH)
  strict private
    FVariables: IDictionary<string, Extended>;
  strict protected
    function StrToOperation(const aOperation: string): TOperation;
    function ExecuteOperation(aOperation: TOperation; aLeft, aRight: Extended): Extended;
  public
    constructor Create; override;
  public
    [Rule('program = statement statement_list:(";" statement)*')]
    function Visit_Program(const aNode: INode): TValue;
    [Rule('statement = _ stmt:(ifelse | expression) _')]
    function Visit_Statement(const aNode: INode): TValue;
    [Rule('expression = _ negate term term_list:( addOp term )*')]
    function Visit_Expression(const aNode: INode): TValue;
    [Rule('term = factor factor_list:( mulOp factor )*')]
    function Visit_Term(const aNode: INode): TValue;
    [Rule('factor = atom atom_list:( expOp atom )*')]
    function Visit_Factor(const aNode: INode): TValue;
    [Rule('atom = parenthesizedExp | number | assignment | variable')]
    function Visit_Atom(const aNode: INode): TValue;
    [Rule('parenthesizedExp = "(" _ expression ")" _')]
    function Visit_ParenthesizedExp(const aNode: INode): TValue;
    [Rule('assignment = identifier "=" expression')]
    function Visit_Assignment(const aNode: INode): TValue;
    [Rule('addOp = op:("+"|"-") _')]
    function Visit_AddOp(const aNode: INode): TValue;
    [Rule('mulOp = op:("*"|"/") _')]
    function Visit_MulOp(const aNode: INode): TValue;
    [Rule('expOp = op:("^"|"r") _')]
    function Visit_ExpOp(const aNode: INode): TValue;
    [Rule('number = num:/[0-9]*\.?[0-9]+(e[-+]?[0-9]+)?/ _')]
    function Visit_Number(const aNode: INode): TValue;
    [Rule('variable = identifier _')]
    function Visit_Variable(const aNode: INode): TValue;
    [Rule('identifier = id:/[a-z_][a-z0-9_]*/i _')]
    function Visit_Identifier(const aNode: INode): TValue;
    [Rule('negate = "-"?')]
    function Visit_Negate(const aNode: INode): TValue;
    [Rule('ifelse = "if" _ expression _ "then" _ statement elsePart:(_ "else" _ statement)?')]
    function Visit_IfElse(const aNode: INode): TValue;
    [Rule('_ = __?')]
    function Visit__(const aNode: INode): TValue;
    [Rule('__ = /\s+/')]
    function Visit___(const aNode: INode): TValue;
  public
    function Execute(const aExpression: string): TValue;
  end;

implementation

uses
  System.Math,
  HSharp.PEG.Node.Visitors;

{ TCalc }

constructor TMiniH.Create;
begin
  inherited;
  FVariables := Collections.CreateDictionary<string, Extended>;
end;

function TMiniH.Execute(const aExpression: string): TValue;
begin
  Result := ParseAndVisit(aExpression);
end;

function TMiniH.ExecuteOperation(aOperation: TOperation; aLeft,
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

function TMiniH.StrToOperation(const aOperation: string): TOperation;
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

function TMiniH.Visit_AddOp(const aNode: INode): TValue;
begin
  Result := TValue.From<TOperation>(StrToOperation(aNode.Children['op'].Text));
end;

function TMiniH.Visit_Assignment(const aNode: INode): TValue;
var
  VariableName: string;
  Value: Extended;
begin
  VariableName := aNode.Children['identifier'].Value.AsString;
  Value := aNode.Children['expression'].Value.AsExtended;
  FVariables.Add(VariableName, Value);
  Result := Value;
end;

function TMiniH.Visit_Atom(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value.AsExtended;
end;

function TMiniH.Visit_ExpOp(const aNode: INode): TValue;
begin
  Result := TValue.From<TOperation>(StrToOperation(aNode.Children['op'].Text));
end;

function TMiniH.Visit_Expression(const aNode: INode): TValue;
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

function TMiniH.Visit_Factor(const aNode: INode): TValue;
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

function TMiniH.Visit_Identifier(const aNode: INode): TValue;
begin
  Result := aNode.Children['id'].Text;
end;

function TMiniH.Visit_IfElse(const aNode: INode): TValue;
begin
  Result := nil;
  if aNode.Children['expression'].Value.AsExtended <> 0 then
    Result := aNode.Children['statement'].Value
  else
  begin
    if Assigned(aNode.Children['elsePart'].Children) then
      Result := aNode.Children['elsePart'].Children.First.Children['statement'].Value;
  end;
end;

function TMiniH.Visit_MulOp(const aNode: INode): TValue;
begin
  Result := TValue.From<TOperation>(StrToOperation(aNode.Children['op'].Text));
end;

function TMiniH.Visit_Negate(const aNode: INode): TValue;
begin
  Result := Assigned(aNode.Children);
end;

function TMiniH.Visit_Number(const aNode: INode): TValue;
begin
  Result := aNode.Children['num'].Text.Replace('.', ',').ToExtended;
end;

function TMiniH.Visit_ParenthesizedExp(const aNode: INode): TValue;
begin
  Result := aNode.Children['expression'].Value.AsExtended;
end;

function TMiniH.Visit_Program(const aNode: INode): TValue;
begin
  Result := aNode.Children['statement'].Value;
  if Assigned(aNode.Children['statement_list'].Children) then
    Result := aNode.Children['statement_list'].Children.Last.Children['statement'].Value;
end;

function TMiniH.Visit_Statement(const aNode: INode): TValue;
begin
  Result := aNode.Children['stmt'].Children.First.Value;
end;

function TMiniH.Visit_Term(const aNode: INode): TValue;
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

function TMiniH.Visit_Variable(const aNode: INode): TValue;
var
  VariableName: string;
  Value: Extended;
begin
  VariableName := aNode.Children['identifier'].Value.AsString;
  if FVariables.TryGetValue(VariableName, Value) then
    Result := Value
  else
    raise EVariableNotDefined.CreateFmt('Variable "%s" is not defined in this ' +
      'scope', [VariableName]);
end;

function TMiniH.Visit___(const aNode: INode): TValue;
begin
end;

function TMiniH.Visit__(const aNode: INode): TValue;
begin
end;

end.
