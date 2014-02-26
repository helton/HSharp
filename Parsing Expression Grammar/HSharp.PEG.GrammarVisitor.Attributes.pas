unit HSharp.PEG.GrammarVisitor.Attributes;

interface

type
  RuleAttribute = class(TCustomAttribute)
  strict private
    FRule: string;
  public
    constructor Create(aRule: string);
    property Rule: string read FRule;
  end;

implementation

{ RuleAttribute }

constructor RuleAttribute.Create(aRule: string);
begin
  inherited Create;
  FRule := aRule;
end;

end.
