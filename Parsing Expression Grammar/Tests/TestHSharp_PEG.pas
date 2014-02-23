unit TestHSharp_PEG;

interface

uses
  TestFramework,
  HSharp.PEG,
  HSharp.PEG.Bootstrap;

type
  TestPEG = class(TTestCase)
  published
    procedure TestRules;
    procedure TestGrammar;
    procedure TestGrammarBootstrap;
  end;

implementation

uses
  System.SysUtils;

{ TestPEG }

procedure TestPEG.TestGrammar;
var
  Context: IContext;
  RootRule: IRule;
  Grammar: IGrammar;
begin
  Context := TContext.Create('text');
  RootRule := RuleFactory.LiteralRule('This is my text');
  Grammar  := TGrammar.Create(RootRule);
//  Grammar.Parse(Context);
end;

procedure TestPEG.TestGrammarBootstrap;
begin
  CheckTrue(PEGGrammar.Parse('Grammar    <- Spacing Definition+ EndOfFile'),
            'Should parse and expression');
end;

procedure TestPEG.TestRules;
var
  Context: IContext;
  Rule: IRule;
  IdRule: IRule;
  NumberRule: IRule;
  SpaceRule: IRule;
  NotEofRule: IRule;
  Seq: IRule;
  ZOM: IRule;
begin
  Context := TContext.Create('This is my textAnother text');
  CheckTrue(RuleFactory.LiteralRule('This is my text').Match(Context), 'Should match');
  CheckTrue(RuleFactory.LiteralRule('Another text').Match(Context), 'Should match twice');
  CheckTrue(RuleFactory.EofRule.Match(Context), 'Should match a empty rule');

  //using class operators
  Context := TContext.Create('This is my textAnother text');
  Rule := RuleFactory.LiteralRule('This is my text').AsRule and
          RuleFactory.LiteralRule('Another text').AsRule;
  CheckTrue(Rule.Match(Context));

  Context := TContext.Create('This is my textAnother text');
  Rule := RuleFactory.LiteralRule('This is my text').AsRule and
          RuleFactory.LiteralRule('This text will not match').AsRule;
  CheckFalse(Rule.Match(Context));

  //we can use the same context because all the expressions weren't matched
  Rule := RuleFactory.LiteralRule('This text will not match').AsRule or
          RuleFactory.LiteralRule('This is my text').AsRule;
  CheckTrue(Rule.Match(Context));

  IdRule := RuleFactory.CustomRule(
    function (const aContext: IContext): Boolean
    begin
      Result := RuleFactory.RegexRule('[A-Za-z_]').Match(aContext) and
                RuleFactory.RegexRule('[0-9A-Za-z_]*').Match(aContext);
    end
  );
  CheckTrue(IdRule.Match(TContext.Create('ThisIsAIdentifier')));
  CheckFalse(IdRule.Match(TContext.Create('091ThisIsAIdentifier')));

  NotEofRule := not RuleFactory.EofRule.AsRule;
  CheckTrue(NotEofRule.Match(TContext.Create('match anything that is not empty')));

  SpaceRule := RuleFactory.RegexRule('[ \t]+');
  NumberRule := RuleFactory.RegexRule('[0-9]+');

  Seq := RuleFactory.SequenceRule([IdRule, SpaceRule, not NumberRule.AsRule, IdRule, SpaceRule, NumberRule]);
  CheckTrue(Seq.Match(TContext.Create('id   notNumber    123')));

  Seq := RuleFactory.SequenceRule([IdRule, SpaceRule, not NumberRule.AsRule, IdRule, SpaceRule, NumberRule]);
  CheckFalse(Seq.Match(TContext.Create('id   123notNumber    123')));

  ZOM := RuleFactory.ZeroOrMoreRule(IdRule.AsRule and SpaceRule.AsRule and NumberRule.AsRule);
  CheckTrue(ZOM.Match(TContext.Create('id 123outroId 4444aaaa 5555')));
end;

initialization
  RegisterTest('HSharp.PEG', TestPEG.Suite);

end.

