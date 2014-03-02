unit Sample.ArithmeticExpression;

interface

uses
  System.Rtti,
  HSharp.Core.Arrays,
  HSharp.PEG.Expression,
  HSharp.PEG.Expression.Interfaces,
  HSharp.PEG.Grammar,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Rule,
  HSharp.PEG.Rule.Interfaces;

type
  TArithmeticExpression = class(TGrammar)
  public
    constructor Create; overload;
    function Visit_Add(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_Number(const aNode: INode; const aArgs: IArray<TValue>): TValue;
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
    Add_Rule, Number_Rule: IRule;
  begin
    { create rules }
    Add_Rule := TRule.Create('Add');
    Number_Rule := TRule.Create('Number');

    { setup rules }
    Add_Rule.Expression := TSequenceExpression.Create([
      TRuleReferenceExpression.Create(Number_Rule),
      TLiteralExpression.Create('+'),
      TRuleReferenceExpression.Create(Number_Rule)
    ]);
    Number_Rule.Expression := TRegexExpression.Create('[0-9]+');

    { create rules array }
    SetLength(Rules, 2);
    Rules[0] := Add_Rule;
    Rules[1] := Number_Rule;
  end;

begin
  BuildRules;
  inherited Create(Rules);
end;

function TArithmeticExpression.Visit_Add(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  ShowMessage(aNode.ToString);
  Result := aArgs.Items[0].AsInteger + aArgs.Items[2].AsInteger;
end;

function TArithmeticExpression.Visit_Number(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := TValue.From<Integer>(aNode.Text.ToInteger);
end;

end.
