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
  TOperation = (None, Addition, Subtraction, Multiplication, Division, Power, Radix);
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
    function StrToOperation(const aOperation: string): TOperation;
    function ExecuteOperation(aOperation: TOperation; aLeft, aRight: Extended): Extended;
    function Scope: IScope;
  public
    constructor Create; override;
  public
    [Rule('program = statementList')]
    function Visit_Program(const aNode: INode): TValue;
    [Rule('statementList = statement statement_list:(";" statement)* ";"? _')]
    function Visit_StatementList(const aNode: INode): TValue;
    [Rule('statement = _ stmt:(function | ifelse | while | for | expression) _')]
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
    [Rule('expression = _ negate term term_list:( addOp term )*')]
    function Visit_Expression(const aNode: INode): TValue;
    [Rule('term = factor factor_list:( mulOp factor )*')]
    function Visit_Term(const aNode: INode): TValue;
    [Rule('factor = atom atom_list:( expOp atom )*')]
    function Visit_Factor(const aNode: INode): TValue;
    [Rule('atom = call | parenthesizedExp | number | assignment | variable')]
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
    [Rule('ifelse = "if" _ expression _ "then" _ statementBody elsePart:(_ "else" _ statementBody)?')]
    [LazyRule]
    function Visit_IfElse(const aNode: INode): TValue;
    [Rule('while = "while" _ expression _ "do" _ statementBody')]
    [LazyRule]
    function Visit_While(const aNode: INode): TValue;
    [Rule('for = "for" _ identifier _ "=" _ initialExp:expression _ "to" _ finalExp:expression _ "do" _ statementBody')]
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
  System.StrUtils;

{ TMiniH }

constructor TMiniH.Create;
begin
  inherited;
  FScopeStack := Collections.CreateStack<IScope>;
  FScopeStack.Push(TScope.Create);
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

function TMiniH.Scope: IScope;
begin
  Result := FScopeStack.Peek;
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
var
  Name: string;
  Value: Extended;
begin
  Name := aNode.Children['identifier'].Value.AsString;
  Value := aNode.Children['expression'].Value.AsExtended;
  Scope.Variables.AddOrSetValue(Name, Value);
  Result := Value;
end;

function TMiniH.Visit_Atom(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value.AsExtended;
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
  ExpressionValue := Visit(aNode.Children['expression']);
  if ExpressionValue.AsExtended <> 0 then
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

function TMiniH.Visit_ParenthesizedExp(const aNode: INode): TValue;
begin
  Result := aNode.Children['expression'].Value.AsExtended;
end;

function TMiniH.Visit_Program(const aNode: INode): TValue;
begin
  Result := aNode.Children['statementList'].Value;
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
  if Scope.Variables.TryGetValue(VariableName, Value) then
    Result := Value
  else
    raise EVariableNotDefinedException.CreateFmt('Variable "%s" is not defined in this ' +
      'scope', [VariableName]);
end;

function TMiniH.Visit_While(const aNode: INode): TValue;
begin
  Result := nil;
  while Visit(aNode.Children['expression']).AsExtended <> 0 do
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
