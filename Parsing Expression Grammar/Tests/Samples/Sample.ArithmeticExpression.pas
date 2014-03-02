unit Sample.ArithmeticExpression;

interface

uses
  System.Rtti,
  HSharp.Core.Arrays,
  HSharp.PEG.Expression,
  HSharp.PEG.Expression.Interfaces,
  HSharp.PEG.Grammar,
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
    { <add> = number ("+" number)* }
    function Visit_Add(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    { <number> = _? /[0-9]+/ _? }
    function Visit_Number(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    { <_> = /\s+/ }
    function Visit__(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function GenericVisit(const aNode: INode; const aArgs: IArray<TValue>): TValue;
  public
    constructor Create; overload;
    function Evaluate(const aExpression: string): Integer;
  end;

implementation

uses
  System.SysUtils,
  Vcl.Dialogs; {TODO -oHelton -cRemove : Remove!}

{ TArithmeticExpression }

constructor TArithmeticExpression.Create;
var
  Rules: array of IRule;

  procedure BuildRules;
  var
    Add_Rule, Number_Rule, __Rule: IRule;
  begin
    { create rules }
    Add_Rule := TRule.Create('Add');
    Number_Rule := TRule.Create('Number');
    __Rule  := TRule.Create('_');

    { setup rules }

    { <add> = number ("+" number)* }
    Add_Rule.Expression := TSequenceExpression.Create([
      TRuleReferenceExpression.Create(Number_Rule),
      TRepeatZeroOrMoreExpression.Create(TSequenceExpression.Create([
        TLiteralExpression.Create('+'),
        TRuleReferenceExpression.Create(Number_Rule)
      ]))
    ]);
    { <number> = _? /[0-9]+/ _? }
    Number_Rule.Expression := TSequenceExpression.Create([
      TRepeatOptionalExpression.Create(TRuleReferenceExpression.Create(__Rule)),
      TRegexExpression.Create('[0-9]+'),
      TRepeatOptionalExpression.Create(TRuleReferenceExpression.Create(__Rule))
    ]);
    { <_> = /\s+/ }
    __Rule.Expression :=  TRegexExpression.Create('\s+');

    { create rules array }
    SetLength(Rules, 3);
    Rules[0] := Add_Rule;
    Rules[1] := Number_Rule;
    Rules[2] := __Rule;
  end;

begin
  BuildRules;
  inherited Create(Rules);
end;

function TArithmeticExpression.Evaluate(const aExpression: string): Integer;
begin
  Result := ParseAndVisit(aExpression).AsInteger;
end;

function TArithmeticExpression.GenericVisit(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
end;

{ <add> = number ("+" number)* }
function TArithmeticExpression.Visit_Add(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
var
  Node: INode;
begin
  Result := aArgs.Items[0].AsInteger;
  for Node in aNode.Children[1].Children do
    Result := Result.AsInteger + Node.Children[1].Text.ToInteger;
end;

{ <number> = _? /[0-9]+/ _? }
function TArithmeticExpression.Visit_Number(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := aNode.Children[1].Text.ToInteger;
end;

{ <_> = /\s+/ }
function TArithmeticExpression.Visit__(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
end;

end.
