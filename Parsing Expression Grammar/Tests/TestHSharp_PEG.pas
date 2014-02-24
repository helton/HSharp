unit TestHSharp_PEG;

interface

uses
  TestFramework,
  HSharp.PEG.Context,
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Exceptions,
  HSharp.PEG.Expression,
  HSharp.PEG.Expression.Interfaces,
  HSharp.PEG.Grammar,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Rule,
  HSharp.PEG.Rule.Interfaces;

type
  TestContext = class(TTestCase)
  strict private
    FContext: IContext;
  protected
    procedure SetUp; override;
  published
    procedure OnCreate_IndexShouldBeZero;
    procedure OnCallIncIndex_ShouldIncrementCurrentIndex;
    procedure OnSaveStateAndRestore_LastCharIndexShouldBeRestored;
    procedure OnSetIndex_GetTextWillReturnTheTextFromCurrentIndex;
  end;

  TestExpression = class(TTestCase)
  published
    procedure WhenCallCanMatch_ShouldCheckIfATextCanMatchButNotConsumesAnyText;
    procedure WhenCallMatch_ShouldCheckRaiseAnExceptionIfTextDoesntMatch;
    procedure WhenCallAsStringOnRegexExpression_ShouldFormatCorrectly;
    procedure WhenMatch_TheMatchTextShouldBeAvailable;
    procedure AfterMatch_IndexShouldPointToTheNextTextThatWillBeMatched;
    procedure SequenceExpression_ShouldBeMatchAllExpressions;
    procedure OneOfExpression_ShouldBeMatchTheFirstValidExpression;
    procedure LookaheadExpression_ShouldntConsumeText;
    procedure NegativeLookaheadExpression_ShouldntConsumeTextAndMatchIfExpressionDoesntMatch;
    procedure RepeatOptionalExpression_ShouldMatchCorrectly;
    procedure RepeatZeroOrMoreExpression_ShouldMatchCorrectly;
    procedure RepeatOneOrMoreExpression_ShouldMatchCorrectly;
    procedure RepeatRangeExpression_ShouldMatchCorrectly;
    procedure RepeatExactlyExpression_ShouldMatchCorrectly;
    procedure RepeatAtLeastExpression_ShouldMatchCorrectly;
    procedure RepeatUpToExpression_ShouldMatchCorrectly;
  end;

  TestRule = class(TTestCase)
  published
    procedure WhenCallAsString_ShouldFormatCorrectly;
  end;

  TestGrammar = class(TTestCase)
  published
    procedure Test;
  end;

implementation

uses
  HSharp.Core.ArrayString,
  System.RegularExpressions,
  System.SysUtils;

{ TestPEG }

procedure TestExpression.WhenCallCanMatch_ShouldCheckIfATextCanMatchButNotConsumesAnyText;
var
  Expr: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('This is my test text');
  Expr := TLiteralExpression.Create('will not match');
  CheckFalse(Expr.IsMatch(Context), 'This shouldn''t match');
  CheckEquals(0, Context.Index, 'Context.Index should be keeped on 0');
end;

procedure TestExpression.WhenCallMatch_ShouldCheckRaiseAnExceptionIfTextDoesntMatch;
var
  Expr: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('This is my test text');
  Expr := TLiteralExpression.Create('will not match');
  StartExpectingException(EMatchError);
  Expr.Match(Context);
  StopExpectingException('Should raise an exception when a text doesn''t match');
end;

procedure TestExpression.WhenMatch_TheMatchTextShouldBeAvailable;
var
  Expr: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('1234567890 another text');
  Expr := TRegexExpression.Create('[0-9]+');
  Expr.Match(Context);
  CheckEquals('1234567890', Expr.Text, 'After match the matched text should be available');
end;

procedure TestExpression.RepeatZeroOrMoreExpression_ShouldMatchCorrectly;
var
  ZeroOrMore: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('0123456789 first_id second_id this_id');
  ZeroOrMore := TRepeatZeroOrMoreExpression.Create(TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]));
  CheckTrue(ZeroOrMore.IsMatch(Context)); //won't match, but it's ZERO or more and will return true
  ZeroOrMore.Match(Context);
  CheckEquals('0123456789 first_id second_id this_id', Context.Text,
              'ZeroOrMore ever matches, but when not matches don''t consumes the ' +
              'text');

  Context := TContext.Create('first_id second_id this_id 0123456789');
  ZeroOrMore := TRepeatZeroOrMoreExpression.Create(TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]));
  CheckTrue(ZeroOrMore.IsMatch(Context)); //will match, and will return true
  ZeroOrMore.Match(Context);
  CheckEquals('0123456789', Context.Text,
              'ZeroOrMore ever matches, but when matches will consumes the matched text');
end;

procedure TestExpression.AfterMatch_IndexShouldPointToTheNextTextThatWillBeMatched;
var
  Expr: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('1234567890 another text');
  Expr := TRegexExpression.Create('1234567890');
  Expr.Match(Context);
  CheckEquals(10, Context.Index, 'After match Context.Index should point to next text that will be matched');
end;

procedure TestExpression.LookaheadExpression_ShouldntConsumeText;
var
  Lookahead: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('0123456789 original text');
  Lookahead := TLookahedExpression.Create(TRegexExpression.Create('[0-9]+'));
  CheckTrue(Lookahead.IsMatch(Context));
  Lookahead.Match(Context);
  CheckEquals('0123456789 original text', Context.Text,
              'Lookahead should not consumes the text');
end;

procedure TestExpression.NegativeLookaheadExpression_ShouldntConsumeTextAndMatchIfExpressionDoesntMatch;
var
  NotExpr: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('original text 0123456789');
  NotExpr := TNegativeLookaheadExpression.Create(TRegexExpression.Create('[0-9]+'));
  CheckTrue(NotExpr.IsMatch(Context));
  NotExpr.Match(Context);
  CheckEquals('original text 0123456789', Context.Text,
              'NotExpression should not consumes the text');
end;

procedure TestExpression.OneOfExpression_ShouldBeMatchTheFirstValidExpression;
var
  OneOf: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('0123456789 literal_text anyIdentifier');
  OneOf := TOneOfExpression.Create(
    [
     TRegexExpression.Create('[a-z]+', [TRegExOption.roIgnoreCase]),
     TLiteralExpression.Create(' '),
     TLiteralExpression.Create('literal_text_not_match'),
     TRegexExpression.Create('[0-9]+')
    ]
  );
  CheckTrue(OneOf.IsMatch(Context), 'Sequence should be matched');

  OneOf.Match(Context);
  CheckEquals('0123456789', OneOf.Text, 'Number should be matched');
  CheckEquals(' literal_text anyIdentifier', Context.Text, 'Remaining text only should not include the matched text');
end;

procedure TestExpression.RepeatAtLeastExpression_ShouldMatchCorrectly;
var
  RepeatAtLeast: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('first_id second_id this_id 0123456789');
  RepeatAtLeast := TRepeatAtLeastExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 5);
  CheckFalse(RepeatAtLeast.IsMatch(Context));

  Context := TContext.Create('first_id second_id this_id 0123456789');
  RepeatAtLeast := TRepeatAtLeastExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 2);
  CheckTrue(RepeatAtLeast.IsMatch(Context));
  RepeatAtLeast.Match(Context);
  CheckEquals('0123456789', Context.Text, 'Remaining text should be only numbers');
end;

procedure TestExpression.RepeatExactlyExpression_ShouldMatchCorrectly;
var
  RepeatExactly: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('first_id second_id this_id 0123456789');
  RepeatExactly := TRepeatExactlyExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 5);
  CheckFalse(RepeatExactly.IsMatch(Context));

  Context := TContext.Create('first_id second_id this_id 0123456789');
  RepeatExactly := TRepeatExactlyExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 3);
  CheckTrue(RepeatExactly.IsMatch(Context));
  RepeatExactly.Match(Context);
  CheckEquals('0123456789', Context.Text, 'Remaining text should be only numbers');
end;

procedure TestExpression.RepeatOneOrMoreExpression_ShouldMatchCorrectly;
var
  RepeatOneOrMore: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('first_id second_id this_id 0123456789');
  RepeatOneOrMore := TRepeatOneOrMoreExpression.Create(TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]));
  CheckTrue(RepeatOneOrMore.IsMatch(Context)); //will match, and will return true
  RepeatOneOrMore.Match(Context);
  CheckEquals('0123456789', Context.Text,
              'OneOrMore only will match if unless 1 expression will match. When matches all matched text will be consumed');

  Context := TContext.Create('0123456789 first_id second_id this_id');
  RepeatOneOrMore := TRepeatOneOrMoreExpression.Create(TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]));
  CheckFalse(RepeatOneOrMore.IsMatch(Context)); //won't match, but it's ZERO or more and will return true
  StartExpectingException(EMatchError);
  RepeatOneOrMore.Match(Context);
  StopExpectingException('Should raise an exception when a text doesn''t match');
  { code after ExpectingException will never be executed! }
end;

procedure TestExpression.RepeatRangeExpression_ShouldMatchCorrectly;
var
  RepeatRange: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('first_id second_id this_id 0123456789');
  RepeatRange := TRepeatRangeExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 5, 9);
  CheckFalse(RepeatRange.IsMatch(Context));

  Context := TContext.Create('first_id second_id this_id 0123456789');
  RepeatRange := TRepeatRangeExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 2, 3);
  CheckTrue(RepeatRange.IsMatch(Context));
  RepeatRange.Match(Context);
  CheckEquals('0123456789', Context.Text, 'Remaining text should be only numbers');
end;

procedure TestExpression.RepeatUpToExpression_ShouldMatchCorrectly;
var
  RepeatUpTo: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('first_id second_id this_id 0123456789');
  RepeatUpTo := TRepeatUpToExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 2);
  CheckTrue(RepeatUpTo.IsMatch(Context));
  RepeatUpTo.Match(Context);
  CheckEquals('this_id 0123456789', Context.Text, 'Remaining text should be only ' +
    'numbers');

  Context := TContext.Create('first_id second_id this_id 0123456789');
  RepeatUpTo := TRepeatUpToExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 5);
  CheckTrue(RepeatUpTo.IsMatch(Context));
  RepeatUpTo.Match(Context);
  CheckEquals('0123456789', Context.Text, 'Remaining text should be only ' +
    'numbers');
end;

procedure TestExpression.RepeatOptionalExpression_ShouldMatchCorrectly;
var
  RepeatOpt: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('original text 0123456789');
  RepeatOpt := TRepeatOptionalExpression.Create(TRegexExpression.Create('[0-9]+'));
  CheckTrue(RepeatOpt.IsMatch(Context)); //won't match, but it's optional and will return true
  RepeatOpt.Match(Context);
  CheckEquals('original text 0123456789', Context.Text,
              'Optional ever matches, but when not matches don''t consumes the ' +
              'text');

  Context := TContext.Create('0123456789 original text');
  RepeatOpt := TRepeatOptionalExpression.Create(TRegexExpression.Create('[0-9]+'));
  CheckTrue(RepeatOpt.IsMatch(Context)); //will match, and will return true
  RepeatOpt.Match(Context);
  CheckEquals(' original text', Context.Text,
              'Optional ever matches, but when matches will consumes the matched text');

end;

procedure TestExpression.SequenceExpression_ShouldBeMatchAllExpressions;
var
  Seq: IExpression;
  Context: IContext;
begin
  Context := TContext.Create('literal_text 0123456789 anyIdentifier');
  Seq := TSequenceExpression.Create(
    [TLiteralExpression.Create('literal_text'),
     TLiteralExpression.Create(' '),
     TRegexExpression.Create('[0-9]+'),
     TLiteralExpression.Create(' '),
     TRegexExpression.Create('[a-z]+', [TRegExOption.roIgnoreCase])
    ]
  );
  CheckTrue(Seq.IsMatch(Context), 'Sequence should be matched');

  //Context was not changed because we called "CanMatch", that not consumes the text
  Seq.Match(Context); //consumes all text
  CheckEquals('', Context.Text, 'All text should be matched');
end;

procedure TestExpression.WhenCallAsStringOnRegexExpression_ShouldFormatCorrectly;
var
  Expr: IExpression;
begin
  Expr := TRegexExpression.Create('[0-9]+', [TRegExOption.roIgnoreCase, TRegExOption.roSingleLine]);
  CheckEquals('~"[0-9]+"is', Expr.AsString);
end;

{ TestContext }

procedure TestContext.OnCallIncIndex_ShouldIncrementCurrentIndex;
begin
  FContext.IncIndex(15);
  CheckEquals(15, FContext.Index, 'IncIndex wasn''t incremented the index correctly');
end;

procedure TestContext.OnCreate_IndexShouldBeZero;
begin
  CheckEquals(0, FContext.Index, 'Index should be zero on create');
end;

procedure TestContext.OnSaveStateAndRestore_LastCharIndexShouldBeRestored;
begin
  { index = 0 }
  FContext.IncIndex(10); { index = 10 }
  FContext.SaveState;
  FContext.IncIndex(5); { index = 15 }
  FContext.RestoreState;
  CheckEquals(10, FContext.Index, 'Context state wasn''t restored');
end;

procedure TestContext.OnSetIndex_GetTextWillReturnTheTextFromCurrentIndex;
begin
  FContext.IncIndex(5);
  CheckEquals('is some test text', FContext.Text, 'Text wasn''t copied correctly from current index');
end;

procedure TestContext.SetUp;
begin
  inherited;
  FContext := TContext.Create('This is some test text');
end;

{ TestRule }

procedure TestRule.WhenCallAsString_ShouldFormatCorrectly;
var
  InternalRule, Rule: IRule;
begin
  InternalRule := TRule.Create('internal_rule', TLiteralExpression.Create('rule_text'));
  Rule := TRule.Create('OneOfRule');
  Rule.Expression := TOneOfExpression.Create(
    [TLiteralExpression.Create('literal_text'),
     TLiteralExpression.Create(' '),
     TRegexExpression.Create('[0-9]+', [TRegExOption.roIgnorePatternSpace]),
     TLiteralExpression.Create(' '),
     TRepeatZeroOrMoreExpression.Create(TLiteralExpression.Create('text that will be repeated')),
     TRepeatOneOrMoreExpression.Create(TLiteralExpression.Create('text that will be repeated')),
     TRepeatOptionalExpression.Create(TLiteralExpression.Create('text that will be repeated')),
     TRepeatAtLeastExpression.Create(TLiteralExpression.Create('text that will be repeated'), 2),
     TRepeatRangeExpression.Create(TLiteralExpression.Create('text that will be repeated'), 3, 8),
     TRepeatExactlyExpression.Create(TLiteralExpression.Create('text that will be repeated'), 7),
     TRepeatUpToExpression.Create(TLiteralExpression.Create('text that will be repeated'), 4),
     TLookahedExpression.Create(TLiteralExpression.Create('lookahead')),
     TRegexExpression.Create('[a-z]+', [TRegExOption.roIgnoreCase]),
     TNegativeLookaheadExpression.Create(TLiteralExpression.Create('another_literal_text')),
     TRuleReferenceExpression.Create(InternalRule),
     TRegexExpression.Create('[0-5]+', [TRegExOption.roExplicitCapture]),
     TSequenceExpression.Create( //fix error...
       [TLiteralExpression.Create('literal_text'),
        TRegexExpression.Create('[0-9]+'),
        TRegexExpression.Create('[a-z]+', [TRegExOption.roIgnoreCase])
       ]
     )
    ]
  );
  CheckEquals('OneOfRule = "literal_text" / ' +
                           '" " / ' +
                           '~"[0-9]+"p / ' +
                           '" " / ' +
                           '"text that will be repeated"* / ' +
                           '"text that will be repeated"+ / ' +
                           '"text that will be repeated"? / ' +
                           '"text that will be repeated"{2,} / ' +
                           '"text that will be repeated"{3,8} / ' +
                           '"text that will be repeated"{7} / ' +
                           '"text that will be repeated"{0,4} / ' +
                           '&"lookahead" / ' +
                           '~"[a-z]+"i / ' +
                           '!"another_literal_text" / ' +
                           'internal_rule / '+
                           '~"[0-5]+"e / ' +
                           '"literal_text" ~"[0-9]+" ~"[a-z]+"i',
              Rule.AsString, 'AsString of Rule should be showed correctly');
end;

{ TestGrammar }

procedure TestGrammar.Test;
var
  Grammar: IGrammar;
  Rule_bold_text, Rule_open_parens, Rule_text, Rule_close_parens: IRule;
  Expected: IArrayString;
begin
  { create rules }
  Rule_bold_text    := TRule.Create('bold_text');
  Rule_open_parens  := TRule.Create('open_parens');
  Rule_text         := TRule.Create('text');
  Rule_close_parens := TRule.Create('close_parens');

  { setup rules }
  Rule_bold_text.Expression    := TSequenceExpression.Create(
    [TRuleReferenceExpression.Create(Rule_open_parens),
     TRuleReferenceExpression.Create(Rule_text),
     TRuleReferenceExpression.Create(Rule_close_parens)
    ]
  );
  Rule_open_parens.Expression  := TLiteralExpression.Create('((');
  Rule_text.Expression         := TRegexExpression.Create('[a-zA-Z]+');
  Rule_close_parens.Expression := TLiteralExpression.Create('))');

  { create grammar }
  Grammar := TGrammar.Create([Rule_bold_text, Rule_open_parens, Rule_text, Rule_close_parens]);
  Expected := TArrayString.Create;
  Expected.Add('bold_text = open_parens text close_parens');
  Expected.Add('open_parens = "(("');
  Expected.Add('text = ~"[a-zA-Z]+"');
  Expected.Add('close_parens = "))"');
  CheckEquals(Expected.AsString, Grammar.AsString, 'AsString of Grammar is wrong');
end;

initialization
  RegisterTest('HSharp.PEG.Context', TestContext.Suite);
  RegisterTest('HSharp.PEG.Expression', TestExpression.Suite);
  RegisterTest('HSharp.PEG.Grammar', TestGrammar.Suite);
  RegisterTest('HSharp.PEG.Rule', TestRule.Suite);

end.

