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
  HSharp.PEG.Grammar,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Rule,
  HSharp.PEG.Rule.Interfaces;

type
  IBootstrappingGrammar = interface(IGrammar)
    ['{D83E083A-9452-4C4F-8DFB-379CF81BFA1D}']
    function GetRules(const aGrammarText: string): IList<IRule>;
  end;

  TBootstrappingGrammar = class(TGrammar, IBootstrappingGrammar)
  public
{??}function Visit_rules(const aNode: INode; const aArgs: IArray<TValue>): TValue;
{OK}function Visit_rule(const aNode: INode; const aArgs: IArray<TValue>): TValue;
{OK}function Visit_assignment(const aNode: INode; const aArgs: IArray<TValue>): TValue;
{OK}function Visit_literal(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_expression(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_or_term(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_ored(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_sequence(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_negative_lookahead_term(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_lookahead_term(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_term(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_quantified(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_atom(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_regex(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_parenthesized(const aNode: INode; const aArgs: IArray<TValue>): TValue;
{OK}function Visit_quantifier(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_repetition(const aNode: INode; const aArgs: IArray<TValue>): TValue;
    function Visit_reference(const aNode: INode; const aArgs: IArray<TValue>): TValue;
{..}function Visit_identifier(const aNode: INode; const aArgs: IArray<TValue>): TValue;
{OK}function Visit__(const aNode: INode; const aArgs: IArray<TValue>): TValue;
{OK}function Visit_comment(const aNode: INode; const aArgs: IArray<TValue>): TValue;
  public
    constructor Create; overload;
    { IBootstrappingGrammar }
    function GetRules(const aGrammarText: string): IList<IRule>;
  end;

implementation

uses
  Vcl.Dialogs, {TODO -oHelton -cRemove : Remove!}
  System.RegularExpressions;

{ TBootstrappingGrammar }

constructor TBootstrappingGrammar.Create;
var
  RulesArray: array of IRule;
  rules,
  rule,
  assignment,
  literal,
  expression,
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
    //expression = ored | sequence | term
    expression.Expression := TOneOfExpression.Create(
      [TRuleReferenceExpression.Create(ored),
       TRuleReferenceExpression.Create(sequence),
       TRuleReferenceExpression.Create(term)
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
    //repetition = /{[0-9]+(\s*,\s*([0-9]+)?)?}/ _
    repetition.Expression := TSequenceExpression.Create(
      [TRegexExpression.Create('{[0-9]+(\s*,\s*([0-9]+)?)?}'),
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

    procedure AddRuleToArray(const aRule: IRule);
    begin
      SetLength(RulesArray, Length(RulesArray) + 1);
      RulesArray[High(RulesArray)] := aRule;
    end;

  begin
    AddRuleToArray(rules);
    AddRuleToArray(rule);
    AddRuleToArray(assignment);
    AddRuleToArray(literal);
    AddRuleToArray(expression);
    AddRuleToArray(or_term);
    AddRuleToArray(ored);
    AddRuleToArray(sequence);
    AddRuleToArray(negative_lookahead_term);
    AddRuleToArray(lookahead_term);
    AddRuleToArray(term);
    AddRuleToArray(quantified);
    AddRuleToArray(atom);
    AddRuleToArray(regex);
    AddRuleToArray(parenthesized);
    AddRuleToArray(quantifier);
    AddRuleToArray(repetition);
    AddRuleToArray(reference);
    AddRuleToArray(identifier);
    AddRuleToArray(_);
    AddRuleToArray(comment);
  end;

begin
  CreateRules;
  SetupRules;
  CreateRulesArray;
  inherited Create(RulesArray);
end;

function TBootstrappingGrammar.GetRules(const aGrammarText: string): IList<IRule>;
begin
  Result := ParseAndVisit(aGrammarText).AsType<IList<IRule>>;
end;

function TBootstrappingGrammar.Visit_assignment(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
end;

function TBootstrappingGrammar.Visit_atom(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_comment(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
end;

function TBootstrappingGrammar.Visit_expression(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_identifier(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := aNode.Children[0].Text;
end;

function TBootstrappingGrammar.Visit_literal(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := aNode.Children[0].Text;
end;

function TBootstrappingGrammar.Visit_lookahead_term(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_negative_lookahead_term(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_ored(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_or_term(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_parenthesized(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_quantified(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_quantifier(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := aNode.Children[0].Text;
end;

function TBootstrappingGrammar.Visit_reference(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_regex(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_repetition(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_rule(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
var
  Rule: IRule;
begin
  Rule := TRule.Create(aArgs[0].AsString);
//  Rule.Expression := aArgs[2].AsType<IExpression>;
  Result := TValue.From<IRule>(Rule);
end;

function TBootstrappingGrammar.Visit_rules(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
var
  FRules: IList<IRule>;
//  Node: INode;
begin
  FRules := Collections.CreateList<IRule>;
//  for Node in aNode.Children[1].Children do
//    FRules.Add(Node.Children[1].Text).AsType<IRule>;
  Result := TValue.From<IList<IRule>>(FRules);
end;

function TBootstrappingGrammar.Visit_sequence(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit_term(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
  Result := nil;
end;

function TBootstrappingGrammar.Visit__(const aNode: INode;
  const aArgs: IArray<TValue>): TValue;
begin
end;

end.