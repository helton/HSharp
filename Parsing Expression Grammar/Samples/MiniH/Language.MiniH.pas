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

unit Language.MiniH;

interface

uses
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  HSharp.Core.Arrays,
  HSharp.Core.ArrayString,
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Grammar,
  HSharp.PEG.Grammar.Attributes,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Node,
  HSharp.PEG.Node.Interfaces;

type
  {$REGION 'Types'}
  EVariableNotDefinedException = class(Exception);
  EMethodNotDefinedException = class(Exception);
  EArgumentCountException = class(Exception);
  {$SCOPEDENUMS ON}
  TArithmeticOperator = (None, Addition, Subtraction, Multiplication, Division, IntegerDivision, Modulo, Power, Radix);
  TRelationalOperator = (None, Equal, NotEqual, GreaterThan, LessThan, GreaterOrEqualThan, LessOrEqualThan);
  TLogicalOperator = (None, LogicalAnd, LogicalOr, LogicalXor);
  TIncrementDecrementOperator = (Increment, Decrement);
  TCompoundAssignment = (AdditionAssignment, SubtractionAssignment, MultiplicationAssignment, DivisionAssignment, IntegerDivisionAssignment, ModuloAssignment, PowerAssignment);
  {$SCOPEDENUMS OFF}

  {$ENDREGION}

  {$REGION 'Interfaces'}
  IMiniH = interface(IGrammar)
    ['{48EF9501-978B-41E7-839E-9FE71C53C788}']
    function Execute(const aExpression: string): TValue;
  end;

  IMethod = interface
    ['{46A35246-32F3-4657-90B4-1907928C238E}']
    function GetParameters: IArrayString;
    function GetBodyNode: INode;
    property Parameters: IArrayString read GetParameters;
    property BodyNode: INode read GetBodyNode;
  end;

  IScope = interface
    ['{DDC8FB74-9A06-4517-98C4-7BF3B2419E3E}']
    function GetVariables: IDictionary<string, Extended>;
    function GetMethods: IDictionary<string, IMethod>;
    property Variables: IDictionary<string, Extended> read GetVariables;
    property Methods: IDictionary<string, IMethod> read GetMethods;
  end;
  {$ENDREGION}

  TScope = class(TInterfacedObject, IScope)
  strict private
    FVariables: IDictionary<string, Extended>;
    FMethods: IDictionary<string, IMethod>;
  strict protected
    { IScope }
    function GetVariables: IDictionary<string, Extended>;
    function GetMethods: IDictionary<string, IMethod>;
  public
    constructor Create(const aInnerScope: IScope = nil); reintroduce;
  end;

  TMethod = class(TInterfacedObject, IMethod)
  strict private
    FParameters: IArrayString;
    FBodyNode: INode;
  strict protected
    { IMethod }
    function GetParameters: IArrayString;
    function GetBodyNode: INode;
  public
    constructor Create(const aParameters: IArrayString;
                       const aBodyNode: INode);
  end;

  TMiniH = class(TGrammar, IMiniH)
  strict private
    FScopeStack: IStack<IScope>;
  strict protected
    function StrToOperation(const aArithmeticOperator: string): TArithmeticOperator;
    function StrToRelationalOperator(const aRelationalOperator: string): TRelationalOperator;
    function StrToLogicalOperator(const aLogicalOperator: string): TLogicalOperator;
    function StrToIncrementDecrementOperator(const aIncrementDecrementOperator: string): TIncrementDecrementOperator;
    function ApplyArithmeticOperator(aOperation: TArithmeticOperator; aLeft, aRight: Extended): Extended;
    function ApplyIncrementDecrementOperator(aValue: Extended; aIncrementDecrementOperator: TIncrementDecrementOperator): Extended;
    function DoCompoundAssignment(const aVariableName: string; aExpressionValue: Extended; aCompoundAssignment: TCompoundAssignment): Extended;
    function Scope: IScope;
  public
    constructor Create; override;
  public
    [Rule('program = statementList')]
    function Visit_Program(const aNode: INode): TValue;
    [Rule('statementList = statement statement_list:(";" statement)* ";"? _')]
    function Visit_StatementList(const aNode: INode): TValue;
    [Rule('statement = _ stmt:(function | expression) _')]
    function Visit_Statement(const aNode: INode): TValue;
    [Rule('statementBlock = "{" _ statementList _ "}" _')]
    function Visit_StatementBlock(const aNode: INode): TValue;
    [Rule('statementBody = statementBlock | statement')]
    function Visit_StatementBody(const aNode: INode): TValue;
    [Rule('function = "def" _ identifier _ "(" _ parameters _ ")" _  statementBody _')]
    [LazyRule]
    function Visit_Function(const aNode: INode): TValue;
    [Rule('parameters = identifier params:(_ "," _ identifier)* _')]
    function Visit_Parameters(const aNode: INode): TValue;
    [Rule('expression = ifElse | while | for | simpleExpression')]
    function Visit_Expression(const aNode: INode): TValue;
    [Rule('simpleExpression = _ negate term term_list:( addOp term )*')]
    function Visit_SimpleExpression(const aNode: INode): TValue;
    [Rule('term = factor factor_list:( mulOp factor )*')]
    function Visit_Term(const aNode: INode): TValue;
    [Rule('factor = atom atom_list:( expOp atom )*')]
    function Visit_Factor(const aNode: INode): TValue;
    [Rule('atom = call | parenthesizedExp | number | assignment | prefixExpression | posfixExpression | variable')]
    function Visit_Atom(const aNode: INode): TValue;
    [Rule('prefixExpression = incrementDecrementOperator _ identifier')]
    function Visit_PrefixExpression(const aNode: INode): TValue;
    [Rule('posfixExpression = identifier _ incrementDecrementOperator')]
    function Visit_PosfixExpression(const aNode: INode): TValue;
    [Rule('incrementDecrementOperator = "++" | "--"')]
    function Visit_IncrementDecrementOperator(const aNode: INode): TValue;
    [Rule('parenthesizedExp = "(" _ expression ")" _')]
    function Visit_ParenthesizedExp(const aNode: INode): TValue;
    [Rule('assignment = simpleAssignment | compoundAssignment')]
    function Visit_Assignment(const aNode: INode): TValue;
    [Rule('simpleAssignment = identifier _ "=" _ expression')]
    function Visit_SimpleAssignment(const aNode: INode): TValue;
    [Rule('compoundAssignment = additionAssignment | subtractionAssignment | multiplicationAssignment | divisionAssignment | integerDivisionAssignment | moduloAssignment | powerAssignment')]
    function Visit_CompoundAssignment(const aNode: INode): TValue;
    [Rule('additionAssignment = identifier _ "+=" _ expression')]
    function Visit_AdditionAssignment(const aNode: INode): TValue;
    [Rule('subtractionAssignment = identifier _ "-=" _ expression')]
    function Visit_SubtractionAssignment(const aNode: INode): TValue;
    [Rule('multiplicationAssignment = identifier _ "*=" _ expression')]
    function Visit_MultiplicationAssignment(const aNode: INode): TValue;
    [Rule('divisionAssignment = identifier _ "/=" _ expression')]
    function Visit_DivisionAssignment(const aNode: INode): TValue;
    [Rule('integerDivisionAssignment = identifier _ "//=" _ expression')]
    function Visit_IntegerDivisionAssignment(const aNode: INode): TValue;
    [Rule('moduloAssignment = identifier _ "%=" _ expression')]
    function Visit_ModuloAssignment(const aNode: INode): TValue;
    [Rule('powerAssignment = identifier _ "**=" _ expression')]
    function Visit_PowerAssignment(const aNode: INode): TValue;
    [Rule('addOp = op:("+" | "-") _')]
    function Visit_AddOp(const aNode: INode): TValue;
    [Rule('mulOp = op:("*" | "//" | "div" | "/" | "%" | "mod") _')]
    function Visit_MulOp(const aNode: INode): TValue;
    [Rule('expOp = op:("**" | "r") _')]
    function Visit_ExpOp(const aNode: INode): TValue;
    [Rule('number = num:/[0-9]*\.?[0-9]+(e[-+]?[0-9]+)?/ _')]
    function Visit_Number(const aNode: INode): TValue;
    [Rule('variable = identifier _')]
    function Visit_Variable(const aNode: INode): TValue;
    [Rule('identifier = id:/[a-z_][a-z0-9_]*/i _')]
    function Visit_Identifier(const aNode: INode): TValue;
    [Rule('negate = "-"?')]
    function Visit_Negate(const aNode: INode): TValue;
    [Rule('booleanExpression = booleanNegateOperator _ simpleBooleanExpression')]
    function Visit_BooleanExpression(const aNode: INode): TValue;
    [Rule('simpleBooleanExpression = booleanComparisonList | booleanNumericExpression | booleanConstant')]
    function Visit_SimpleBooleanExpression(const aNode: INode): TValue;
    [Rule('booleanNumericExpression = expression _')]
    function Visit_BooleanNumericExpression(const aNode: INode): TValue;
    [Rule('booleanComparisonList = comparisonExpression comparison_expr_list:(booleanLogicalOperator booleanExpression)*')]
    function Visit_BooleanComparisonList(const aNode: INode): TValue;
    [Rule('comparisonExpression = booleanRelationalExpression | parenthesizedBooleanExpression')]
    function Visit_ComparisonExpression(const aNode: INode): TValue;
    [Rule('parenthesizedBooleanExpression = "(" booleanExpression ")" _')]
    function Visit_ParenthesizedBooleanExpression(const aNode: INode): TValue;
    [Rule('booleanRelationalExpression = expression relational_expr_list:(booleanRelationalOperator expression)+')]
    function Visit_BooleanRelationalExpression(const aNode: INode): TValue;
    [Rule('booleanRelationalOperator = op:("==" | "!="| "<>" | ">=" | "<=" | "<" | ">") _')]
    function Visit_BooleanRelationalOperator(const aNode: INode): TValue;
    [Rule('booleanLogicalOperator = op:("or" | "and" | "xor" | "||" | "&&" | "^") _')]
    function Visit_BooleanLogicalOperator(const aNode: INode): TValue;
    [Rule('booleanNegateOperator = ("not" | "!")?')]
    function Visit_BooleanNegateOperator(const aNode: INode): TValue;
    [Rule('booleanConstant = bool_const:("true" | "false") _')]
    function Visit_BooleanConstant(const aNode: INode): TValue;
    [Rule('ifElse = "if" _ booleanExpression _ ( "then" _ )? statementBody elsePart:(_ "else" _ statementBody)?')]
    [LazyRule]
    function Visit_IfElse(const aNode: INode): TValue;
    [Rule('while = "while" _ booleanExpression _ ( "do" _ )? statementBody')]
    [LazyRule]
    function Visit_While(const aNode: INode): TValue;
    [Rule('for = "for" _ identifier _ "=" _ initialExp:expression _ "to" _ finalExp:expression _ ( "do" _ )? statementBody')]
    [LazyRule]
    function Visit_For(const aNode: INode): TValue;
    [Rule('call = identifier _ "(" _ arguments _ ")" _')]
    function Visit_Call(const aNode: INode): TValue;
    [Rule('arguments = expression _ args:(_ "," _ expression)* _')]
    function Visit_Arguments(const aNode: INode): TValue;
    [Rule('_ = /\s+/?')]
    function Visit__(const aNode: INode): TValue;
  public
    function Execute(const aExpression: string): TValue;
  end;

implementation

uses
  FMX.Dialogs,
  System.Math,
  System.StrUtils,
  System.Typinfo,
  HSharp.PEG.Utils;

{ TMiniH }

function TMiniH.ApplyIncrementDecrementOperator(
  aValue: Extended; aIncrementDecrementOperator: TIncrementDecrementOperator): Extended;
begin
  if aIncrementDecrementOperator = TIncrementDecrementOperator.Increment then
    Result := aValue + 1
  else
    Result := aValue - 1;
end;

constructor TMiniH.Create;
begin
  inherited;
  FScopeStack := Collections.CreateStack<IScope>;
  FScopeStack.Push(TScope.Create);
end;

function TMiniH.DoCompoundAssignment(const aVariableName: string;
  aExpressionValue: Extended; aCompoundAssignment: TCompoundAssignment): Extended;
var
  VariableValue, Value: Extended;
begin
  if Scope.Variables.TryGetValue(aVariableName, VariableValue) then
  begin
    Value := VariableValue;
    case aCompoundAssignment of
      TCompoundAssignment.AdditionAssignment:
        Value := Value + aExpressionValue;
      TCompoundAssignment.SubtractionAssignment:
        Value := Value - aExpressionValue;
      TCompoundAssignment.MultiplicationAssignment:
        Value := Value * aExpressionValue;
      TCompoundAssignment.DivisionAssignment:
        Value := Value / aExpressionValue;
      TCompoundAssignment.IntegerDivisionAssignment:
        Value := Trunc(Value) div Trunc(aExpressionValue); {TODO -oHelton -cCheck this again : Check if this Trunc is correct}
      TCompoundAssignment.ModuloAssignment:
        Value := Trunc(Value) mod Trunc(aExpressionValue); {TODO -oHelton -cCheck this again : Check if this Trunc is correct}
      TCompoundAssignment.PowerAssignment:
        Value := Power(Value, aExpressionValue);
    end;
    Scope.Variables.AddOrSetValue(aVariableName, Value);
  end
  else
    raise EVariableNotDefinedException.CreateFmt('Variable "%s" is not defined in this ' +
      'scope', [aVariableName]);
  Result := Value;
end;

function TMiniH.Execute(const aExpression: string): TValue;
begin
  ShowMessage(NodeToStr(Parse(aExpression)));
  Result := ParseAndVisit(aExpression);
end;

function TMiniH.ApplyArithmeticOperator(aOperation: TArithmeticOperator; aLeft,
  aRight: Extended): Extended;
begin
  case aOperation of
    TArithmeticOperator.Addition:
      Result := aLeft + aRight;
    TArithmeticOperator.Subtraction:
      Result := aLeft - aRight;
    TArithmeticOperator.Multiplication:
      Result := aLeft * aRight;
    TArithmeticOperator.Division:
      Result := aLeft / aRight;
    TArithmeticOperator.IntegerDivision:
      Result := Trunc(aLeft) div Trunc(aRight); {TODO -oHelton -cCheck this again : Check if this Trunc is correct}
    TArithmeticOperator.Modulo:
      Result := Trunc(aLeft) mod Trunc(aRight); {TODO -oHelton -cCheck this again : Check if this Trunc is correct}
    TArithmeticOperator.Power:
      Result := Power(aLeft, aRight);
    TArithmeticOperator.Radix:
      Result := Power(aRight, 1/aLeft);
    else
      Result := 0;
  end;
end;

function TMiniH.Scope: IScope;
begin
  Result := FScopeStack.Peek;
end;

function TMiniH.StrToRelationalOperator(
  const aRelationalOperator: string): TRelationalOperator;
begin
  Result := TRelationalOperator.Equal;
  if aRelationalOperator = '==' then
    Result := TRelationalOperator.Equal
  else if (aRelationalOperator = '!=') or
          (aRelationalOperator = '<>') then
    Result := TRelationalOperator.NotEqual
  else if aRelationalOperator = '>=' then
    Result := TRelationalOperator.GreaterOrEqualThan
  else if aRelationalOperator = '<=' then
    Result := TRelationalOperator.LessOrEqualThan
  else if aRelationalOperator = '>' then
    Result := TRelationalOperator.GreaterThan
  else if aRelationalOperator = '<' then
    Result := TRelationalOperator.LessThan
end;

function TMiniH.StrToIncrementDecrementOperator(
  const aIncrementDecrementOperator: string): TIncrementDecrementOperator;
begin
  if aIncrementDecrementOperator = '++' then
    Result := TIncrementDecrementOperator.Increment
  else
    Result := TIncrementDecrementOperator.Decrement;
end;

function TMiniH.StrToLogicalOperator(
  const aLogicalOperator: string): TLogicalOperator;
begin
  if (aLogicalOperator = 'and') or
     (aLogicalOperator = '&&') then
    Result := TLogicalOperator.LogicalAnd
  else if (aLogicalOperator = 'or') or
          (aLogicalOperator = '||') then
    Result := TLogicalOperator.LogicalOr
  else if (aLogicalOperator = 'xor') or
          (aLogicalOperator = '^') then
    Result := TLogicalOperator.LogicalXor
  else
    Result := TLogicalOperator.None;
end;

function TMiniH.StrToOperation(const aArithmeticOperator: string): TArithmeticOperator;
begin
  if aArithmeticOperator = '+' then
    Result := TArithmeticOperator.Addition
  else if aArithmeticOperator = '-' then
    Result := TArithmeticOperator.Subtraction
  else if aArithmeticOperator = '*' then
    Result := TArithmeticOperator.Multiplication
  else if aArithmeticOperator = '/' then
    Result := TArithmeticOperator.Division
  else if (aArithmeticOperator = '//') or
          (aArithmeticOperator = 'div') then
    Result := TArithmeticOperator.IntegerDivision
  else if (aArithmeticOperator = '%') or
          (aArithmeticOperator = 'mod') then
    Result := TArithmeticOperator.Modulo
  else if aArithmeticOperator = '**' then
    Result := TArithmeticOperator.Power
  else if aArithmeticOperator = 'r' then
    Result := TArithmeticOperator.Radix
  else
    Result := TArithmeticOperator.None;
end;

function TMiniH.Visit_AdditionAssignment(const aNode: INode): TValue;
begin
  Result := DoCompoundAssignment(aNode.Children['identifier'].Value.AsString,
    aNode.Children['expression'].Value.AsExtended,
    TCompoundAssignment.AdditionAssignment
  );
end;

function TMiniH.Visit_AddOp(const aNode: INode): TValue;
begin
  Result := TValue.From<TArithmeticOperator>(StrToOperation(aNode.Children['op'].Text));
end;

function TMiniH.Visit_Arguments(const aNode: INode): TValue;
var
  Args: IArray<Extended>;
  Node: INode;
begin
  Args := TArray<Extended>.Create;
  Args.Add(aNode.Children['expression'].Value.AsExtended);
  if Assigned(aNode.Children['args'].Children) then
  begin
    for Node in aNode.Children['args'].Children do
      Args.Add(Node.Children['expression'].Value.AsExtended);
  end;
  Result := TValue.From<IArray<Extended>>(Args);
end;

function TMiniH.Visit_Assignment(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value;
end;

function TMiniH.Visit_Atom(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value.AsExtended;
end;

function TMiniH.Visit_BooleanComparisonList(const aNode: INode): TValue;
var
  ChildNode: INode;
begin
  Result := aNode.Children['comparisonExpression'].Value.AsBoolean;
  if Assigned(aNode.Children['comparison_expr_list'].Children) then
  begin
    for ChildNode in aNode.Children['comparison_expr_list'].Children do
    begin
      case ChildNode.Children['booleanLogicalOperator'].Value.AsType<TLogicalOperator> of
        TLogicalOperator.LogicalOr:
          Result := Result.AsBoolean or ChildNode.Children['booleanExpression'].Value.AsBoolean;
        TLogicalOperator.LogicalAnd:
          Result := Result.AsBoolean and ChildNode.Children['booleanExpression'].Value.AsBoolean;
        TLogicalOperator.LogicalXor:
          Result := Result.AsBoolean xor ChildNode.Children['booleanExpression'].Value.AsBoolean;
      end;
    end;
  end;
end;

function TMiniH.Visit_BooleanConstant(const aNode: INode): TValue;
begin
  Result := aNode.Children['bool_const'].Text = 'true';
end;

function TMiniH.Visit_BooleanExpression(const aNode: INode): TValue;
begin
  Result := aNode.Children['simpleBooleanExpression'].Value;
  if aNode.Children['booleanNegateOperator'].Value.AsBoolean then
    Result := not Result.AsBoolean;
end;

function TMiniH.Visit_BooleanLogicalOperator(const aNode: INode): TValue;
begin
  Result := TValue.From<TLogicalOperator>(StrToLogicalOperator(aNode.Children['op'].Text));
end;

function TMiniH.Visit_BooleanNegateOperator(const aNode: INode): TValue;
begin
  Result := Assigned(aNode.Children);
end;

function TMiniH.Visit_BooleanNumericExpression(const aNode: INode): TValue;
begin
  Result := aNode.Children['expression'].Value.AsExtended <> 0;
end;

function TMiniH.Visit_BooleanRelationalExpression(const aNode: INode): TValue;
var
  ChildNode: INode;
  LeftValue: Extended;
begin
  Result := True;
  LeftValue := aNode.Children['expression'].Value.AsExtended;
  if Assigned(aNode.Children['relational_expr_list'].Children) then
  begin
    for ChildNode in aNode.Children['relational_expr_list'].Children do
    begin
      case ChildNode.Children['booleanRelationalOperator'].Value.AsType<TRelationalOperator> of
        TRelationalOperator.Equal:
          Result := LeftValue = ChildNode.Children['expression'].Value.AsExtended;
        TRelationalOperator.NotEqual:
          Result := LeftValue <> ChildNode.Children['expression'].Value.AsExtended;
        TRelationalOperator.GreaterThan:
          Result := LeftValue > ChildNode.Children['expression'].Value.AsExtended;
        TRelationalOperator.LessThan:
          Result := LeftValue < ChildNode.Children['expression'].Value.AsExtended;
        TRelationalOperator.GreaterOrEqualThan:
          Result := LeftValue >= ChildNode.Children['expression'].Value.AsExtended;
        TRelationalOperator.LessOrEqualThan:
          Result := LeftValue <= ChildNode.Children['expression'].Value.AsExtended;
      end;
      LeftValue := ChildNode.Children['expression'].Value.AsExtended;
      if not Result.AsBoolean then
        Break;
    end;
  end;
end;

function TMiniH.Visit_BooleanRelationalOperator(const aNode: INode): TValue;
begin
  Result := TValue.From<TRelationalOperator>(StrToRelationalOperator(aNode.Children['op'].Text));
end;

function TMiniH.Visit_Call(const aNode: INode): TValue;
var
  MethodName: string;
  Method: IMethod;
  MethodScope: IScope;
  Arguments: IArray<Extended>;
begin
  MethodName := aNode.Children['identifier'].Value.AsString;
  if Scope.Methods.TryGetValue(MethodName, Method) then
  begin
    Arguments := aNode.Children['arguments'].Value.AsType<IArray<Extended>>;
    MethodScope := TScope.Create(Scope);
    if Method.Parameters.Count <> Arguments.Count then
      raise EArgumentCountException.CreateFmt('Method "%s" expect %d parameter%s,' +
        ' but %d got it.',
        [MethodName, Method.Parameters.Count, IfThen(Method.Parameters.Count > 1, 's'), Arguments.Count]);
    Method.Parameters.ForEachIndex(
      procedure (const aParam: string; aIndex: Integer)
      begin
        MethodScope.Variables.AddOrSetValue(aParam, Arguments[aIndex]);
      end
    );
    FScopeStack.Push(MethodScope);
    Result := Visit(Method.BodyNode);
    FScopeStack.Pop;
  end
  else
    raise EMethodNotDefinedException.CreateFmt('Method "%s" is not defined in this ' +
      'scope', [MethodName]);
end;

function TMiniH.Visit_ComparisonExpression(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value;
end;

function TMiniH.Visit_CompoundAssignment(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value;
end;

function TMiniH.Visit_DivisionAssignment(const aNode: INode): TValue;
begin
  Result := DoCompoundAssignment(aNode.Children['identifier'].Value.AsString,
    aNode.Children['expression'].Value.AsExtended,
    TCompoundAssignment.DivisionAssignment
  );
end;

function TMiniH.Visit_ExpOp(const aNode: INode): TValue;
begin
  Result := TValue.From<TArithmeticOperator>(StrToOperation(aNode.Children['op'].Text));
end;

function TMiniH.Visit_Expression(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value;
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
      Result := ApplyArithmeticOperator(
        ChildNode.Children['expOp'].Value.AsType<TArithmeticOperator>,
        Result.AsExtended,
        ChildNode.Children['atom'].Value.AsExtended
      );
    end;
  end;
end;

function TMiniH.Visit_For(const aNode: INode): TValue;
var
  VariableName: string;
  InitialValue: Extended;
begin
  Result := nil;
  InitialValue := Visit(aNode.Children[6]).AsExtended;//initialExpr
  VariableName := Visit(aNode.Children['identifier']).AsString;
  Scope.Variables.AddOrSetValue(VariableName, InitialValue);
  while Scope.Variables.Items[VariableName] <= Visit(aNode.Children[10]).AsExtended do //'finalExp'
  begin
    Result := Visit(aNode.Children['statementBody']);
    Scope.Variables.AddOrSetValue(VariableName, Scope.Variables.Items[VariableName] + 1);
  end;
  Scope.Variables.Remove(VariableName); //loop variable is only available inside loop
end;

function TMiniH.Visit_Function(const aNode: INode): TValue;
var
  Method: IMethod;
  MethodName: string;
begin
  MethodName := Visit(aNode.Children['identifier']).AsString;
  Method := TMethod.Create(Visit(aNode.Children['parameters']).AsType<IArrayString>,
                           aNode.Children['statementBody'].Children.First);
  Scope.Methods.AddOrSetValue(MethodName, Method); //overwrite the methods if it already exists
  Result := nil;
end;

function TMiniH.Visit_Identifier(const aNode: INode): TValue;
begin
  Result := aNode.Children['id'].Text;
end;

function TMiniH.Visit_IfElse(const aNode: INode): TValue;
var
  ExpressionValue: TValue;
begin
  Result := nil;
  ExpressionValue := Visit(aNode.Children['booleanExpression']);
  if ExpressionValue.AsBoolean then
    Result := Visit(aNode.Children['statementBody'])
  else
  begin
    if Assigned(aNode.Children['elsePart'].Children) then
    begin
      Visit(aNode.Children['elsePart']);
      Result := aNode.Children['elsePart'].Children.First.Children['statementBody'].Value;
    end;
  end;
end;

function TMiniH.Visit_IncrementDecrementOperator(const aNode: INode): TValue;
begin
  Result := TValue.From<TIncrementDecrementOperator>(StrToIncrementDecrementOperator(aNode.Text));
end;

function TMiniH.Visit_IntegerDivisionAssignment(const aNode: INode): TValue;
begin
  Result := DoCompoundAssignment(aNode.Children['identifier'].Value.AsString,
    aNode.Children['expression'].Value.AsExtended,
    TCompoundAssignment.IntegerDivisionAssignment
  );
end;

function TMiniH.Visit_ModuloAssignment(const aNode: INode): TValue;
begin
  Result := DoCompoundAssignment(aNode.Children['identifier'].Value.AsString,
    aNode.Children['expression'].Value.AsExtended,
    TCompoundAssignment.ModuloAssignment
  );
end;

function TMiniH.Visit_MulOp(const aNode: INode): TValue;
begin
  Result := TValue.From<TArithmeticOperator>(StrToOperation(aNode.Children['op'].Text));
end;

function TMiniH.Visit_MultiplicationAssignment(const aNode: INode): TValue;
begin
  Result := DoCompoundAssignment(aNode.Children['identifier'].Value.AsString,
    aNode.Children['expression'].Value.AsExtended,
    TCompoundAssignment.MultiplicationAssignment
  );
end;

function TMiniH.Visit_Negate(const aNode: INode): TValue;
begin
  Result := Assigned(aNode.Children);
end;

function TMiniH.Visit_Number(const aNode: INode): TValue;
begin
  Result := aNode.Children['num'].Text.Replace('.', ',').ToExtended; {TODO -oHelton -cFix : Check locale before do the text replace}
end;

function TMiniH.Visit_Parameters(const aNode: INode): TValue;
var
  Params: IArrayString;
  Node: INode;
begin
  Params := TArrayString.Create;
  Params.Add(aNode.Children['identifier'].Text);
  if Assigned(aNode.Children['params'].Children) then
  begin
    for Node in aNode.Children['params'].Children do
      Params.Add(Node.Children['identifier'].Text);
  end;
  Result := TValue.From<IArrayString>(Params);
end;

function TMiniH.Visit_ParenthesizedBooleanExpression(
  const aNode: INode): TValue;
begin
  Result := aNode.Children['booleanExpression'].Value;
end;

function TMiniH.Visit_ParenthesizedExp(const aNode: INode): TValue;
begin
  Result := aNode.Children['expression'].Value.AsExtended;
end;

function TMiniH.Visit_PosfixExpression(const aNode: INode): TValue;
var
  VariableName: string;
  Value: Extended;
begin
  VariableName := aNode.Children['identifier'].Value.AsString;
  if Scope.Variables.TryGetValue(VariableName, Value) then
  begin
    Result := Value;
    Scope.Variables.AddOrSetValue(VariableName,
      ApplyIncrementDecrementOperator(Value,
        aNode.Children['incrementDecrementOperator'].Value.AsType<TIncrementDecrementOperator>));
  end
  else
    raise EVariableNotDefinedException.CreateFmt('Variable "%s" is not defined in this ' +
      'scope', [VariableName]);
end;

function TMiniH.Visit_PowerAssignment(const aNode: INode): TValue;
begin
  Result := DoCompoundAssignment(aNode.Children['identifier'].Value.AsString,
    aNode.Children['expression'].Value.AsExtended,
    TCompoundAssignment.PowerAssignment
  );
end;

function TMiniH.Visit_PrefixExpression(const aNode: INode): TValue;
var
  VariableName: string;
  Value: Extended;
begin
  VariableName := aNode.Children['identifier'].Value.AsString;
  if Scope.Variables.TryGetValue(VariableName, Value) then
  begin
    Scope.Variables.AddOrSetValue(VariableName,
       ApplyIncrementDecrementOperator(Value, aNode.Children['incrementDecrementOperator'].Value.AsType<TIncrementDecrementOperator>));
    Result := Scope.Variables.Items[VariableName];
  end
  else
    raise EVariableNotDefinedException.CreateFmt('Variable "%s" is not defined in this ' +
      'scope', [VariableName]);
end;

function TMiniH.Visit_Program(const aNode: INode): TValue;
begin
  Result := aNode.Children['statementList'].Value;
end;

function TMiniH.Visit_SimpleAssignment(const aNode: INode): TValue;
var
  VariableName: string;
  Value: Extended;
begin
  VariableName := aNode.Children['identifier'].Value.AsString;
  Value := aNode.Children['expression'].Value.AsExtended;
  Scope.Variables.AddOrSetValue(VariableName, Value);
  Result := Value;
end;

function TMiniH.Visit_SimpleBooleanExpression(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value;
end;

function TMiniH.Visit_SimpleExpression(const aNode: INode): TValue;
var
  ChildNode: INode;
begin
  Result := aNode.Children['term'].Value.AsExtended;
  if Assigned(aNode.Children['term_list'].Children) then
  begin
    for ChildNode in aNode.Children['term_list'].Children do
    begin
      Result := ApplyArithmeticOperator(
        ChildNode.Children['addOp'].Value.AsType<TArithmeticOperator>,
        Result.AsExtended,
        ChildNode.Children['term'].Value.AsExtended
      );
    end;
  end;
  if aNode.Children['negate'].Value.AsBoolean then
    Result := -Result.AsExtended;
end;

function TMiniH.Visit_Statement(const aNode: INode): TValue;
begin
  Result := aNode.Children['stmt'].Children.First.Value;
end;

function TMiniH.Visit_StatementBlock(const aNode: INode): TValue;
begin
  Result := aNode.Children['statementList'].Value;
end;

function TMiniH.Visit_StatementBody(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value;
end;

function TMiniH.Visit_StatementList(const aNode: INode): TValue;
begin
  Result := aNode.Children['statement'].Value;
  if Assigned(aNode.Children['statement_list'].Children) then
    Result := aNode.Children['statement_list'].Children.Last.Children['statement'].Value;
end;

function TMiniH.Visit_SubtractionAssignment(const aNode: INode): TValue;
begin
  Result := DoCompoundAssignment(aNode.Children['identifier'].Value.AsString,
    aNode.Children['expression'].Value.AsExtended,
    TCompoundAssignment.SubtractionAssignment
  );
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
      Result := ApplyArithmeticOperator(
        ChildNode.Children['mulOp'].Value.AsType<TArithmeticOperator>,
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
  if Scope.Variables.TryGetValue(VariableName, Value) then
    Result := Value
  else
    raise EVariableNotDefinedException.CreateFmt('Variable "%s" is not defined in this ' +
      'scope', [VariableName]);
end;

function TMiniH.Visit_While(const aNode: INode): TValue;
begin
  Result := nil;
  while Visit(aNode.Children['booleanExpression']).AsBoolean do
    Result := Visit(aNode.Children['statementBody']);
end;

function TMiniH.Visit__(const aNode: INode): TValue;
begin
end;

{ TScope }

constructor TScope.Create(const aInnerScope: IScope);

  procedure CopyInnerScope;
  var
    Variable: TPair<string, Extended>;
    Method: TPair<string, IMethod>;
  begin
    for Variable in aInnerScope.Variables do
      FVariables.Add(Variable.Key, Variable.Value);
    for Method in aInnerScope.Methods do
      FMethods.Add(Method.Key, Method.Value);
  end;

begin
  inherited Create;
  FVariables := Collections.CreateDictionary<string, Extended>;
  FMethods := Collections.CreateDictionary<string, IMethod>;
  if Assigned(aInnerScope) then
    CopyInnerScope;
end;

function TScope.GetMethods: IDictionary<string, IMethod>;
begin
  Result := FMethods;
end;

function TScope.GetVariables: IDictionary<string, Extended>;
begin
  Result := FVariables;
end;

{ TMethod }

constructor TMethod.Create(const aParameters: IArrayString;
  const aBodyNode: INode);
begin
  inherited Create;
  FParameters := aParameters;
  FBodyNode := aBodyNode;
end;

function TMethod.GetBodyNode: INode;
begin
  Result := FBodyNode;
end;

function TMethod.GetParameters: IArrayString;
begin
  Result := FParameters;
end;

end.
