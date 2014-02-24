unit HSharp.PEG.Rule.Interfaces;

interface

uses
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Expression.Interfaces;

type
  IRule = interface
    ['{4288D2E1-362C-468D-AC88-99C2C1E236D7}']
    function GetName: string;
    function GetExpression: IExpression;
    procedure SetExpression(const aExpression: IExpression);
    function Parse(const aContext: IContext): Boolean;
    function AsString: string;
    property Name: string read GetName;
    property Expression: IExpression read GetExpression write SetExpression;
  end;

implementation

end.
