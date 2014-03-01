unit HSharp.PEG.Expression.Interfaces;

interface

uses
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Types;

type
  IExpression = interface
    ['{62F4F422-597B-4B06-AED9-109236BCF845}']
    function GetExpressionHandler: TExpressionHandler;
    procedure SetExpressionHandler(aExpressionHandler: TExpressionHandler);
    function IsMatch(const aContext: IContext): Boolean;
    function Match(const aContext: IContext): INode;
    function AsString: string;
    property ExpressionHandler: TExpressionHandler read GetExpressionHandler
      write SetExpressionHandler;
  end;

implementation

end.
