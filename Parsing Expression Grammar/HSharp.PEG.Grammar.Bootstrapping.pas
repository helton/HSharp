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
{??}function Visit_rules(const aNode: INode): TValue;
{OK}function Visit_rule(const aNode: INode): TValue;
{OK}function Visit_assignment(const aNode: INode): TValue;
{OK}function Visit_literal(const aNode: INode): TValue;
{OK}function Visit_expression(const aNode: INode): TValue;
{OK}function Visit_expression_label(const aNode: INode): TValue;
{OK}function Visit_or_term(const aNode: INode): TValue;
{OK}function Visit_ored(const aNode: INode): TValue;
{OK}function Visit_sequence(const aNode: INode): TValue;
{OK}function Visit_negative_lookahead_term(const aNode: INode): TValue;
{OK}function Visit_lookahead_term(const aNode: INode): TValue;
{OK}function Visit_term(const aNode: INode): TValue;
{OK}function Visit_quantified(const aNode: INode): TValue;
{OK}function Visit_atom(const aNode: INode): TValue;
{OK}function Visit_regex(const aNode: INode): TValue;
{OK}function Visit_parenthesized(const aNode: INode): TValue;
{OK}function Visit_quantifier(const aNode: INode): TValue;
    function Visit_repetition(const aNode: INode): TValue;
{OK}function Visit_reference(const aNode: INode): TValue;
{OK}function Visit_identifier(const aNode: INode): TValue;
{OK}function Visit__(const aNode: INode): TValue;
{OK}function Visit_comment(const aNode: INode): TValue;
  public
    constructor Create; overload;
    { IBootstrappingGrammar }
    function GetRules(const aGrammarText: string): IList<IRule>;
  end;

implementation

uses
  Vcl.Dialogs, {TODO -oHelton -cRemove : Remove!}
  HSharp.PEG.Node.Visitors,

  System.RegularExpressions,
  System.SysUtils;

{ TBootstrappingGrammar }

constructor TBootstrappingGrammar.Create;
var
  RulesList: IList<IRule>;
  rules,
  rule,
  assignment,
  literal,
  expression,
  expression_label,
  or_term,
  ored,
  sequence,
  negative_lookahead_term,
  lookahead_term,
  term,
  quantified,
  atom,
  regex,
  parenthesized,
  quantifier,
  repetition,
  reference,
  identifier,
  _,
  comment: IRule;

  procedure CreateRules;
  begin
    rules                   := TRule.Create('rules');
    rule                    := TRule.Create('rule');
    assignment              := TRule.Create('assignment');
    literal                 := TRule.Create('literal');
    expression              := TRule.Create('expression');
    expression_label        := TRule.Create('expression_label');
    or_term                 := TRule.Create('or_term');
    ored                    := TRule.Create('ored');
    sequence                := TRule.Create('sequence');
    negative_lookahead_term := TRule.Create('negative_lookahead_term');
    lookahead_term          := TRule.Create('lookahead_term');
    term                    := TRule.Create('term');
    quantified              := TRule.Create('quantified');
    atom                    := TRule.Create('atom');
    regex                   := TRule.Create('regex');
    parenthesized           := TRule.Create('parenthesized');
    quantifier              := TRule.Create('quantifier');
    repetition              := TRule.Create('repetition');
    reference               := TRule.Create('reference');
    identifier              := TRule.Create('identifier');
    _                       := TRule.Create('_');
    comment                 := TRule.Create('comment');
  end;

  procedure SetupRules;
  begin
    //rules = _ rule+
    rules.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(_),
       TRepeatOneOrMoreExpression.Create(TRuleReferenceExpression.Create(rule))
      ]
    );
    //rule = identifier assignment expression
    rule.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(identifier),
       TRuleReferenceExpression.Create(assignment),
       TRuleReferenceExpression.Create(expression)
      ]
    );
    //assignment = "=" _
    assignment.Expression := TSequenceExpression.Create(
      [TLiteralExpression.Create('='),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //literal = /\".*?[^\\]\"/i _
    literal.Expression := TSequenceExpression.Create(
      [TRegexExpression.Create('\".*?[^\\]\"', [TRegExOption.roIgnoreCase]),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //expression = expression_label? (ored | sequence | term)
    expression.Expression := TSequenceExpression.Create(
      [TRepeatOptionalExpression.Create(
        TRuleReferenceExpression.Create(expression_label)),
       TOneOfExpression.Create(
        [TRuleReferenceExpression.Create(ored),
         TRuleReferenceExpression.Create(sequence),
         TRuleReferenceExpression.Create(term)
        ]
       )
      ]
    );
    //expression_label = identifier ":"
    expression_label.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(identifier),
       TLiteralExpression.Create(':')
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
    //sequence = term term+
    sequence.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(term),
       TRepeatOneOrMoreExpression.Create(
         TRuleReferenceExpression.Create(term)
       )
      ]
    );
    //negative_lookahead_term = "!" term _
    negative_lookahead_term.Expression := TSequenceExpression.Create(
      [TLiteralExpression.Create('!'),
       TRuleReferenceExpression.Create(term),
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
    //term = lookahead_term | negative_lookahead_term | quantified | repetition | atom
    term.Expression := TOneOfExpression.Create(
      [TRuleReferenceExpression.Create(lookahead_term),
       TRuleReferenceExpression.Create(negative_lookahead_term),
       TRuleReferenceExpression.Create(quantified),
       TRuleReferenceExpression.Create(repetition),
       TRuleReferenceExpression.Create(atom)
      ]
    );
    //quantified = atom quantifier
    quantified.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(atom),
       TRuleReferenceExpression.Create(quantifier)
      ]
    );
    //atom = reference | literal | regex | parenthesized
    atom.Expression := TOneOfExpression.Create(
      [TRuleReferenceExpression.Create(reference),
       TRuleReferenceExpression.Create(literal),
       TRuleReferenceExpression.Create(regex),
       TRuleReferenceExpression.Create(parenthesized)
      ]
    );
    //regex = /\/.*?[^\\]\// /[imesp]*/i? _
    regex.Expression := TSequenceExpression.Create(
      [TRegexExpression.Create('\/.*?[^\\]\/'),
       TRepeatOptionalExpression.Create(TRegexExpression.Create('[imesp]*', [TRegExOption.roIgnoreCase])),
       TRuleReferenceExpression.Create(_)
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
    //quantifier = /[*+?]/ _
    quantifier.Expression := TSequenceExpression.Create(
      [TRegexExpression.Create('[*+?]'),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //repetition = atom /{[0-9]+(\s*,\s*([0-9]+)?)?}/ _
    repetition.Expression := TSequenceExpression.Create(
      [TRuleReferenceExpression.Create(atom),
       TRegexExpression.Create('{[0-9]+(\s*,\s*([0-9]+)?)?}'),
       TRuleReferenceExpression.Create(_)
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
    //identifier = /[a-z_][a-z0-9_]*/i _
    identifier.Expression := TSequenceExpression.Create(
      [TRegexExpression.Create('[a-z_][a-z0-9_]*', [TRegExOption.roIgnoreCase]),
       TRuleReferenceExpression.Create(_)
      ]
    );
    //_ = /\s+/? | comment
    _.Expression := TOneOfExpression.Create(
      [TRepeatOptionalExpression.Create(TRegexExpression.Create('\s+')),
       TRuleReferenceExpression.Create(comment)
      ]
    );
    //comment = /#.*?(?:\r\n|$)/
    comment.Expression := TRegexExpression.Create('#.*?(?:' + sLineBreak + '|$)');
  end;

  procedure CreateRulesArray;
  begin
    RulesList.Add(rules);
    RulesList.Add(rule);
    RulesList.Add(assignment);
    RulesList.Add(literal);
    RulesList.Add(expression);
    RulesList.Add(expression_label);
    RulesList.Add(or_term);
    RulesList.Add(ored);
    RulesList.Add(sequence);
    RulesList.Add(negative_lookahead_term);
    RulesList.Add(lookahead_term);
    RulesList.Add(term);
    RulesList.Add(quantified);
    RulesList.Add(atom);
    RulesList.Add(regex);
    RulesList.Add(parenthesized);
    RulesList.Add(quantifier);
    RulesList.Add(repetition);
    RulesList.Add(reference);
    RulesList.Add(identifier);
    RulesList.Add(_);
    RulesList.Add(comment);
  end;

begin
  RulesList := Collections.CreateList<IRule>;
  CreateRules;
  SetupRules;
  CreateRulesArray;
  inherited Create(RulesList);
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

//  function GetPrintedTreeText(const aTree: INode): string;
//  var
//    PrinterNodeVisitor: INodeVisitor;
//    Value: TValue;
//  begin
//    PrinterNodeVisitor := TPrinterNodeVisitor.Create;
//    Value := (aTree as IVisitableNode).Accept(PrinterNodeVisitor);
//    Result := Value.AsString;
//  end;

begin
//  ShowMessage(GetPrintedTreeText(Parse(aGrammarText)));
  Result := ParseAndVisit(aGrammarText).AsType<IList<IRule>>;
end;

function TBootstrappingGrammar.Visit_assignment(const aNode: INode): TValue;
begin
end;

function TBootstrappingGrammar.Visit_atom(const aNode: INode): TValue;
begin
  Result := aNode.Children[0].Value;
end;

function TBootstrappingGrammar.Visit_comment(const aNode: INode): TValue;
begin
end;

function TBootstrappingGrammar.Visit_expression(const aNode: INode): TValue;
begin
  Result := aNode.Children[1].Children[0].Value;
  if not aNode.Children[0].Value.AsString.IsEmpty then
    Result.AsType<IExpression>.Name := aNode.Children[0].Value.AsString;
end;

function TBootstrappingGrammar.Visit_expression_label(
  const aNode: INode): TValue;
begin
  Result := aNode.Children[0].Text;
end;

function TBootstrappingGrammar.Visit_identifier(const aNode: INode): TValue;
begin
  Result := aNode.Children[0].Text;
end;

function TBootstrappingGrammar.Visit_literal(const aNode: INode): TValue;

  function ExtractLiteral(const aWrappedLiteral: string): string;
  begin
    Result := TRegEx.Match(aWrappedLiteral, '^"(?<literal>.*?)"$').
      Groups['literal'].Value;
  end;

begin
  Result := TValue.From<IExpression>(TLiteralExpression.Create(
    ExtractLiteral(aNode.Children[0].Text)));
end;

function TBootstrappingGrammar.Visit_lookahead_term(const aNode: INode): TValue;
begin
  Result := TLookaheadExpression.Create(aNode.Children[1].Value.AsType<IExpression>);
end;

function TBootstrappingGrammar.Visit_negative_lookahead_term(const aNode: INode): TValue;
begin
  Result := TNegativeLookaheadExpression.Create(aNode.Children[1].Value.AsType<IExpression>);
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
  AddExpressionToArray(aNode.Children[0].Value.AsType<IExpression>);
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
var
  Quantifier: string;
  Atom: IExpression;
begin
  Quantifier := aNode.Children[1].Children[0].Text;
  Atom := aNode.Children[0].Value.AsType<IExpression>;
  if Quantifier = '?' then
    Result := TValue.From<IExpression>(TRepeatOptionalExpression.Create(Atom))
  else if Quantifier = '*' then
    Result := TValue.From<IExpression>(TRepeatZeroOrMoreExpression.Create(Atom))
  else if Quantifier = '+' then
    Result := TValue.From<IExpression>(TRepeatOneOrMoreExpression.Create(Atom));
end;

function TBootstrappingGrammar.Visit_quantifier(const aNode: INode): TValue;
begin
  Result := aNode.Children[0].Text;
end;

function TBootstrappingGrammar.Visit_reference(const aNode: INode): TValue;
begin
  Result := TRuleReferenceExpression.Create(GetRuleByName(aNode.Children[0].Value.AsString));
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
  Result := TRegexExpression.Create(ExtractRegexPattern(aNode.Children[0].Text),
     RegexOptions);
end;

function TBootstrappingGrammar.Visit_repetition(const aNode: INode): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_rule(const aNode: INode): TValue;
var
  Rule: IRule;
begin
  Rule := GetRuleByName(aNode.Children[0].Value.AsString);
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
  AddExpressionToArray(aNode.Children[0].Value.AsType<IExpression>);
  for ExpressionNode in aNode.Children[1].Children do
    AddExpressionToArray(ExpressionNode.Value.AsType<IExpression>);
  Result := TValue.From<IExpression>(TSequenceExpression.Create(Expressions));
  SetLength(Expressions, 0);
end;

function TBootstrappingGrammar.Visit_term(const aNode: INode): TValue;
begin
  Result := aNode.Children[0].Value;
end;

function TBootstrappingGrammar.Visit__(const aNode: INode): TValue;
begin
end;

end.