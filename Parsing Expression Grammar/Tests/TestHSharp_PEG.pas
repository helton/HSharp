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
  HSharp.PEG.Grammar.Bootstrapping,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.GrammarVisitor,
  HSharp.PEG.GrammarVisitor.Attributes,
  HSharp.PEG.Node,
  HSharp.PEG.Node.Interfaces,
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
    procedure TestExpressionHandler;
  end;

  TestRule = class(TTestCase)
  published
    procedure WhenCallAsString_ShouldFormatCorrectly;
    procedure TestExpressionHandler;
  end;

  TestGrammar = class(TTestCase)
  published
    procedure Test;
    procedure TestExpressionGrammarVisitor;
    procedure TestBootstrappingGrammar;
  end;

  TestNode = class(TTestCase)
  published
    procedure TestNodeLiteralExpression;
    procedure TestNodeRegexExpression;
    procedure TestNodeSequenceExpression;
    procedure TestNodeOneOfExpression;
    procedure TestNodeLookahedExpression;
    procedure TestNodeNegativeLookaheadExpression;
    procedure TestNodeRepeatAtLeastExpression;
    procedure TestNodeRepeatRangeExpression;
    procedure TestNodeRepeatZeroOrMoreExpression;
    procedure TestNodeRepeatOneOrMoreExpression;
    procedure TestNodeRepeatOptionalExpression;
    procedure TestNodeRepeatExactlyExpression;
    procedure TestNodeRepeatUpToExpression;
//    procedure TestNodeRuleReferenceExpression;
    procedure TestToString;
  end;

implementation

uses
  System.Rtti,

  Vcl.Dialogs,

  Test.ExpressionGrammar,
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
  Node: INode;
begin
  Context := TContext.Create('1234567890 another text');
  Expr := TRegexExpression.Create('[0-9]+');
  Node := Expr.Match(Context);
  CheckEquals('1234567890', Node.Text, 'After match the matched text should be available');
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
  Node: INode;
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

  Node := OneOf.Match(Context);
  CheckEquals('0123456789', Node.Text, 'Number should be matched');
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

procedure TestExpression.TestExpressionHandler;
var
  InternalExpression, Seq: IExpression;
  Context: IContext;
  InternalTextMatched: string;
begin
  Context := TContext.Create('literal_text 0123456789 anyIdentifier');
  InternalExpression := TRegexExpression.Create('[0-9]+');
  Seq := TSequenceExpression.Create(
    [TLiteralExpression.Create('literal_text'),
     TLiteralExpression.Create(' '),
     InternalExpression,
     TLiteralExpression.Create(' '),
     TRegexExpression.Create('[a-z]+', [TRegExOption.roIgnoreCase])
    ]
  );
  InternalExpression.ExpressionHandler :=
    function (const aNode: INode): TValue
    begin
      Result := aNode.Text;
      InternalTextMatched := Result.AsString;
    end;
  Seq.Match(Context);
  CheckEquals('0123456789', InternalTextMatched);
end;

procedure TestExpression.WhenCallAsStringOnRegexExpression_ShouldFormatCorrectly;
var
  Expr: IExpression;
begin
  Expr := TRegexExpression.Create('[0-9]+', [TRegExOption.roIgnoreCase, TRegExOption.roSingleLine]);
  CheckEquals('/[0-9]+/is', Expr.AsString);
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

procedure TestRule.TestExpressionHandler;
var
  Context: IContext;
  InternalTextMatchedNode, InternalTextMatched0, InternalTextMatched2, InternalTextMatched4: string;
  Rule: IRule;
begin
  Context := TContext.Create('literal_text 0123456789 anyIdentifier');
  Rule := TRule.Create('expression_handler',
    TSequenceExpression.Create(
    [TLiteralExpression.Create('literal_text'),
     TLiteralExpression.Create(' '),
     TRegexExpression.Create('[0-9]+'),
     TLiteralExpression.Create(' '),
     TRegexExpression.Create('[a-z]+', [TRegExOption.roIgnoreCase])
    ]
  ),
  function(const aNode: INode): TValue
  begin
    Result := aNode.Text;
    InternalTextMatched0 := aNode.Children[0].Text;
    InternalTextMatched2 := aNode.Children[2].Text;
    InternalTextMatched4 := aNode.Children[4].Text;
    InternalTextMatchedNode := Result.AsString;
  end);
  Rule.Parse(Context);
  CheckEquals('literal_text 0123456789 anyIdentifier', InternalTextMatchedNode);
  CheckEquals('literal_text', InternalTextMatched0);
  CheckEquals('0123456789', InternalTextMatched2);
  CheckEquals('anyIdentifier', InternalTextMatched4);
end;

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
     TSequenceExpression.Create(
       [TLiteralExpression.Create('literal_text'),
        TRegexExpression.Create('[0-9]+'),
        TRegexExpression.Create('[a-z]+', [TRegExOption.roIgnoreCase])
       ]
     )
    ]
  );
  CheckEquals('<OneOfRule> = "literal_text" | ' +
                             '" " | ' +
                             '/[0-9]+/p | ' +
                             '" " | ' +
                             '"text that will be repeated"* | ' +
                             '"text that will be repeated"+ | ' +
                             '"text that will be repeated"? | ' +
                             '"text that will be repeated"{2,} | ' +
                             '"text that will be repeated"{3,8} | ' +
                             '"text that will be repeated"{7} | ' +
                             '"text that will be repeated"{0,4} | ' +
                             '&"lookahead" | ' +
                             '/[a-z]+/i | ' +
                             '!"another_literal_text" | ' +
                             'internal_rule | '+
                             '/[0-5]+/e | ' +
                             '"literal_text" /[0-9]+/ /[a-z]+/i',
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
  Expected.Add('<bold_text> = open_parens text close_parens');
  Expected.Add('<open_parens> = "(("');
  Expected.Add('<text> = /[a-zA-Z]+/');
  Expected.Add('<close_parens> = "))"');
  CheckEquals(Expected.AsString, Grammar.AsString, 'AsString of Grammar is wrong');
end;

procedure TestGrammar.TestBootstrappingGrammar;
var
  BootstrappingGrammar: TBootstrappingGrammar;
begin
  BootstrappingGrammar := TBootstrappingGrammar.Create(nil);
  try
    {}
  finally
    BootstrappingGrammar.Free;
  end;
end;

procedure TestGrammar.TestExpressionGrammarVisitor;
var
  GrammarVisitor: TExpressionGrammarVisitor;
begin
  GrammarVisitor := TExpressionGrammarVisitor.Create;
  try

  finally
    GrammarVisitor.Free;
  end;
end;

{ TestNode }

procedure TestNode.TestNodeLiteralExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('literal_text here');
  Exp := TLiteralExpression.Create('literal_text');
  Node := Exp.Match(Context);
  CheckEquals('literal_text', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNull(Node.Children);
end;

procedure TestNode.TestNodeLookahedExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('0123456789 original text');
  Exp := TLookahedExpression.Create(TRegexExpression.Create('[0-9]+'));
  Node := Exp.Match(Context);
  CheckEquals('0123456789', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNull(Node.Children);
end;

procedure TestNode.TestNodeNegativeLookaheadExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('original text 0123456789');
  Exp := TNegativeLookaheadExpression.Create(TRegexExpression.Create('[0-9]+'));
  Node := Exp.Match(Context);
  CheckEquals('', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNull(Node.Children);
end;

procedure TestNode.TestNodeOneOfExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('0123456789 literal_text anyIdentifier');
  Exp := TOneOfExpression.Create(
    [
     TRegexExpression.Create('[a-z]+', [TRegExOption.roIgnoreCase]),
     TLiteralExpression.Create(' '),
     TLiteralExpression.Create('literal_text_not_match'),
     TRegexExpression.Create('[0-9]+')
    ]
  );
  Node := Exp.Match(Context);
  CheckEquals('0123456789', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNull(Node.Children);
end;

procedure TestNode.TestNodeRegexExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('literal_text here');
  Exp := TRegexExpression.Create('[a-z_]+');
  Node := Exp.Match(Context);
  CheckEquals('literal_text', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNull(Node.Children);
end;

procedure TestNode.TestNodeRepeatAtLeastExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('first_id second_id this_id 0123456789');
  Exp := TRepeatAtLeastExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 2);
  Node := Exp.Match(Context);
  CheckEquals('first_id second_id this_id ', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNotNull(Node.Children);
  CheckEquals(3, Node.Children.Count);

  CheckEquals('first_id ', Node.Children[0].Text);
  CheckEquals(0, Node.Children[0].Index);

  CheckEquals('second_id ', Node.Children[1].Text);
  CheckEquals(9, Node.Children[1].Index);

  CheckEquals('this_id ', Node.Children[2].Text);
  CheckEquals(19, Node.Children[2].Index);
end;

procedure TestNode.TestNodeRepeatExactlyExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('first_id second_id this_id 0123456789');
  Exp := TRepeatExactlyExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 3);
  Node := Exp.Match(Context);
  CheckEquals('first_id second_id this_id ', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNotNull(Node.Children);
  CheckEquals(3, Node.Children.Count);

  CheckEquals('first_id ', Node.Children[0].Text);
  CheckEquals(0, Node.Children[0].Index);

  CheckEquals('second_id ', Node.Children[1].Text);
  CheckEquals(9, Node.Children[1].Index);

  CheckEquals('this_id ', Node.Children[2].Text);
  CheckEquals(19, Node.Children[2].Index);
end;

procedure TestNode.TestNodeRepeatOneOrMoreExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('first_id second_id this_id 0123456789');
  Exp := TRepeatOneOrMoreExpression.Create(TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]));
  Node := Exp.Match(Context);
  CheckEquals('first_id second_id this_id ', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNotNull(Node.Children);
  CheckEquals(3, Node.Children.Count);

  CheckEquals('first_id ', Node.Children[0].Text);
  CheckEquals(0, Node.Children[0].Index);

  CheckEquals('second_id ', Node.Children[1].Text);
  CheckEquals(9, Node.Children[1].Index);

  CheckEquals('this_id ', Node.Children[2].Text);
  CheckEquals(19, Node.Children[2].Index);
end;

procedure TestNode.TestNodeRepeatOptionalExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('original text 0123456789');
  Exp := TRepeatOptionalExpression.Create(TRegexExpression.Create('[0-9]+'));
  Node := Exp.Match(Context);
  CheckEquals('', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNull(Node.Children);

  Context := TContext.Create('0123456789 original text');
  Exp := TRepeatOptionalExpression.Create(TRegexExpression.Create('[0-9]+'));
  Node := Exp.Match(Context);
  CheckEquals('0123456789', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNull(Node.Children);
end;

procedure TestNode.TestNodeRepeatRangeExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('first_id second_id this_id 0123456789');
  Exp := TRepeatRangeExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 2, 3);
  Node := Exp.Match(Context);
  CheckEquals('first_id second_id this_id ', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNotNull(Node.Children);
  CheckEquals(3, Node.Children.Count);

  CheckEquals('first_id ', Node.Children[0].Text);
  CheckEquals(0, Node.Children[0].Index);

  CheckEquals('second_id ', Node.Children[1].Text);
  CheckEquals(9, Node.Children[1].Index);

  CheckEquals('this_id ', Node.Children[2].Text);
  CheckEquals(19, Node.Children[2].Index);
end;

procedure TestNode.TestNodeRepeatUpToExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('first_id second_id this_id 0123456789');
  Exp := TRepeatUpToExpression.Create(
    TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]), 2);
  Node := Exp.Match(Context);
  CheckEquals('first_id second_id ', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNotNull(Node.Children);
  CheckEquals(2, Node.Children.Count);

  CheckEquals('first_id ', Node.Children[0].Text);
  CheckEquals(0, Node.Children[0].Index);

  CheckEquals('second_id ', Node.Children[1].Text);
  CheckEquals(9, Node.Children[1].Index);
end;


procedure TestNode.TestNodeRepeatZeroOrMoreExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('0123456789 first_id second_id this_id');
  Exp := TRepeatZeroOrMoreExpression.Create(TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]));
  Node := Exp.Match(Context);
  CheckNotNull(Node);
  CheckEquals('', Node.Text);
  CheckEquals(0, Node.Index);

  Context := TContext.Create('first_id second_id this_id 0123456789');
  Exp := TRepeatZeroOrMoreExpression.Create(TRegexExpression.Create('[a-z_]+ ', [TRegExOption.roIgnoreCase]));
  Node := Exp.Match(Context);
  CheckNotNull(Node.Children);
  CheckEquals(3, Node.Children.Count);

  CheckEquals('first_id ', Node.Children[0].Text);
  CheckEquals(0, Node.Children[0].Index);

  CheckEquals('second_id ', Node.Children[1].Text);
  CheckEquals(9, Node.Children[1].Index);

  CheckEquals('this_id ', Node.Children[2].Text);
  CheckEquals(19, Node.Children[2].Index);
end;

procedure TestNode.TestNodeSequenceExpression;
var
  Exp: IExpression;
  Context: IContext;
  Node: INode;
begin
  Context := TContext.Create('literal_text 0123456789 anyIdentifier');
  Exp := TSequenceExpression.Create(
    [TLiteralExpression.Create('literal_text'),
     TLiteralExpression.Create(' '),
     TRegexExpression.Create('[0-9]+'),
     TLiteralExpression.Create(' '),
     TRegexExpression.Create('[a-z]+', [TRegExOption.roIgnoreCase])
    ]
  );
  Node := Exp.Match(Context);
  CheckEquals('literal_text 0123456789 anyIdentifier', Node.Text);
  CheckEquals(0, Node.Index);
  CheckNotNull(Node.Children);
  CheckEquals(5, Node.Children.Count);

  CheckEquals('literal_text', Node.Children[0].Text);
  CheckEquals(0, Node.Children[0].Index);

  CheckEquals(' ', Node.Children[1].Text);
  CheckEquals(12, Node.Children[1].Index);

  CheckEquals('0123456789', Node.Children[2].Text);
  CheckEquals(13, Node.Children[2].Index);

  CheckEquals(' ', Node.Children[3].Text);
  CheckEquals(23, Node.Children[3].Index);

  CheckEquals('anyIdentifier', Node.Children[4].Text);
  CheckEquals(24, Node.Children[4].Index);
end;

procedure TestNode.TestToString;
var
  Context: IContext;
  Rule: IRule;
  ReturnedText: string;

  function GetExpectedText: string;
  var
    Arr: TArrayString;
  begin
    Arr := TArrayString.Create;
    Arr.Add('<node>');
    Arr.Add('  <value>literal_text 0123456789 anyIdentifier</value>');
    Arr.Add('  <text>literal_text 0123456789 anyIdentifier</text>');
    Arr.Add('  <index>0</index>');
    Arr.Add('  <children>');
    Arr.Add('    <node>');
    Arr.Add('      <value>literal_text</value>');
    Arr.Add('      <text>literal_text</text>');
    Arr.Add('      <index>0</index>');
    Arr.Add('    </node>');
    Arr.Add('    <node>');
    Arr.Add('      <value> </value>');
    Arr.Add('      <text> </text>');
    Arr.Add('      <index>12</index>');
    Arr.Add('    </node>');
    Arr.Add('    <node>');
    Arr.Add('      <value>0123456789</value>');
    Arr.Add('      <text>0123456789</text>');
    Arr.Add('      <index>13</index>');
    Arr.Add('    </node>');
    Arr.Add('    <node>');
    Arr.Add('      <value> </value>');
    Arr.Add('      <text> </text>');
    Arr.Add('      <index>23</index>');
    Arr.Add('    </node>');
    Arr.Add('    <node>');
    Arr.Add('      <value>anyIdentifier</value>');
    Arr.Add('      <text>anyIdentifier</text>');
    Arr.Add('      <index>24</index>');
    Arr.Add('    </node>');
    Arr.Add('  </children>');
    Arr.Add('</node>');
    Result := Arr.AsString;
  end;

begin
  Context := TContext.Create('literal_text 0123456789 anyIdentifier');
  Rule := TRule.Create('expression_handler',
    TSequenceExpression.Create(
    [TLiteralExpression.Create('literal_text'),
     TLiteralExpression.Create(' '),
     TRegexExpression.Create('[0-9]+'),
     TLiteralExpression.Create(' '),
     TRegexExpression.Create('[a-z]+', [TRegExOption.roIgnoreCase])
    ]
  ));
  ReturnedText := Rule.Parse(Context).ToString;
  CheckEquals(GetExpectedText, ReturnedText);
end;

initialization
  RegisterTest('HSharp.PEG.Context', TestContext.Suite);
  RegisterTest('HSharp.PEG.Expression', TestExpression.Suite);
  RegisterTest('HSharp.PEG.Grammar', TestGrammar.Suite);
  RegisterTest('HSharp.PEG.Node', TestNode.Suite);
  RegisterTest('HSharp.PEG.Rule', TestRule.Suite);

end.

