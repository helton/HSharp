unit HSharp.PEG.Expression.Interfaces;

interface

uses
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Node.Interfaces;

type
  IExpression = interface
    ['{62F4F422-597B-4B06-AED9-109236BCF845}']
    function IsMatch(const aContext: IContext): Boolean;
    function Match(const aContext: IContext): INode;
    function AsString: string;
  end;

implementation

end.
