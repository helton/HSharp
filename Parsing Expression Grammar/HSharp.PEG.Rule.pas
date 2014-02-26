unit HSharp.PEG.Rule;

interface

uses
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Expression.Interfaces,
  HSharp.PEG.Rule.Interfaces;

type
  TRule = class(TInterfacedObject, IRule)
  strict private
    FName: string;
    FExpression: IExpression;
  strict protected
    function GetName: string;
    function GetExpression: IExpression;
    procedure SetExpression(const aExpression: IExpression);
  public
    function AsString: string;
    function Parse(const aContext: IContext): Boolean;
    constructor Create(const aName: string; aExpression: IExpression = nil); reintroduce;
  end;

implementation

{ TRule }

constructor TRule.Create(const aName: string; aExpression: IExpression);
begin
  inherited Create;
  FName       := aName;
  FExpression := aExpression;
end;

function TRule.GetExpression: IExpression;
begin
  Result := FExpression;
end;

function TRule.GetName: string;
begin
  Result := FName;
end;

function TRule.Parse(const aContext: IContext): Boolean;
begin
  Result := FExpression.IsMatch(aContext);
  FExpression.Match(aContext);
end;

procedure TRule.SetExpression(const aExpression: IExpression);
begin
  FExpression := aExpression;
end;

function TRule.AsString: string;
begin
  Result := '<' + FName + '> = ' + FExpression.AsString;
end;

end.
