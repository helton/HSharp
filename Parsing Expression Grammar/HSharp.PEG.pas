unit HSharp.PEG;

interface

uses
  System.Generics.Collections, {TODO -oHelton -cCreate : Create a interface to Stack in HSharp.Collections.Interfaces, a IStack<T>}
  System.RegularExpressions,
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.WeakReference;

type
  {$REGION 'Forwarding declarations'}
  IRule    = interface;
  IContext = interface;
  {$ENDREGION}

  {$REGION 'Types'}

  TFuncApplyRule = reference to function (const aContext: IContext): Boolean;

  {$SCOPEDENUMS ON}
  TMatchAction = (Greedy, Ungreedy);
  {$SCOPEDENUMS OFF}

  TRule = record
  private
    FRule: IRule;
  public
    property Rule: IRule read FRule write FRule;
    function Match(const aContext: IContext): Boolean;
    class operator Implicit(aRule: IRule): TRule;
    class operator Implicit(aRule: TRule): IRule;
    class operator LogicalAnd(aLeftRule, ARightRule: TRule): TRule;
    class operator LogicalNot(aRule: TRule): TRule;
    class operator LogicalOr(aLeftRule, ARightRule: TRule): TRule;
  end;

  {$ENDREGION}

  {$REGION 'Interfaces'}

  IContext = interface
    ['{BCCB62C1-06A3-4678-8D53-0A030952FC81}']
    procedure IncIndex(aOffset: Integer);
    procedure SaveState;
    procedure RestoreState;
    { Property accessors }
    function GetIndex: Integer;
    function GetText: string;
    { Properties }
    property Index: Integer read GetIndex;
    property Text: string read GetText;
  end;

  IRule = interface
    ['{B75E5ABD-3F73-4EB9-8FB5-FA5AC371E8AF}']
    function Match(const aContext: IContext; aMatchAction: TMatchAction = TMatchAction.Greedy): Boolean;
    function AsRule: TRule;
  end;

  IRegexRule = interface(IRule)
    ['{024F0139-1BBF-46C4-9901-39AF5F752DE3}']
  end;

  ILiteralRule = interface(IRule)
    ['{4A8C2760-31E9-4FC3-98FE-FA4A790B2CC2}']
  end;

  IGrammar = interface
    ['{E1A9FA2D-86A4-4EEB-969A-0DE8C36848FF}']
    function GetRootRule: IRule;
    function Parse(const aText: string): Boolean;
    property RootRule: IRule read GetRootRule;
  end;

  {$ENDREGION}

  {$REGION 'Classes'}

  TContext = class(TInterfacedObject, IContext)
  strict private
    FText: string;
    FIndex: Integer;
    FState: TStack<Integer>;
  private
    function GetText: string;
    function GetIndex: Integer;
  public
    procedure IncIndex(aOffset: Integer);
    procedure SaveState;
    procedure RestoreState;
    constructor Create(const aText: String); reintroduce;
    destructor Destroy; override;
  end;

  //TSequenceRule
  //TExpressionRule

  TGrammar = class(TInterfacedObject, IGrammar)
  strict private
    FRootRule: Weak<IRule>;
  strict protected
    function GetRootRule: IRule;
  public
    function Parse(const aText: string): Boolean;
    constructor Create(const aRootRule: IRule); reintroduce;
  end;

  {$ENDREGION}

  {$REGION 'Rule function factories'}

  RuleFactory = class
  strict private
    {$REGION 'Predefined rules - Lazy initialization' }
    class var
      FEofRule: IRule;
    {$ENDREGION}
  public
    { Rule function factories }
    class function CustomRule(aFuncApplyRule: TFuncApplyRule): IRule;
    class function LiteralRule(const aConstant: string): ILiteralRule;
    class function RegexRule(const aPattern: string): IRegexRule;
    class function SequenceRule(const aRules: array of IRule): IRule; //can be easily simulated by => rule1 AND rule2 AND rule3 AND ...
    class function ZeroOrMoreRule(const aRule: IRule): IRule;
    class function OneOrMoreRule(const aRule: IRule): IRule;
    class function OptionalRule(const aRule: IRule): IRule;
    class function OneOf(const aRules: array of IRule): IRule; //can be easily simulated by => rule1 OR rule2 OR rule3 OR ...
    { Predefined rules }
    class function EofRule: IRule;
  end;

  {$ENDREGION}

implementation

uses
  System.SysUtils,
  System.StrUtils;

type
  {$REGION 'Internal rule classes'}
  TAbstractRule = class abstract(TInterfacedObject, IRule)
    //FMatchedText: string
    //FName: string
  public
    function ApplyRule(const aContext: IContext): Boolean; virtual; abstract;
    function Match(const aContext: IContext; aMatchAction: TMatchAction = TMatchAction.Greedy): Boolean;
    function AsRule: TRule;
  end;

  TRegexRule = class(TAbstractRule, IRegexRule)
  strict private
    FPattern: string;
  public
    constructor Create(const aPattern: string); reintroduce;
    function ApplyRule(const aContext: IContext): Boolean; override;
  end;

  TLiteralRule = class(TRegexRule, ILiteralRule)
  public
    constructor Create(const aLiteral: string); reintroduce;
  end;

  TCustomRule = class(TAbstractRule)
  strict private
    FFuncApplyRule: TFuncApplyRule;
  public
    function ApplyRule(const aContext: IContext): Boolean; override;
    constructor Create(aFuncApplyRule: TFuncApplyRule); reintroduce;
  end;
  {$ENDREGION}

{ RuleFactory }

class function RuleFactory.LiteralRule(const aConstant: string): ILiteralRule;
begin
  Result := TLiteralRule.Create(aConstant);
end;

class function RuleFactory.OneOf(const aRules: array of IRule): IRule;
var
  Rule: IRule;
begin
  for Rule in aRules do
  begin
    if not Assigned(Result) then
      Result := Rule.AsRule
    else
      Result := Result or Rule.AsRule;
  end;
end;

class function RuleFactory.OneOrMoreRule(const aRule: IRule): IRule;
begin
  Result := CustomRule(
    function (const aContext: IContext): Boolean
    begin
      Result := aRule.Match(aContext);
      if Result then
      begin
        while aRule.Match(aContext) do ;
        Result := True;
      end;
    end
  );
end;

class function RuleFactory.OptionalRule(const aRule: IRule): IRule;
begin
  Result := CustomRule(
    function (const aContext: IContext): Boolean
    begin
      aRule.Match(aContext);
      Result := True;
    end
  );
end;

class function RuleFactory.SequenceRule(const aRules: array of IRule): IRule;
var
  Rule: IRule;
begin
  for Rule in aRules do
  begin
    if not Assigned(Result) then
      Result := Rule.AsRule
    else
      Result := Result and Rule.AsRule;
  end;
end;

class function RuleFactory.ZeroOrMoreRule(const aRule: IRule): IRule;
begin
  Result := CustomRule(
    function (const aContext: IContext): Boolean
    begin
      while aRule.Match(aContext) do ;
      Result := True;
    end
  );
end;

class function RuleFactory.CustomRule(aFuncApplyRule: TFuncApplyRule): IRule;
begin
  Result := TCustomRule.Create(aFuncApplyRule);
end;

class function RuleFactory.EofRule: IRule;
begin
  if not Assigned(FEofRule) then
  begin
    FEofRule := CustomRule(
      function (const aContext: IContext): Boolean
      begin
        Result := aContext.Text.IsEmpty;
      end
    );
  end;
  Result := FEofRule;
end;

class function RuleFactory.RegexRule(const aPattern: string): IRegexRule;
begin
  Result := TRegexRule.Create('^' + aPattern);
end;

{ TContext }

constructor TContext.Create(const aText: String);
begin
  inherited Create;
  FText  := aText;
  FState := TStack<Integer>.Create;
end;

destructor TContext.Destroy;
begin
  FState.Free;
  inherited;
end;

function TContext.GetIndex: Integer;
begin
  Result := FIndex;
end;

function TContext.GetText: string;
begin
  Result := RightStr(FText, Length(FText) - FIndex);
end;

procedure TContext.IncIndex(aOffset: Integer);
begin
  Inc(FIndex, aOffset);
end;

procedure TContext.RestoreState;
begin
  FIndex := FState.Pop;
end;

procedure TContext.SaveState;
begin
  FState.Push(FIndex);
end;

{ TRule }

function TAbstractRule.AsRule: TRule;
begin
  Result.Rule := Self;
end;

function TAbstractRule.Match(const aContext: IContext;
  aMatchAction: TMatchAction): Boolean;
begin
  aContext.SaveState;
  Result := ApplyRule(aContext);
  if not Result and (aMatchAction = TMatchAction.Greedy) then
    aContext.RestoreState;
end;

{ TConstantRule }

constructor TLiteralRule.Create(const aLiteral: string);
begin
  inherited Create(TRegex.Escape(aLiteral));
end;

{ TRegexRule }

function TRegexRule.ApplyRule(const aContext: IContext): Boolean;
var
  Match: TMatch;
begin
  Match := TRegex.Match(aContext.Text, FPattern);
  Result := Match.Success;
  aContext.IncIndex(Match.Index + Match.Length - 1);
end;

constructor TRegexRule.Create(const aPattern: string);
begin
  inherited Create;
  FPattern := aPattern;
end;

{ TCustomRule }

function TCustomRule.ApplyRule(const aContext: IContext): Boolean;
begin
  Result := FFuncApplyRule(aContext);
end;

constructor TCustomRule.Create(aFuncApplyRule: TFuncApplyRule);
begin
  inherited Create;
  FFuncApplyRule := aFuncApplyRule;
end;

{ Rule }

class operator TRule.Implicit(aRule: TRule): IRule;
begin
  Result := aRule.Rule;
end;

class operator TRule.Implicit(aRule: IRule): TRule;
begin
  Result.Rule := aRule;
end;

class operator TRule.LogicalAnd(aLeftRule, ARightRule: TRule): TRule;
begin
  Result.Rule := TCustomRule.Create(
    function (const aContext: IContext): Boolean
    begin
      Result := aLeftRule.Rule.Match(aContext) and ARightRule.Rule.Match(aContext);
    end
  );
end;

class operator TRule.LogicalNot(aRule: TRule): TRule;
begin
  Result.Rule := TCustomRule.Create(
    function (const aContext: IContext): Boolean
    begin
      Result := not aRule.Rule.Match(aContext);
    end
  );
end;

class operator TRule.LogicalOr(aLeftRule, ARightRule: TRule): TRule;
begin
  Result.Rule := TCustomRule.Create(
    function (const aContext: IContext): Boolean
    begin
      Result := aLeftRule.Rule.Match(aContext) or ARightRule.Rule.Match(aContext);
    end
  );
end;

function TRule.Match(const aContext: IContext): Boolean;
begin
  Result := FRule.Match(aContext);
end;

{ TGrammar }

constructor TGrammar.Create(const aRootRule: IRule);
begin
  inherited Create;
  FRootRule := aRootRule;
end;

function TGrammar.GetRootRule: IRule;
begin
  Result := FRootRule;
end;

function TGrammar.Parse(const aText: string): Boolean;
begin
  Result := GetRootRule.Match(TContext.Create(aText));
end;

end.
