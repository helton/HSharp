unit HSharp.PEG.Grammar.Bootstrapping;

interface

uses
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Expression,
  HSharp.PEG.Expression.Interfaces,
  HSharp.PEG.Rule,
  HSharp.PEG.Rule.Interfaces;

type
  TBootstrappingGrammar = class
  strict private
    FRawRules: IList<string>;
    FRules: IList<IRule>;
  public
    constructor Create(const aRawRules: IList<string>);
    procedure BuildRules;
  end;

implementation

uses
  System.RegularExpressions;

{ TBootstrappingGrammar }

procedure TBootstrappingGrammar.BuildRules;
var
  { rules }
  Rules, Rule, Expression, Sequence, Preffix, Suffix, Primary,
  ParenthesizedExpression, Assignment, RuleIdentifier, Regex,
  Literal, RuleReference, LookaheadAssertion, Quantifier, Comment, Spaces: IRule;
begin
  { create rules }
  Rules                   := TRule.Create('rules');
  Rule                    := TRule.Create('rule');
  Expression              := TRule.Create('expression');
  Sequence                := TRule.Create('sequence');
  Preffix                 := TRule.Create('preffix');
  Suffix                  := TRule.Create('suffix');
  Primary                 := TRule.Create('primary');
  ParenthesizedExpression := TRule.Create('parenthesized_expression');
  Assignment              := TRule.Create('assignment');
  RuleIdentifier          := TRule.Create('rule_identifier');
  Regex                   := TRule.Create('regex');
  Literal                 := TRule.Create('literal');
  RuleReference           := TRule.Create('rule_reference');
  LookaheadAssertion      := TRule.Create('lookahead_assertion');
  Quantifier              := TRule.Create('quantifier');
  Comment                 := TRule.Create('comment');
  Spaces                  := TRule.Create('spaces');

  { setup rules }

  // <rules> = rule+
  Rules.Expression := TRepeatOneOrMoreExpression.Create(
    TRuleReferenceExpression.Create(Rule));
  // <rule> = rule_identifier assignment expression
  Rule.Expression := TSequenceExpression.Create(
    [TRuleReferenceExpression.Create(RuleIdentifier),
     TRuleReferenceExpression.Create(Assignment),
     TRuleReferenceExpression.Create(Expression)
    ]
  );
  // <expression> = sequence ("|" sequence)*
  Expression.Expression := TSequenceExpression.Create(
    [TRuleReferenceExpression.Create(Sequence),
     TRepeatZeroOrMoreExpression.Create(
       TSequenceExpression.Create(
         [TLiteralExpression.Create('|'),
          TRuleReferenceExpression.Create(Sequence)
         ]
       )
     )
    ]
  );
  // <sequence> = prefix*
  Sequence.Expression := TRepeatZeroOrMoreExpression.Create(
    TRuleReferenceExpression.Create(Preffix));
  // <prefix> = lookahead_assertion? suffix
  Preffix.Expression := TSequenceExpression.Create(
    [TRepeatOptionalExpression.Create(TRuleReferenceExpression.Create(
      LookaheadAssertion)),
     TRuleReferenceExpression.Create(Suffix)
    ]
  );
  // <suffix> = primary quantifier?
  Suffix.Expression := TSequenceExpression.Create(
    [TRuleReferenceExpression.Create(Primary),
     TRepeatOptionalExpression.Create(TRuleReferenceExpression.Create(
       Quantifier))
    ]
  );
  // <primary> = rule_reference
  //           |  parenthesized_expression
  //           |  literal
  //           |  regex
  Primary.Expression := TOneOfExpression.Create(
    [TRuleReferenceExpression.Create(RuleReference),
     TRuleReferenceExpression.Create(ParenthesizedExpression),
     TRuleReferenceExpression.Create(Literal),
     TRuleReferenceExpression.Create(Regex)
    ]
  );
  // <parenthesized_expression> = "(" expression ")"
  ParenthesizedExpression.Expression := TSequenceExpression.Create(
    [TLiteralExpression.Create('('),
     TRuleReferenceExpression.Create(Expression),
     TLiteralExpression.Create(')')
    ]
  );

  { # Implicit tokens }
  // <assignment> = "="
  Assignment.Expression := TLiteralExpression.Create('=');
  // <rule_identifier> = /<[a-z_][a-z0-9_]*>/i
  RuleIdentifier.Expression := TRegexExpression.Create('[a-z_][a-z0-9_]*', [
    TRegExOption.roIgnoreCase]);
  // <regex> = ///.*?[^\\]//[imesp]*/is
  Regex.Expression := TRegexExpression.Create('//.*?[^\\]//[imesp]*', [
    TRegExOption.roIgnoreCase, TRegExOption.roSingleLine]); {TODO -oHelton -cCheck : Check if "s" regex flag is a roSingleLine option}
  // <literal> = /\".*?[^\\]\"/is
  Literal.Expression := TRegexExpression.Create('\".*?[^\\]\"', [
    TRegExOption.roIgnoreCase, TRegExOption.roSingleLine]);
  // <rule_reference> = /[a-z_][a-z0-9_]*/i
  RuleReference.Expression := TRegexExpression.Create('[a-z_][a-z0-9_]*', [
    TRegExOption.roIgnoreCase]);
  // <lookahead_assertion> = /[&!]/
  LookaheadAssertion.Expression := TRegexExpression.Create('[&!]');
  // <quantifier> = /[?*+]|{[0-9]+(\s*,\s*([0-9]+)?)?}/
  Quantifier.Expression := TRegexExpression.Create('[?*+]|{[0-9]+(\s*,\s*([0-9]+)?)?}');
  // <comment>  = /#[^\r\n]*/
  Comment.Expression := TRegexExpression.Create('#[^\r\n]*');
  // <spaces> = /(?:\t|\s|\n)+/
  Spaces.Expression := TRegexExpression.Create('(?:\t|\s|\n)+');
end;

constructor TBootstrappingGrammar.Create(const aRawRules: IList<string>);
begin
  inherited Create;
  FRawRules := aRawRules;
  FRules := Collections.CreateList<IRule>;
  BuildRules;
end;

end.