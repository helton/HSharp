unit Sample.ArithmeticExpression;

interface

uses
  System.Rtti,
  HSharp.Core.Arrays,
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Expression,
  HSharp.PEG.Expression.Interfaces,
  HSharp.PEG.Grammar,
  HSharp.PEG.Grammar.Attributes,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Rule,
  HSharp.PEG.Rule.Interfaces;

type
  IArithmeticExpression = interface(IGrammar)
    ['{64DA187A-3794-4FE1-897F-AD834BF64163}']
    function Evaluate(const aExpression: string): Integer;
  end;

  TArithmeticExpression = class(TGrammar, IArithmeticExpression)
  public
    [Rule('add = number ("+" number)*')]
    function Visit_Add(const aNode: INode): TValue;
    [Rule('number = _ /[0-9]+/ _')]
    function Visit_Number(const aNode: INode): TValue;
    [Rule('_ = /\s+/?')]
    function Visit__(const aNode: INode): TValue;
    function GenericVisit(const aNode: INode): TValue;
  public
    function Evaluate(const aExpression: string): Integer;
  end;

implementation

uses
  System.SysUtils;

{ TArithmeticExpression }

function TArithmeticExpression.Evaluate(const aExpression: string): Integer;
begin
  Result := ParseAndVisit(aExpression).AsInteger;
end;

function TArithmeticExpression.GenericVisit(const aNode: INode): TValue;
begin
end;

function TArithmeticExpression.Visit_Add(const aNode: INode): TValue;
var
  ChildNode: INode;
begin
  Result := aNode.Children[0].Value.AsInteger;
  for ChildNode in aNode.Children[1].Children do
    Result := Result.AsInteger + ChildNode.Children[1].Text.ToInteger;
end;

function TArithmeticExpression.Visit_Number(const aNode: INode): TValue;
begin
  Result := aNode.Children[1].Text.ToInteger;
end;

function TArithmeticExpression.Visit__(const aNode: INode): TValue;
begin
end;

end.
