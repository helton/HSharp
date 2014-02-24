unit HSharp.PEG.Expression;

interface

uses
  System.RegularExpressions,
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.Core.RegularExpressions,
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Exceptions,
  HSharp.PEG.Expression.Interfaces,
  HSharp.PEG.Rule.Interfaces;

type
  {$REGION 'Base/abstract classes'}

  // A thing that can be matched against a piece of text
  TExpression = class abstract(TInterfacedObject, IExpression)
  strict private
    FText: string;
  strict protected
    function GetText: string;
    procedure SetText(aText: string); //can't be used as a set function to Text property
    function ApplyExpression(const aContext: IContext): Boolean; virtual; abstract;
  public
    function IsMatch(const aContext: IContext): Boolean;
    procedure Match(const aContext: IContext);
    function AsString: string; virtual; abstract;
    property Text: string read GetText;
  end;

  // A container that hold a simple expression
  TExpressionContainer = class abstract(TExpression)
  strict private
    FExpression: IExpression;
  strict protected
    property Expression: IExpression read FExpression;
  public
    constructor Create(const aExpression: IExpression); reintroduce;
    function AsString: string; override;
  end;

  // An abstract expression which contains other expressions
  TCompoundExpression = class abstract(TExpression)
  strict private
    FExpressions: IList<IExpression>;
  strict protected
    property Expressions: IList<IExpression> read FExpressions;
  public
    constructor Create(const aExpressions: array of IExpression); reintroduce;
  end;

  {$ENDREGION}

  // A string literal
  TLiteralExpression = class(TExpression)
  strict private
    FLiteral: string;
  strict protected
    function ApplyExpression(const aContext: IContext): Boolean; override;
  public
    constructor Create(const aLiteral: string); reintroduce;
    function AsString: string; override;
  end;

  // An expression that matches what a regex does.
  TRegexExpression = class(TExpression)
  strict private
    FRegEx: TRegEx;
  strict protected
    function ApplyExpression(const aContext: IContext): Boolean; override;
  public
    constructor Create(const aPattern: string; aRegExOptions: TRegExOptions = []); reintroduce;
    function AsString: string; override;
  end;

  // A series of expressions that must match contiguous, ordered pieces of
  // the text.
  // In other words, it's a concatenation operator: each piece has to match, one
  // after another.
  TSequenceExpression = class(TCompoundExpression)
  strict protected
    function ApplyExpression(const aContext: IContext): Boolean; override;
  public
    function AsString: string; override;
  end;

  // A series of expressions, one of which must match.
  // Expressions are tested in order from first to last. The first to succeed
  // wins
  TOneOfExpression = class(TCompoundExpression)
  strict protected
    function ApplyExpression(const aContext: IContext): Boolean; override;
  public
    function AsString: string; override;
  end;

  // An expression which consumes nothing, even if its contained expression
  // succeeds
  TLookahedExpression = class(TExpressionContainer)
  strict protected
    function ApplyExpression(const aContext: IContext): Boolean; override;
  end;

  // An expression that succeeds only if the expression within it doesn't
  // In any case, it never consumes any characters
  TNegativeLookaheadExpression = class(TExpressionContainer)
  strict protected
    function ApplyExpression(const aContext: IContext): Boolean; override;
  public
    function AsString: string; override;
  end;

  {$REGION 'Quantifiers expressions'}

  // An expression wrapper like the repetition {min,} in regexes.
  TRepeatAtLeastExpression = class(TExpressionContainer)
  strict private
    FMin: Integer;
  strict protected
    function ApplyExpression(const aContext: IContext): Boolean; override;
  public
    constructor Create(const aExpression: IExpression; aMin: Integer); reintroduce;
  end;

  // An expression wrapper like the repetition {min,max} in regexes.
  TRepeatRangeExpression = class(TExpressionContainer)
  strict private
    FMin, FMax: Integer;
  strict protected
    function ApplyExpression(const aContext: IContext): Boolean; override;
  public
    constructor Create(const aExpression: IExpression; aMin, aMax: Integer); reintroduce;
  end;

  // An expression wrapper like the * quantifier in regexes
  TRepeatZeroOrMoreExpression = class(TRepeatAtLeastExpression)
  public
    constructor Create(const aExpression: IExpression); reintroduce;
  end;

  // An expression wrapper like the + quantifier in regexes.
  TRepeatOneOrMoreExpression = class(TRepeatAtLeastExpression)
  public
    constructor Create(const aExpression: IExpression); reintroduce;
  end;

  // An expression that succeeds whether or not the contained one does
  // If the contained expression succeeds, it goes ahead and consumes what it
  // consumes. Otherwise, it consumes nothing.
  TRepeatOptionalExpression = class(TRepeatRangeExpression)
  public
    constructor Create(const aExpression: IExpression); reintroduce;
  end;

  // An expression wrapper like the repetition {times} in regexes.
  TRepeatExactlyExpression = class(TRepeatRangeExpression)
  public
    constructor Create(const aExpression: IExpression; aTimes: Integer); reintroduce;
  end;

  // An expression wrapper like the repetition {times} in regexes.
  TRepeatUpToExpression = class(TRepeatRangeExpression)
  public
    constructor Create(const aExpression: IExpression; aMax: Integer); reintroduce;
  end;

  {$ENDREGION}

  TRuleReferenceExpression = class(TExpression)
  strict private
    FRule: IRule;
  strict protected
    function ApplyExpression(const aContext: IContext): Boolean; override;
  public
    constructor Create(const aRule: IRule); reintroduce;
    function AsString: string; override;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils;

{ TExpression }

function TExpression.IsMatch(const aContext: IContext): Boolean;
begin
  aContext.SaveState;
  try
    Result := ApplyExpression(aContext);
  except
    on EMatchError do
      Result := False
    else
      raise;
  end;
  aContext.RestoreState;
  FText := '';
end;

function TExpression.GetText: string;
begin
  Result := FText;
end;

procedure TExpression.Match(const aContext: IContext);
var
  Success: Boolean;
begin
  Success := ApplyExpression(aContext);
  if not Success then
    raise EMatchError.Create('Can''t match text'); {TODO -oHelton -cImprove : Improve error message with more details}
end;

procedure TExpression.SetText(aText: string);
begin
  FText := aText;
end;

{ TRegexExpression }

constructor TRegexExpression.Create(const aPattern: string;
  aRegExOptions: TRegExOptions);
begin
  inherited Create;
  FRegEx := TRegEx.Create('^' + aPattern, aRegExOptions + [TRegExOption.roCompiled]);
end;

function TRegexExpression.ApplyExpression(const aContext: IContext): Boolean;
var
  Match: TMatch;
begin
  Match  := FRegex.Match(aContext.Text);
  Result := Match.Success;
  if Result then
  begin
    aContext.IncIndex(Match.Index + Match.Length - 1);
    SetText(Match.Value);
  end;
end;

function TRegexExpression.AsString: string;
var
  RegExOptions: TRegExOptions;
begin
  Result := '"' + RightStr(FRegEx.GetPattern, FRegEx.GetPattern.Length - 1) + '"';
  RegExOptions := FRegEx.GetOptions;
  if TRegExOption.roIgnoreCase in RegExOptions then
    Result := Result + 'i';
  if TRegExOption.roMultiLine in RegExOptions then
    Result := Result + 'm';
  if TRegExOption.roExplicitCapture in RegExOptions then
    Result := Result + 'e';
  if TRegExOption.roSingleLine in RegExOptions then
    Result := Result + 's';
  if TRegExOption.roIgnorePatternSpace in RegExOptions then
    Result := Result + 'p';
end;

{ TLiteralExpression }

function TLiteralExpression.ApplyExpression(const aContext: IContext): Boolean;
begin
  Result := aContext.Text.StartsWith(FLiteral);
  if Result then
  begin
    aContext.IncIndex(FLiteral.Length);
    SetText(FLiteral);
  end;
end;

function TLiteralExpression.AsString: string;
begin
  Result := QuotedStr(FLiteral);
end;

constructor TLiteralExpression.Create(const aLiteral: string);
begin
  inherited Create;
  FLiteral := aLiteral;
end;

{ TCompoundExpression }

constructor TCompoundExpression.Create(
  const aExpressions: array of IExpression);
begin
  inherited Create;
  FExpressions := Collections.CreateList<IExpression>;
  FExpressions.AddRange(aExpressions);
end;

{ TSequenceExpressions }

function TSequenceExpression.ApplyExpression(
  const aContext: IContext): Boolean;
var
  Expression: IExpression;
begin
  Result := False;
  for Expression in Expressions do
  begin
    Result := Expression.IsMatch(aContext);
    Expression.Match(aContext);
    SetText(Text + Expression.Text);
  end;
end;

function TSequenceExpression.AsString: string;
var
  Expression: IExpression;
begin
  for Expression in Expressions do
  begin
    if Result.IsEmpty then
      Result := Expression.AsString
    else
      Result := Result + ' ' + Expression.AsString;
  end;
end;

{ TPrioritizedChoiceExpression }

function TOneOfExpression.ApplyExpression(
  const aContext: IContext): Boolean;
var
  Expression: IExpression;
begin
  Result := False;
  for Expression in Expressions do
  begin
    Result := Expression.IsMatch(aContext);
    if Result then
    begin
      Expression.Match(aContext);
      SetText(Text + Expression.Text);
      Break;
    end;
  end;
end;

function TOneOfExpression.AsString: string;
var
  Expression: IExpression;
begin
  for Expression in Expressions do
  begin
    if Result.IsEmpty then
      Result := Expression.AsString
    else
      Result := Result + ' / ' + Expression.AsString;
  end;
end;

{ TExpressionContainer }

function TExpressionContainer.AsString: string;
begin
  Result := FExpression.AsString;
end;

constructor TExpressionContainer.Create(const aExpression: IExpression);
begin
  inherited Create;
  FExpression := aExpression;
end;

{ TLookahedExpression }

function TLookahedExpression.ApplyExpression(const aContext: IContext): Boolean;
begin
  Result := Expression.IsMatch(aContext); { don't consumes text }
end;

{ TNegativeLookaheadExpression }

function TNegativeLookaheadExpression.ApplyExpression(const aContext: IContext): Boolean;
begin
  Result := not Expression.IsMatch(aContext); { don't consumes text }
end;

function TNegativeLookaheadExpression.AsString: string;
begin
  Result := '!' + inherited;
end;

{ TRepeatZeroOrMoreExpression }

constructor TRepeatZeroOrMoreExpression.Create(const aExpression: IExpression);
begin
  inherited Create(aExpression, 0);
end;

{ TRepeatOneOrMoreExpression }

constructor TRepeatOneOrMoreExpression.Create(const aExpression: IExpression);
begin
  inherited Create(aExpression, 1);
end;

{ TRepeatRangeExpression }

function TRepeatRangeExpression.ApplyExpression(
  const aContext: IContext): Boolean;
var
  Count: Integer;
  i: Integer;
begin
  for i in [1..FMin] do
    Expression.Match(aContext);
  Count  := FMin;
  Result := True;
  while (Count < FMax) and Expression.IsMatch(aContext) do
  begin
    Expression.Match(aContext);
    Inc(Count);
  end;
end;

constructor TRepeatRangeExpression.Create(const aExpression: IExpression; aMin,
  aMax: Integer);
begin
  inherited Create(aExpression);
  FMin := aMin;
  FMax := aMax;
  if FMin < 0 then
    raise EArgumentException.Create('Min should be positive');
  if FMax < 0 then
    raise EArgumentException.Create('Max should be positive');
  if FMin > FMax then
    raise EArgumentException.Create('Min should be greater or equal than Max');
end;

{ TRepeatExactlyExpression }

constructor TRepeatExactlyExpression.Create(const aExpression: IExpression;
  aTimes: Integer);
begin
  inherited Create(aExpression, aTimes, aTimes);
  if aTimes < 0 then
    raise EArgumentException.Create('Times should be positive');
end;

{ TRepeatAtLeastExpression }

function TRepeatAtLeastExpression.ApplyExpression(
  const aContext: IContext): Boolean;
var
  i: Integer;
begin
  for i in [1..FMin] do
    Expression.Match(aContext);
  Result := True;
  while Expression.IsMatch(aContext) do
    Expression.Match(aContext);
end;

constructor TRepeatAtLeastExpression.Create(const aExpression: IExpression;
  aMin: Integer);
begin
  inherited Create(aExpression);
  FMin := aMin;
  if FMin < 0 then
    raise EArgumentException.Create('Min should be positive');
end;

{ TRepeatOptionalExpression }

constructor TRepeatOptionalExpression.Create(const aExpression: IExpression);
begin
  inherited Create(aExpression, 0, 1);
end;

{ TRepeatUpToExpression }

constructor TRepeatUpToExpression.Create(const aExpression: IExpression;
  aMax: Integer);
begin
  inherited Create(aExpression, 0, aMax);
  if aMax < 0 then
    raise EArgumentException.Create('Max should be positive');
end;

{ TRuleReferenceExpression }

function TRuleReferenceExpression.ApplyExpression(
  const aContext: IContext): Boolean;
begin
  Result := FRule.Expression.IsMatch(aContext);
  FRule.Expression.Match(aContext);
end;

function TRuleReferenceExpression.AsString: string;
begin
  Result := FRule.Name;
end;

constructor TRuleReferenceExpression.Create(const aRule: IRule);
begin
  inherited Create;
  FRule := aRule;
end;

end.
