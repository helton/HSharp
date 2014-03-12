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

unit HSharp.PEG.Grammar.Bootstrapping;

interface

uses
  System.Rtti,
  HSharp.Core.Arrays,
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Expression,
  HSharp.PEG.Expression.Interfaces,
  HSharp.PEG.Grammar.Base,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Rule,
  HSharp.PEG.Rule.Interfaces;

type
  IBootstrappingGrammar = interface(IBaseGrammar)
    ['{D83E083A-9452-4C4F-8DFB-379CF81BFA1D}']
    function GetRules(const aGrammarText: string): IList<IRule>;
  end;

  TBootstrappingGrammar = class(TBaseGrammar, IBootstrappingGrammar)
  strict private
    FRulesMap: IDictionary<string, IRule>;
  strict protected
    function GetRuleByName(const aRuleName: string): IRule; //to solve the lazy reference problem
  public
{OK}function Visit__(const aNode: INode): TValue;
{OK}function Visit_any(const aNode: INode): TValue;
{OK}function Visit_assignment(const aNode: INode): TValue;
{OK}function Visit_atom(const aNode: INode): TValue;
{OK}function Visit_comment(const aNode: INode): TValue;
{OK}function Visit_expression(const aNode: INode): TValue;
{OK}function Visit_factor(const aNode: INode): TValue;
{OK}function Visit_identifier(const aNode: INode): TValue;
{OK}function Visit_literal(const aNode: INode): TValue;
{OK}function Visit_lookahead_term(const aNode: INode): TValue;
{OK}function Visit_negative_lookahead_term(const aNode: INode): TValue;
{OK}function Visit_optional(const aNode: INode): TValue;
{OK}function Visit_or_term(const aNode: INode): TValue;
{OK}function Visit_ored(const aNode: INode): TValue;
{OK}function Visit_parenthesized(const aNode: INode): TValue;
{OK}function Visit_quantified(const aNode: INode): TValue;
{OK}function Visit_reference(const aNode: INode): TValue;
{OK}function Visit_regex(const aNode: INode): TValue;
{OK}function Visit_repeat_at_least(const aNode: INode): TValue;
{OK}function Visit_repeat_exactly(const aNode: INode): TValue;
{OK}function Visit_repeat_one_or_more(const aNode: INode): TValue;
{OK}function Visit_repeat_range(const aNode: INode): TValue;
{OK}function Visit_repeat_up_to(const aNode: INode): TValue;
{OK}function Visit_repeat_zero_or_more(const aNode: INode): TValue;
{OK}function Visit_rule(const aNode: INode): TValue;
{OK}function Visit_rules(const aNode: INode): TValue;
{OK}function Visit_sequence(const aNode: INode): TValue;
{OK}function Visit_term(const aNode: INode): TValue;
{OK}function Visit_term_label(const aNode: INode): TValue;
{OK}function Visit_unsigned_int(const aNode: INode): TValue;
  public
    constructor Create; overload;
    { IBootstrappingGrammar }
    function GetRules(const aGrammarText: string): IList<IRule>;
  end;

implementation

uses
  HSharp.PEG.Node.Visitors,
  System.RegularExpressions,
  System.SysUtils;

{ TBootstrappingGrammar }

constructor TBootstrappingGrammar.Create;
var
  RulesList: IList<IRule>;
  _,
  any,
  assignment,
  atom,
  comment,
  expression,
  factor,
  identifier,
  literal,
  lookahead_term,
  negative_lookahead_term,
  optional,
  or_term,
  ored,
  parenthesized,
  quantified,
  reference,
  regex,
  repeat_at_least,
  repeat_exactly,
  repeat_one_or_more,
  repeat_range,
  repeat_up_to,
  repeat_zero_or_more,
  rule,
  rules,
  sequence,
  term,
  term_label,
  unsigned_int: IRule;

  procedure CreateRules;
  begin
    _                       := TRule.Create('_');
    any                     := TRule.Create('any');
    assignment              := TRule.Create('assignment');
    atom                    := TRule.Create('atom');
    comment                 := TRule.Create('comment');
    expression              := TRule.Create('expression');
    factor                  := TRule.Create('factor');
    identifier              := TRule.Create('identifier');
    literal                 := TRule.Create('literal');
    lookahead_term          := TRule.Create('lookahead_term');
    negative_lookahead_term := TRule.Create('negative_lookahead_term');
    optional                := TRule.Create('optional');
    or_term                 := TRule.Create('or_term');
    ored                    := TRule.Create('ored');
    parenthesized           := TRule.Create('parenthesized');
    quantified              := TRule.Create('quantified');
    reference               := TRule.Create('reference');
    regex                   := TRule.Create('regex');
    repeat_at_least         := TRule.Create('repeat_at_least');
    repeat_exactly          := TRule.Create('repeat_exactly');
    repeat_one_or_more      := TRule.Create('repeat_one_or_more');
    repeat_range            := TRule.Create('repeat_range');
    repeat_up_to            := TRule.Create('repeat_up_to');
    repeat_zero_or_more     := TRule.Create('repeat_zero_or_more');
    rule                    := TRule.Create('rule');
    rules                   := TRule.Create('rules');
    sequence                := TRule.Create('sequence');
    term                    := TRule.Create('term');
    term_label              := TRule.Create('term_label');
    unsigned_int            := TRule.Create('unsigned_int');
  end;

  procedure SetupRules;
  begin
    //_ = /\s+/? | comment
    _.Expression := TOneOfExpression.Create(
      [TOptionalExpression.Create(TRegexExpression.Create('\s+')),
       TRuleReferenceExpression.Create(comment)
      ]
    );
    //any = "." _
    any.Expression := TSequenceExpression.Create(
      [TLiteralExpression.Create('.'),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //assignment = "=" _
    assignment.Expression := TSequenceExpression.Create(
      [TLiteralExpression.Create('='),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //atom = reference | literal | regex | parenthesized | any
    atom.Expression := TOneOfExpression.Create(
      [TRuleReferenceExpression.Create(reference),
       TRuleReferenceExpression.Create(literal),
       TRuleReferenceExpression.Create(regex),
       TRuleReferenceExpression.Create(parenthesized),
       TRuleReferenceExpression.Create(any)
      ]
    );
    //comment = /#.*?(?:\r\n|$)/
    comment.Expression := TRegexExpression.Create('#.*?(?:' + sLineBreak + '|$)');
    //expression = ored | sequence | term
    expression.Expression := TOneOfExpression.Create(
      [TRuleReferenceExpression.Create(ored),
       TRuleReferenceExpression.Create(sequence),
       TRuleReferenceExpression.Create(term)
      ]
    );
    //factor = lookahead_term | negative_lookahead_term | quantified | atom
    factor.Expression := TOneOfExpression.Create(
      [TRuleReferenceExpression.Create(lookahead_term),
       TRuleReferenceExpression.Create(negative_lookahead_term),
       TRuleReferenceExpression.Create(quantified),
       TRuleReferenceExpression.Create(atom)
      ]
    );
    //identifier = /[a-z_][a-z0-9_]*/i _
    identifier.Expression := TSequenceExpression.Create(
      [TRegexExpression.Create('[a-z_][a-z0-9_]*', [TRegExOption.roIgnoreCase]),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //literal = /\".*?[^\\]\"/i _
    literal.Expression := TSequenceExpression.Create(
      [TRegexExpression.Create('\".*?[^\\]\"', [TRegExOption.roIgnoreCase]),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //lookahead_term = "&" term _
    lookahead_term.Expression := TSequenceExpression.Create(
      [TLiteralExpression.Create('&'),
       TRuleReferenceExpression.Create(term),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //negative_lookahead_term = "!" term _
    negative_lookahead_term.Expression := TSequenceExpression.Create(
      [TLiteralExpression.Create('!'),
       TRuleReferenceExpression.Create(term),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //optional = atom "?" _
    optional.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(atom),
       TLiteralExpression.Create('?'),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //or_term = "|" _ term
    or_term.Expression := TSequenceExpression.Create(
      [TLiteralExpression.Create('|'),
       TRuleReferenceExpression.Create(_),
       TRuleReferenceExpression.Create(term)
      ]
    );
    //ored = term or_term+
    ored.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(term),
       TRepeatOneOrMoreExpression.Create(
         TRuleReferenceExpression.Create(or_term)
       )
      ]
    );
    //parenthesized = "(" _ expression ")" _
    parenthesized.Expression := TSequenceExpression.Create(
      [TLiteralExpression.Create('('),
       TRuleReferenceExpression.Create(_),
       TRuleReferenceExpression.Create(expression),
       TLiteralExpression.Create(')'),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //quantified = repeat_exactly | repeat_range | repeat_at_least | repeat_up_to | repeat_zero_or_more | repeat_one_or_more | optional
    quantified.Expression := TOneOfExpression.Create(
      [TRuleReferenceExpression.Create(repeat_exactly),
       TRuleReferenceExpression.Create(repeat_range),
       TRuleReferenceExpression.Create(repeat_at_least),
       TRuleReferenceExpression.Create(repeat_up_to),
       TRuleReferenceExpression.Create(repeat_zero_or_more),
       TRuleReferenceExpression.Create(repeat_one_or_more),
       TRuleReferenceExpression.Create(optional)
      ]
    );
    //reference = identifier !assignment
    reference.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(identifier),
       TNegativeLookaheadExpression.Create(
         TRuleReferenceExpression.Create(assignment)
       )
      ]
    );
    //regex = /\/.*?[^\\]\// /[imesp]*/i? _
    regex.Expression := TSequenceExpression.Create(
      [TRegexExpression.Create('\/.*?[^\\]\/'),
       TOptionalExpression.Create(TRegexExpression.Create('[imesp]*', [TRegExOption.roIgnoreCase])),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //repeat_at_least = atom "{" _ unsigned_int _ "," _ "}" _
    repeat_at_least.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(atom),
       TLiteralExpression.Create('{'),
       TRuleReferenceExpression.Create(_),
       TRuleReferenceExpression.Create(unsigned_int),
       TRuleReferenceExpression.Create(_),
       TLiteralExpression.Create(','),
       TRuleReferenceExpression.Create(_),
       TLiteralExpression.Create('}'),
       TRuleReferenceExpression.Create(_)
       ]
    );
    //repeat_exactly = atom "{" _ unsigned_int  _ "}" _
    repeat_exactly.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(atom),
       TLiteralExpression.Create('{'),
       TRuleReferenceExpression.Create(_),
       TRuleReferenceExpression.Create(unsigned_int),
       TRuleReferenceExpression.Create(_),
       TLiteralExpression.Create('}'),
       TRuleReferenceExpression.Create(_)
       ]
    );
    //repeat_one_or_more = atom "+" _
    repeat_one_or_more.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(atom),
       TLiteralExpression.Create('+'),
       TRuleReferenceExpression.Create(_)
       ]
    );
    //repeat_range = atom "{" _ unsigned_int _ "," _ unsigned_int _ "}" _
    repeat_range.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(atom),
       TLiteralExpression.Create('{'),
       TRuleReferenceExpression.Create(_),
       TRuleReferenceExpression.Create(unsigned_int),
       TRuleReferenceExpression.Create(_),
       TLiteralExpression.Create(','),
       TRuleReferenceExpression.Create(_),
       TRuleReferenceExpression.Create(unsigned_int),
       TRuleReferenceExpression.Create(_),
       TLiteralExpression.Create('}'),
       TRuleReferenceExpression.Create(_)
       ]
    );
    //repeat_up_to = atom "{" _ "," _ unsigned_int _ "}" _
    repeat_up_to.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(atom),
       TLiteralExpression.Create('{'),
       TRuleReferenceExpression.Create(_),
       TLiteralExpression.Create(','),
       TRuleReferenceExpression.Create(_),
       TRuleReferenceExpression.Create(unsigned_int),
       TRuleReferenceExpression.Create(_),
       TLiteralExpression.Create('}'),
       TRuleReferenceExpression.Create(_)
       ]
    );
    //repeat_zero_or_more = atom "*" _
    repeat_zero_or_more.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(atom),
       TLiteralExpression.Create('*'),
       TRuleReferenceExpression.Create(_)
       ]
    );
    //rule = identifier assignment expression
    rule.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(identifier),
       TRuleReferenceExpression.Create(assignment),
       TRuleReferenceExpression.Create(expression)
      ]
    );
    //rules = _ rule+
    rules.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(_),
       TRepeatOneOrMoreExpression.Create(TRuleReferenceExpression.Create(rule))
      ]
    );
    //sequence = term term+
    sequence.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(term),
       TRepeatOneOrMoreExpression.Create(
         TRuleReferenceExpression.Create(term)
       )
      ]
    );
    //term = term_label factor
    term.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(term_label),
       TRuleReferenceExpression.Create(factor)
      ]
    );
    //term_label = (identifier ":")?
    term_label.Expression := TOptionalExpression.Create(
      TSequenceExpression.Create(
        [TRuleReferenceExpression.Create(identifier),
         TLiteralExpression.Create(':')
        ]
      )
    );
    //unsigned_int = /[1-9][0-9]*/ _
    unsigned_int.Expression := TSequenceExpression.Create(
      [TRegexExpression.Create('[1-9][0-9]*'),
       TRuleReferenceExpression.Create(_)
      ]
    );
  end;

  procedure AddRulesToList;
  begin
    RulesList.Add(_);
    RulesList.Add(any);
    RulesList.Add(assignment);
    RulesList.Add(atom);
    RulesList.Add(comment);
    RulesList.Add(expression);
    RulesList.Add(factor);
    RulesList.Add(identifier);
    RulesList.Add(literal);
    RulesList.Add(lookahead_term);
    RulesList.Add(negative_lookahead_term);
    RulesList.Add(optional);
    RulesList.Add(or_term);
    RulesList.Add(ored);
    RulesList.Add(parenthesized);
    RulesList.Add(quantified);
    RulesList.Add(reference);
    RulesList.Add(regex);
    RulesList.Add(repeat_at_least);
    RulesList.Add(repeat_exactly);
    RulesList.Add(repeat_one_or_more);
    RulesList.Add(repeat_range);
    RulesList.Add(repeat_up_to);
    RulesList.Add(repeat_zero_or_more);
    RulesList.Add(rule);
    RulesList.Add(rules);
    RulesList.Add(sequence);
    RulesList.Add(term);
    RulesList.Add(term_label);
    RulesList.Add(unsigned_int);
  end;

begin
  RulesList := Collections.CreateList<IRule>;
  CreateRules;
  SetupRules;
  AddRulesToList;
  inherited Create(RulesList, rules);
  FRulesMap := Collections.CreateDictionary<string, IRule>;
end;

function TBootstrappingGrammar.GetRuleByName(const aRuleName: string): IRule;
begin
  if not FRulesMap.TryGetValue(aRuleName, Result) then
  begin
    Result := TRule.Create(aRuleName);
    FRulesMap.Add(aRuleName, Result);
  end;
end;

function TBootstrappingGrammar.GetRules(const aGrammarText: string): IList<IRule>;
begin
  Result := ParseAndVisit(aGrammarText).AsType<IList<IRule>>;
end;

function TBootstrappingGrammar.Visit_any(const aNode: INode): TValue;
begin
  Result := TValue.From<IExpression>(TRegexExpression.Create('.'));
end;

function TBootstrappingGrammar.Visit_assignment(const aNode: INode): TValue;
begin
end;

function TBootstrappingGrammar.Visit_atom(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value;
end;

function TBootstrappingGrammar.Visit_comment(const aNode: INode): TValue;
begin
end;

function TBootstrappingGrammar.Visit_expression(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value;
end;

function TBootstrappingGrammar.Visit_factor(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value;
end;

function TBootstrappingGrammar.Visit_identifier(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Text;
end;

function TBootstrappingGrammar.Visit_literal(const aNode: INode): TValue;

  function ExtractLiteral(const aWrappedLiteral: string): string;
  begin
    Result := TRegEx.Match(aWrappedLiteral, '^"(?<literal>.*?)"$').
      Groups['literal'].Value;
  end;

begin
  Result := TValue.From<IExpression>(TLiteralExpression.Create(
    ExtractLiteral(aNode.Children.First.Text)));
end;

function TBootstrappingGrammar.Visit_lookahead_term(const aNode: INode): TValue;
begin
  Result := TLookaheadExpression.Create(aNode.Children[1].Value.AsType<IExpression>);
end;

function TBootstrappingGrammar.Visit_negative_lookahead_term(const aNode: INode): TValue;
begin
  Result := TNegativeLookaheadExpression.Create(aNode.Children[1].Value.AsType<IExpression>);
end;

function TBootstrappingGrammar.Visit_optional(const aNode: INode): TValue;
var
  Atom: IExpression;
begin
  Atom := aNode.Children.First.Value.AsType<IExpression>;
  Result := TValue.From<IExpression>(TOptionalExpression.Create(Atom));
end;

function TBootstrappingGrammar.Visit_ored(const aNode: INode): TValue;
var
  Expressions: array of IExpression;

  procedure AddExpressionToArray(const aExpression: IExpression);
  begin
    SetLength(Expressions, Length(Expressions) + 1);
    Expressions[High(Expressions)] := aExpression;
  end;

var
  ExpressionNode: INode;
begin
  AddExpressionToArray(aNode.Children.First.Value.AsType<IExpression>);
  for ExpressionNode in aNode.Children[1].Children do
    AddExpressionToArray(ExpressionNode.Value.AsType<IExpression>);
  Result := TValue.From<IExpression>(TOneOfExpression.Create(Expressions));
  SetLength(Expressions, 0);
end;

function TBootstrappingGrammar.Visit_or_term(const aNode: INode): TValue;
begin
  Result := aNode.Children[2].Value;
end;

function TBootstrappingGrammar.Visit_parenthesized(const aNode: INode): TValue;
begin
  Result := aNode.Children[2].Value;
end;

function TBootstrappingGrammar.Visit_quantified(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Value;
end;

function TBootstrappingGrammar.Visit_reference(const aNode: INode): TValue;
begin
  Result := TRuleReferenceExpression.Create(GetRuleByName(aNode.Children.First.Value.AsString));
end;

function TBootstrappingGrammar.Visit_regex(const aNode: INode): TValue;

  function ExtractRegexPattern(const aWrappedRegex: string): string;
  begin
    Result := TRegEx.Match(aWrappedRegex, '^/(?<pattern>.*?)/$').
      Groups['pattern'].Value;
  end;

var
  RegexOptions: TRegExOptions;
begin
  RegexOptions := [];
  if aNode.Children[1].Text.Contains('i') then
    RegexOptions := RegexOptions + [TRegExOption.roIgnoreCase];
  if aNode.Children[1].Text.Contains('m') then
    RegexOptions := RegexOptions + [TRegExOption.roMultiLine];
  if aNode.Children[1].Text.Contains('e') then
    RegexOptions := RegexOptions + [TRegExOption.roExplicitCapture];
  if aNode.Children[1].Text.Contains('s') then
    RegexOptions := RegexOptions + [TRegExOption.roSingleLine];
  if aNode.Children[1].Text.Contains('p') then
    RegexOptions := RegexOptions + [TRegExOption.roIgnorePatternSpace];
  Result := TRegexExpression.Create(ExtractRegexPattern(aNode.Children.First.Text),
     RegexOptions);
end;

function TBootstrappingGrammar.Visit_repeat_at_least(
  const aNode: INode): TValue;
var
  Atom: IExpression;
  Min: Integer;
begin
  Atom := aNode.Children.First.Value.AsType<IExpression>;
  Min := aNode.Children[3].Value.AsInteger;
  Result := TValue.From<IExpression>(TRepeatAtLeastExpression.Create(Atom, Min));
end;

function TBootstrappingGrammar.Visit_repeat_exactly(const aNode: INode): TValue;
var
  Atom: IExpression;
  Times: Integer;
begin
  Atom := aNode.Children.First.Value.AsType<IExpression>;
  Times := aNode.Children[3].Value.AsInteger;
  Result := TValue.From<IExpression>(TRepeatExactlyExpression.Create(Atom, Times));
end;

function TBootstrappingGrammar.Visit_repeat_one_or_more(
  const aNode: INode): TValue;
var
  Atom: IExpression;
begin
  Atom := aNode.Children.First.Value.AsType<IExpression>;
  Result := TValue.From<IExpression>(TRepeatOneOrMoreExpression.Create(Atom));
end;

function TBootstrappingGrammar.Visit_repeat_range(const aNode: INode): TValue;
var
  Atom: IExpression;
  Min, Max: Integer;
begin
  Atom := aNode.Children.First.Value.AsType<IExpression>;
  Min := aNode.Children[3].Value.AsInteger;
  Max := aNode.Children[7].Value.AsInteger;
  Result := TValue.From<IExpression>(TRepeatRangeExpression.Create(Atom, Min, Max));
end;

function TBootstrappingGrammar.Visit_repeat_up_to(const aNode: INode): TValue;
var
  Atom: IExpression;
  Max: Integer;
begin
  Atom := aNode.Children.First.Value.AsType<IExpression>;
  Max := aNode.Children[5].Value.AsInteger;
  Result := TValue.From<IExpression>(TRepeatUpToExpression.Create(Atom, Max));
end;

function TBootstrappingGrammar.Visit_repeat_zero_or_more(
  const aNode: INode): TValue;
var
  Atom: IExpression;
begin
  Atom := aNode.Children.First.Value.AsType<IExpression>;
  Result := TValue.From<IExpression>(TRepeatZeroOrMoreExpression.Create(Atom));
end;

function TBootstrappingGrammar.Visit_rule(const aNode: INode): TValue;
var
  Rule: IRule;
begin
  Rule := GetRuleByName(aNode.Children.First.Value.AsString);
  Rule.Expression := aNode.Children[2].Value.AsType<IExpression>;
  Result := TValue.From<IRule>(Rule);
end;

function TBootstrappingGrammar.Visit_rules(const aNode: INode): TValue;
var
  FRules: IList<IRule>;
  RuleNode: INode;
begin
  FRules := Collections.CreateList<IRule>;
  for RuleNode in aNode.Children[1].Children do
    FRules.Add(RuleNode.Value.AsType<IRule>);
  Result := TValue.From<IList<IRule>>(FRules);
end;

function TBootstrappingGrammar.Visit_sequence(const aNode: INode): TValue;
var
  Expressions: array of IExpression;

  procedure AddExpressionToArray(const aExpression: IExpression);
  begin
    SetLength(Expressions, Length(Expressions) + 1);
    Expressions[High(Expressions)] := aExpression;
  end;

var
  ExpressionNode: INode;
begin
  AddExpressionToArray(aNode.Children.First.Value.AsType<IExpression>);
  for ExpressionNode in aNode.Children[1].Children do
    AddExpressionToArray(ExpressionNode.Value.AsType<IExpression>);
  Result := TValue.From<IExpression>(TSequenceExpression.Create(Expressions));
  SetLength(Expressions, 0);
end;

function TBootstrappingGrammar.Visit_term(const aNode: INode): TValue;
var
  Expression: IExpression;
begin
  Expression := aNode.Children['factor'].Value.AsType<IExpression>;
  if not aNode.Children['term_label'].Value.IsEmpty then
    Expression.Name := aNode.Children['term_label'].Value.AsString;
  Result := TValue.From<IExpression>(Expression);
end;

function TBootstrappingGrammar.Visit_term_label(
  const aNode: INode): TValue;
begin
  Result := nil;
  if Assigned(aNode.Children) then
    Result := aNode.Children.First.Children['identifier'].Text;
end;

function TBootstrappingGrammar.Visit_unsigned_int(const aNode: INode): TValue;
begin
  Result := aNode.Children.First.Text.ToInteger;
end;

function TBootstrappingGrammar.Visit__(const aNode: INode): TValue;
begin
end;

end.
