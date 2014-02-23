unit HSharp.PEG.Bootstrap;

interface

uses
  HSharp.PEG;

var
  PEGGrammar: IGrammar;

implementation

{
  # Hierarchical syntax
  Grammar    <- Spacing Definition+ EndOfFile
  Definition <- Identifier LEFTARROW Expression

  Expression <- Sequence (SLASH Sequence)*
  Sequence   <- Prefix*
  Prefix     <- (AND / NOT)? Suffix
  Suffix     <- Primary (QUESTION / STAR / PLUS)?
  Primary    <- Identifier !LEFTARROW
              / OPEN Expression CLOSE
              / Literal / Class / DOT

  # Lexical syntax
  Identifier <- IdentStart IdentCont* Spacing
  IdentStart <- [a-zA-Z_]
  IdentCont  <- IdentStart / [0-9]

  Literal    <- [’] (![’] Char)* [’] Spacing
              / ["] (!["] Char)* ["] Spacing
  Class      <- ’[’ (!’]’ Range)* ’]’ Spacing
  Range      <- Char ’-’ Char / Char
  Char       <- ’\\’ [nrt’"\[\]\\]
              / ’\\’ [0-2][0-7][0-7]
              / ’\\’ [0-7][0-7]?
              / !’\\’ .

  LEFTARROW  <- ’<-’ Spacing
  SLASH      <- ’/’ Spacing
  AND        <- ’&’ Spacing
  NOT        <- ’!’ Spacing
  QUESTION   <- ’?’ Spacing
  STAR       <- ’*’ Spacing
  PLUS       <- ’+’ Spacing
  OPEN       <- ’(’ Spacing
  CLOSE      <- ’)’ Spacing
  DOT        <- ’.’ Spacing

  Spacing    <- (Space / Comment)*
  Comment    <- ’#’ (!EndOfLine .)* EndOfLine
  Space      <- ’ ’ / ’\t’ / EndOfLine
  EndOfLine  <- ’\r\n’ / ’\n’ / ’\r’
  EndOfFile  <- !.
}

var
  { # Hierarchical syntax }
  GrammarRule: IRule;
  DefinitionRule: IRule;

  ExpressionRule: IRule;
  SequenceRule: IRule;
  PrefixRule: IRule;
  SuffixRule: IRule;
  PrimaryRule: IRule;

  { # Lexical syntax }
  IdentifierRule: IRule;
  IdentStartRule: IRule;
  IdentContRule: IRule;
  LiteralRule: IRule;
  ClassRule: IRule;
  RangeRule: IRule;
  CharRule: IRule;

  LEFTARROW_Rule: IRule;
  SLASH_Rule: IRule;
  AND_Rule: IRule;
  NOT_Rule: IRule;
  QUESTION_Rule: IRule;
  STAR_Rule: IRule;
  PLUS_Rule: IRule;
  OPEN_Rule: IRule;
  CLOSE_Rule: IRule;
  DOT_Rule: IRule;

  SpacingRule: IRule;
  CommentRule: IRule;
  SpaceRule: IRule;
  EndOfLineRule: IRule;
  EndOfFileRule: IRule;

initialization
  {$REGION 'Grammar rules'}

  { Grammar    <- Spacing Definition+ EndOfFile }
  GrammarRule := SpacingRule.AsRule and
                 RuleFactory.OneOrMoreRule(DefinitionRule).AsRule and
                 EndOfFileRule.AsRule;

  { Definition <- Identifier LEFTARROW Expression }
  DefinitionRule := IdentifierRule.AsRule and
                    LEFTARROW_Rule.AsRule and
                    ExpressionRule.AsRule;

  { Expression <- Sequence (SLASH Sequence)* }
  ExpressionRule := SequenceRule.AsRule and
                    RuleFactory.ZeroOrMoreRule(SLASH_Rule.AsRule and SequenceRule.AsRule);

  { Sequence   <- Prefix* }
  SequenceRule := RuleFactory.ZeroOrMoreRule(PrefixRule).AsRule;

  { Prefix     <- (AND / NOT)? Suffix }
  PrefixRule := RuleFactory.OptionalRule(AND_Rule.AsRule or NOT_Rule.AsRule) and
                SuffixRule.AsRule;

  { Suffix     <- Primary (QUESTION / STAR / PLUS)? }
  SuffixRule := PrimaryRule.AsRule and
                RuleFactory.OptionalRule(QUESTION_Rule.AsRule or STAR_RULE.AsRule or PLUS_Rule.AsRule);

  { Primary    <- Identifier !LEFTARROW
               / OPEN Expression CLOSE
               / Literal / Class / DOT }
  PrimaryRule := (IdentifierRule.AsRule and (not LEFTARROW_Rule.AsRule)) or
                 (OPEN_Rule.AsRule and ExpressionRule.AsRule and CLOSE_Rule.AsRule) or
                 LiteralRule.AsRule or ClassRule.AsRule or DOT_Rule.AsRule;

  { Identifier <- IdentStart IdentCont* Spacing }
  IdentifierRule := IdentStartRule.AsRule and
                    RuleFactory.ZeroOrMoreRule(IdentContRule) and
                    SpacingRule.AsRule;

  { IdentStart <- [a-zA-Z_] }
  IdentStartRule := RuleFactory.RegexRule('[a-zA-Z_]');

  { IdentCont  <- IdentStart / [0-9] }
  IdentContRule := IdentStartRule.AsRule or RuleFactory.RegexRule('[0-9]').AsRule;

  {
    SKIPPED FOR WHILE...
  Literal    <- [’] (![’] Char)* [’] Spacing
              / ["] (!["] Char)* ["] Spacing
  Class      <- ’[’ (!’]’ Range)* ’]’ Spacing
  Range      <- Char ’-’ Char / Char
  Char       <- ’\\’ [nrt’"\[\]\\]
              / ’\\’ [0-2][0-7][0-7]
              / ’\\’ [0-7][0-7]?
              / !’\\’ .
  }

  { Spacing    <- (Space / Comment)* }
  SpacingRule := RuleFactory.ZeroOrMoreRule(SpaceRule.AsRule or CommentRule.AsRule);

  { Comment    <- ’#’ (!EndOfLine .)* EndOfLine }
  CommentRule := RuleFactory.LiteralRule('#') and
                 RuleFactory.ZeroOrMoreRule(not EndOfLineRule.AsRule and RuleFactory.RegexRule('.').AsRule).AsRule and
                 EndOfLineRule.AsRule;

  { Space      <- ’ ’ / ’\t’ / EndOfLine }
  SpaceRule := RuleFactory.RegexRule('[ \t]').AsRule or EndOfLineRule.AsRule;

  { EndOfLine  <- ’\r\n’ / ’\n’ / ’\r’ }
  EndOfLineRule := RuleFactory.RegexRule('\r\n').AsRule or
                   RuleFactory.RegexRule('\n').AsRule or
                   RuleFactory.RegexRule('\r').AsRule;

  { EndOfFile  <- !. }
  EndOfFileRule := RuleFactory.LiteralRule('!.');

  {$ENDREGION}

  PEGGrammar := TGrammar.Create(GrammarRule);

end.
