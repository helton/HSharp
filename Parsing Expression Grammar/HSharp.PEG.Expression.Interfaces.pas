unit HSharp.PEG.Expression.Interfaces;

interface

uses
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Node.Interfaces;

type
  IExpression = interface
    ['{62F4F422-597B-4B06-AED9-109236BCF845}']
    procedure SetName(const aName: string);
    function GetName: string;
    function IsMatch(const aContext: IContext): Boolean;
    function Match(const aContext: IContext): INode;
    function AsString: string;
    property Name: string read GetName write SetName;
  end;

implementation

end.
