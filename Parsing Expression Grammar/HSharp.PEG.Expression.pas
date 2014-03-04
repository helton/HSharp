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
  HSharp.PEG.Node,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Rule.Interfaces;

type
  {$REGION 'Base/abstract classes'}

  // A thing that can be matched against a piece of text
  TExpression = class abstract(TInterfacedObject, IExpression)
  strict private
    FName: string;
  strict protected
    { IExpression }
    procedure SetName(const aName: string);
    function GetName: string;
    function ApplyExpression(const aContext: IContext): INode; virtual; abstract;
  public
    constructor Create(const aName: string); overload;
    function IsMatch(const aContext: IContext): Boolean;
    function Match(const aContext: IContext): INode;
    function AsString: string; virtual; abstract;
    property Name: string read GetName write SetName;
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
    function ApplyExpression(const aContext: IContext): INode; override;
  public
    constructor Create(const aLiteral: string); reintroduce;
    function AsString: string; override;
  end;

  // An expression that matches what a regex does.
  TRegexExpression = class(TExpression)
  strict private
    FRegEx: TRegEx;
  strict protected
    function ApplyExpression(const aContext: IContext): INode; override;
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
    function ApplyExpression(const aContext: IContext): INode; override;
  public
    function AsString: string; override;
  end;

  // A series of expressions, one of which must match.
  // Expressions are tested in order from first to last. The first to succeed
  // wins
  TOneOfExpression = class(TCompoundExpression)
  strict protected
    function ApplyExpression(const aContext: IContext): INode; override;
  public
    function AsString: string; override;
  end;

  // An expression which consumes nothing, even if its contained expression
  // succeeds
  TLookaheadExpression = class(TExpressionContainer)
  strict protected
    function ApplyExpression(const aContext: IContext): INode; override;
  public
    function AsString: string; override;
  end;

  // An expression that succeeds only if the expression within it doesn't
  // In any case, it never consumes any characters
  TNegativeLookaheadExpression = class(TExpressionContainer)
  strict protected
    function ApplyExpression(const aContext: IContext): INode; override;
  public
    function AsString: string; override;
  end;

  {$REGION 'Quantifiers expressions'}

  // An expression wrapper like the repetition {min,} in regexes.
  TRepeatAtLeastExpression = class(TExpressionContainer)
  strict private
    FMin: Integer;
  strict protected
    function ApplyExpression(const aContext: IContext): INode; override;
  public
    constructor Create(const aExpression: IExpression; aMin: Integer); reintroduce;
    function AsString: string; override;
  end;

  // An expression wrapper like the repetition {min,max} in regexes.
  TRepeatRangeExpression = class(TExpressionContainer)
  strict private
    FMin, FMax: Integer;
  strict protected
    function ApplyExpression(const aContext: IContext): INode; override;
  public
    constructor Create(const aExpression: IExpression; aMin, aMax: Integer); reintroduce;
    function AsString: string; override;
  end;

  // An expression wrapper like the * quantifier in regexes
  TRepeatZeroOrMoreExpression = class(TRepeatAtLeastExpression)
  public
    constructor Create(const aExpression: IExpression); reintroduce;
    function AsString: string; override;
  end;

  // An expression wrapper like the + quantifier in regexes.
  TRepeatOneOrMoreExpression = class(TRepeatAtLeastExpression)
  public
    constructor Create(const aExpression: IExpression); reintroduce;
    function AsString: string; override;
  end;

  // An expression that succeeds whether or not the contained one does
  // If the contained expression succeeds, it goes ahead and consumes what it
  // consumes. Otherwise, it consumes nothing.
  TRepeatOptionalExpression = class(TRepeatRangeExpression)
  strict protected
    function ApplyExpression(const aContext: IContext): INode; override;
  public
    constructor Create(const aExpression: IExpression); reintroduce;
    function AsString: string; override;
  end;

  // An expression wrapper like the repetition {times} in regexes.
  TRepeatExactlyExpression = class(TRepeatRangeExpression)
  strict private
    FTimes: Integer;
  public
    constructor Create(const aExpression: IExpression; aTimes: Integer); reintroduce;
    function AsString: string; override;
  end;

  // An expression wrapper like the repetition {0,max} in regexes.
  TRepeatUpToExpression = class(TRepeatRangeExpression)
  public
    constructor Create(const aExpression: IExpression; aMax: Integer); reintroduce;
  end;

  {$ENDREGION}

  TRuleReferenceExpression = class(TExpression)
  strict private
    FRule: IRule;  //should be a weak reference?
  strict protected
    function ApplyExpression(const aContext: IContext): INode; override;
  public
    constructor Create(const aRule: IRule); reintroduce;
    function AsString: string; override;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils;

{ TExpression }

constructor TExpression.Create(const aName: string);
begin
  inherited Create;
  FName := aName;
end;

function TExpression.GetName: string;
begin
  Result := FName;
end;

function TExpression.IsMatch(const aContext: IContext): Boolean;
begin
  aContext.SaveState;
  try
    Result := ApplyExpression(aContext) <> nil;
  except
    on EMatchError do
      Result := False
    else
      raise;
  end;
  aContext.RestoreState;
end;

function TExpression.Match(const aContext: IContext): INode;
var
  SavedIndex: Integer;
begin
  SavedIndex := aContext.Index;
  Result := ApplyExpression(aContext);
  if not Assigned(Result) then
    raise EMatchError.Create('[' + FName + '] - Can''t match text at position ' +
      SavedIndex.ToString + ' after "' + LeftStr(aContext.Text, 100) + '" ...');
end;

procedure TExpression.SetName(const aName: string);
begin
  FName := aName;
end;

{ TRegexExpression }

constructor TRegexExpression.Create(const aPattern: string;
  aRegExOptions: TRegExOptions);
begin
  inherited Create;
  FRegEx := TRegEx.Create('^' + aPattern, aRegExOptions + [TRegExOption.roCompiled]);
end;

function TRegexExpression.ApplyExpression(const aContext: IContext): INode;
var
  Match: TMatch;
  PreviousIndex: Integer;
begin
  Result := nil;
  PreviousIndex := aContext.Index;
  Match  := FRegex.Match(aContext.Text);
  if Match.Success then
  begin
    aContext.IncIndex(Match.Index + Match.Length - 1);
    Result := TRegexNode.Create(Name, Match, PreviousIndex);
  end;
end;

function TRegexExpression.AsString: string;
var
  RegExOptions: TRegExOptions;
begin
  Result := '/' + RightStr(FRegEx.GetPattern, FRegEx.GetPattern.Length - 1) + '/';
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

function TLiteralExpression.ApplyExpression(const aContext: IContext): INode;
var
  PreviousIndex: Integer;
begin
  Result := nil;
  PreviousIndex := aContext.Index;
  if aContext.Text.StartsWith(FLiteral) then
  begin
    aContext.IncIndex(FLiteral.Length);
    Result := TNode.Create(Name, FLiteral, PreviousIndex);
  end;
end;

function TLiteralExpression.AsString: string;
begin
  Result := '"' + FLiteral + '"';
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
  const aContext: IContext): INode;
var
  Expression: IExpression;
  PreviousIndex: Integer;
  Children: INodeList;
  ChildNode: INode;
  FullText: string;
begin
  Result := nil;
  PreviousIndex := aContext.Index;
  FullText := '';
  Children := TNodeList.Create;
  for Expression in Expressions do
  begin
    ChildNode := Expression.Match(aContext);
    Children.Add(ChildNode);
    FullText := FullText + ChildNode.Text;
  end;
  if FullText.IsEmpty then
    Children := nil;
  Result := TNode.Create(Name, FullText, PreviousIndex, Children);
end;

function TSequenceExpression.AsString: string;
var
  Expression: IExpression;
begin
  Result := '';
  for Expression in Expressions do
  begin
    if Result.IsEmpty then
      Result := Expression.AsString
    else
      Result := Result + ' ' + Expression.AsString;
  end;
end;

{ TOneOfExpression }

function TOneOfExpression.ApplyExpression(
  const aContext: IContext): INode;
var
  Expression: IExpression;
  Children: INodeList;
  PreviousIndex: Integer;
begin
  Result := nil;
  PreviousIndex := aContext.Index;
  Children := TNodeList.Create;
  for Expression in Expressions do
  begin
    if Expression.IsMatch(aContext) then
    begin
      Children.Add(Expression.Match(aContext));
      Result := TNode.Create(Name, Children[0].Text, PreviousIndex, Children);
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
      Result := Result + ' | ' + Expression.AsString;
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

{ TLookaheadExpression }

function TLookaheadExpression.ApplyExpression(const aContext: IContext): INode;
var
  Node: INode;
  Children: INodeList;
  PreviousIndex: Integer;
begin
  Result := nil;
  PreviousIndex := aContext.Index;
  aContext.SaveState;
  Node := Expression.Match(aContext); { don't consumes text }
  if Assigned(Node) then
  begin
    Children := TNodeList.Create;
    Children.Add(Node);
  end;
  Result := TNode.Create(Name, Node.Text, PreviousIndex, Children);
  aContext.RestoreState;
end;

function TLookaheadExpression.AsString: string;
begin
  Result := '&' + inherited;
end;

{ TNegativeLookaheadExpression }

function TNegativeLookaheadExpression.ApplyExpression(const aContext: IContext): INode;
var
  PreviousIndex: Integer;
begin
  Result := nil;
  PreviousIndex := aContext.Index;
  aContext.SaveState;
  if not Expression.IsMatch(aContext) then
    Result := TNode.Create(Name, '', PreviousIndex);  {TODO -oHelton -cCheck : Is is right?}
  aContext.RestoreState;
end;

function TNegativeLookaheadExpression.AsString: string;
begin
  Result := '!' + inherited;
end;

{ TRepeatZeroOrMoreExpression }

function TRepeatZeroOrMoreExpression.AsString: string;
begin
  Result := Expression.AsString + '*';
end;

constructor TRepeatZeroOrMoreExpression.Create(const aExpression: IExpression);
begin
  inherited Create(aExpression, 0);
end;

{ TRepeatOneOrMoreExpression }

function TRepeatOneOrMoreExpression.AsString: string;
begin
  Result := Expression.AsString + '+';
end;

constructor TRepeatOneOrMoreExpression.Create(const aExpression: IExpression);
begin
  inherited Create(aExpression, 1);
end;

{ TRepeatRangeExpression }

function TRepeatRangeExpression.ApplyExpression(
  const aContext: IContext): INode;
var
  Count: Integer;
  i: Integer;
  PreviousIndex: Integer;
  Children: INodeList;
  ChildNode: INode;
  FullText: string;
begin
  Result := nil;
  PreviousIndex := aContext.Index;
  FullText := '';
  Children := TNodeList.Create;
  for i in [1..FMin] do
  begin
    ChildNode := Expression.Match(aContext);
    Children.Add(ChildNode);
    FullText := FullText + ChildNode.Text;
  end;
  Count := FMin;
  while (Count < FMax) and Expression.IsMatch(aContext) do
  begin
    ChildNode := Expression.Match(aContext);
    Children.Add(ChildNode);
    FullText := FullText + ChildNode.Text;
    Inc(Count);
  end;
  if FullText.IsEmpty then
    Children := nil;
  Result := TNode.Create(Name, FullText, PreviousIndex, Children);
end;

function TRepeatRangeExpression.AsString: string;
begin
  Result := inherited + '{' + FMin.ToString + ',' + FMax.ToString + '}';
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

function TRepeatExactlyExpression.AsString: string;
begin
  Result := Expression.AsString + '{' + FTimes.ToString + '}';
end;

constructor TRepeatExactlyExpression.Create(const aExpression: IExpression;
  aTimes: Integer);
begin
  inherited Create(aExpression, aTimes, aTimes);
  FTimes := aTimes;
  if FTimes < 0 then
    raise EArgumentException.Create('Times should be positive');
end;

{ TRepeatAtLeastExpression }

function TRepeatAtLeastExpression.ApplyExpression(
  const aContext: IContext): INode;
var
  i: Integer;
  PreviousIndex: Integer;
  Children: INodeList;
  ChildNode: INode;
  FullText: string;
begin
  Result := nil;
  FullText := '';
  PreviousIndex := aContext.Index;
  Children := TNodeList.Create;
  for i in [1..FMin] do
  begin
    ChildNode := Expression.Match(aContext);
    Children.Add(ChildNode);
    FullText := FullText + ChildNode.Text;
  end;
  while Expression.IsMatch(aContext) do
  begin
    ChildNode := Expression.Match(aContext);
    Children.Add(ChildNode);
    FullText := FullText + ChildNode.Text;
  end;
  if FullText.IsEmpty then
    Children := nil;
  Result := TNode.Create(Name, FullText, PreviousIndex, Children);
end;

function TRepeatAtLeastExpression.AsString: string;
begin
  Result := inherited + '{' + FMin.ToString + ',}'; {TODO -oHelton -cAdd : Add parenthesis if inner expression is a list ("sequence" or "one of")}
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

function TRepeatOptionalExpression.ApplyExpression(
  const aContext: IContext): INode;
var
  Node: INode;
begin
  Node := inherited;
  Result := TNode.Create(Name, Node.Text, Node.Index, nil); {TODO -oHelton -cQuestion : Is is right?}
end;

function TRepeatOptionalExpression.AsString: string;
begin
  Result := Expression.AsString + '?';
end;

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
  const aContext: IContext): INode;
begin
  Result := FRule.Expression.Match(aContext); {TODO -oHelton -cQuestion : Is is right?}
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
